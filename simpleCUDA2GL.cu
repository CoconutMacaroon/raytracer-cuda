#include "simpleCUDA2GL.h"

// Utilities and system includes

#include <helper_cuda.h>

// clamp x to range [a, b]
__device__ float clamp(float x, float a, float b) { return max(a, min(b, x)); }

__device__ int clamp(int x, int a, int b) { return max(a, min(b, x)); }

// convert floating point rgb color to 8-bit integer
__device__ int rgbToInt(float r, float g, float b) {
    r = clamp(r, 0.0f, 255.0f);
    g = clamp(g, 0.0f, 255.0f);
    b = clamp(b, 0.0f, 255.0f);
    return (int(b) << 16) | (int(g) << 8) | int(r);
}

__device__ double dot(const double x[3], const double y[3]) {
    return (x[0] * y[0]) + (x[1] * y[1]) + (x[2] * y[2]);
}

__device__ void add(const double a[], const double b[], double *resultLocation) {
    resultLocation[0] = a[0] + b[0];
    resultLocation[1] = a[1] + b[1];
    resultLocation[2] = a[2] + b[2];
}

__device__ void subtract(const double a[], const double b[], double *resultLocation) {
    resultLocation[0] = a[0] - b[0];
    resultLocation[1] = a[1] - b[1];
    resultLocation[2] = a[2] - b[2];
}

__device__ void multiply(double a, const double b[], double *resultLocation) {
    resultLocation[0] = a * b[0];
    resultLocation[1] = a * b[1];
    resultLocation[2] = a * b[2];
}

__device__ void canvasToViewport(int x, int y, double *returnLocation) {
    returnLocation[0] = x * VIEWPORT_WIDTH / (double) CANVAS_WIDTH;
    returnLocation[1] = y * VIEWPORT_HEIGHT / (double) CANVAS_HEIGHT;
    returnLocation[2] = D;
}

__device__ void reflectRay(double R[], double N[], double *returnLocation) {
    double n_dot_r = dot(N, R);
    double n_multiply_two[3];
    multiply(2, N, n_multiply_two);

    double dot_times_multiply[3];
    multiply(n_dot_r, n_multiply_two, dot_times_multiply);

    subtract(dot_times_multiply, R, returnLocation);
}

__device__ void intersectRaySphere(double cameraPos[], double d[], Sphere sphere, double *returnLocation) {
    double CO[3];
    subtract(cameraPos, sphere.center, CO);

    double a = dot(d, d);
    double b = 2 * dot(CO, d);
    double c = dot(CO, CO) - sphere.radius * sphere.radius;

    double discriminant = b * b - 4 * a * c;

    if (discriminant < 0) {
        returnLocation[0] = inf;
        returnLocation[1] = inf;
        return;
    }

    double discriminantSqrt = sqrt(discriminant);

    returnLocation[0] = (double) ((-b + discriminantSqrt) / (2 * a));
    returnLocation[1] = (double) ((-b - discriminantSqrt) / (2 * a));
}

__device__ IntersectionData closestIntersection(double cameraPos[], double d[], double t_min, double t_max) {
    double closest_t = inf;
    Sphere closestSphere;
    bool isNull = true;
    for (size_t i = 0; i < ARR_LEN(spheres); ++i) {
        double t[2];
        intersectRaySphere(cameraPos, d, spheres[i], t);

        if (t[0] < closest_t && t_min < t[0] && t[0] < t_max) {
            closest_t = t[0];
            closestSphere = spheres[i];
            isNull = false;
        }
        if (t[1] < closest_t && t_min < t[1] && t[1] < t_max) {
            closest_t = t[1];
            closestSphere = spheres[i];
            isNull = false;
        }
    }
    IntersectionData data = {.sphere = closestSphere, .closest_t = closest_t, .isSphereNull = isNull};
    return data;
}

__device__ double computeLighting(double P[], double N[], double V[], double s) {
    double intensity = 0.0;
    for (size_t i = 0; i < ARR_LEN(lights); ++i) {
        if (lights[i].lightType == LIGHT_TYPE_AMBIENT) {
            intensity += lights[i].intensity;
        } else {
            double L[3];
            double t_max;
            if (lights[i].lightType == LIGHT_TYPE_POINT) {
                subtract(lights[i].position, P, L);
                t_max = 1.0;
            } else {
                L[0] = lights[i].direction[0];
                L[1] = lights[i].direction[1];
                L[2] = lights[i].direction[2];
                t_max = DBL_MAX;
            }
            // shadow check
            IntersectionData intersectionData = closestIntersection(P, L, 0.001, t_max);

            if (!intersectionData.isSphereNull)
                continue;

            // diffuse
            double n_dot_l = dot(N, L);

            if (n_dot_l > 0)
                intensity += lights[i].intensity * n_dot_l / (LENGTH(N) * LENGTH(L));

            // specular
            if (s != -1) {
                // 2 * N * dot(N, L) - L
                double R[3];

                reflectRay(L, N, R);

                double r_dot_v = dot(R, V);

                if (r_dot_v > 0)
                    intensity += lights[i].intensity * pow(r_dot_v / (LENGTH(R) * LENGTH(V)), s);
            }
        }
    }
    return intensity;
}

__device__ Color traceRay(double cameraPos[3], double d[], double min_t, double max_t, int recursion_depth) {
    IntersectionData intersectionData = closestIntersection(cameraPos, d, min_t, max_t);
    if (intersectionData.isSphereNull)
        return BACKGROUND_COLOR;

    double tmp1[3];
    multiply(intersectionData.closest_t, d, tmp1);

    double P[3];
    add(cameraPos, tmp1, P);

    double N[3];
    subtract(P, intersectionData.sphere.center, N);

    double N2[3];
    multiply(1.0 / LENGTH(N), N, N2);

    double tmp3[3];
    multiply(-1.0, d, tmp3);
    double lighting = computeLighting(P, N, tmp3, intersectionData.sphere.specular);
    Color localColor = {ROUND_COLOR(intersectionData.sphere.color.r * lighting),
                        ROUND_COLOR(intersectionData.sphere.color.g * lighting),
                        ROUND_COLOR(intersectionData.sphere.color.b * lighting)};

    if (recursion_depth <= 0 || intersectionData.sphere.reflectiveness <= 0)
        return localColor;

    double temp[3];
    multiply(-1.0, d, temp);
    double R[3];
    reflectRay(temp, N2, R);

    Color reflectedColor = traceRay(P, R, 0.001, inf, recursion_depth - 1);
    return (Color) {ROUND_COLOR(localColor.r * (1 - intersectionData.sphere.reflectiveness) +
                                reflectedColor.r * intersectionData.sphere.reflectiveness), ROUND_COLOR(
                            localColor.g * (1 - intersectionData.sphere.reflectiveness) +
                            reflectedColor.g * intersectionData.sphere.reflectiveness), ROUND_COLOR(
                            localColor.b * (1 - intersectionData.sphere.reflectiveness) +
                            reflectedColor.b * intersectionData.sphere.reflectiveness)};
}

__global__ void cudaProcess(unsigned int *g_odata, int imgw) {
    extern __shared__ uchar4 sdata[];

    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int bw = blockDim.x;
    int bh = blockDim.y;
    int x = blockIdx.x * bw + tx;
    int y = blockIdx.y * bh + ty;
    /*
     * THIS IS HOW WE DRAW A PIXEL:
     * g_odata[y * imgw + x] = rgbToInt(0, 255, 255);
     */

    double d[3];
    canvasToViewport(x - (CANVAS_WIDTH / 2), y - (CANVAS_HEIGHT / 2), d);
    Color c = traceRay(cameraPosition, d, 1, inf, RECURSION_DEPTH_FOR_REFLECTIONS);
    g_odata[y * imgw + x] = rgbToInt(c.r, c.g, c.b);
}

__global__ void moveCamera(double z, double y, double x) {
    cameraPosition[0] += x;
    cameraPosition[1] += y;
    cameraPosition[2] += z;
}
extern "C" void launch_cudaProcess(dim3 grid, dim3 block, int sbytes, unsigned int *g_odata, int imgw) {
    keyActions();
    cudaProcess<<<grid, block, sbytes>>>(g_odata, imgw);
}

extern void moveCam(double z, double y, double x) {
    moveCamera<<<1, 1>>>(z, y, x);
}
