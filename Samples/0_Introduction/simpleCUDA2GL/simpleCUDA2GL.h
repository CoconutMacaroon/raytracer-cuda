#include <float.h>

#define LIGHT_TYPE_AMBIENT 1
#define LIGHT_TYPE_POINT 2
#define LIGHT_TYPE_DIRECTIONAL 3

typedef unsigned char byte;

#define LENGTH(n) (sqrt(dot(n, n)))
#define ARR_LEN(a) (sizeof(a) / sizeof((a)[0]))
#define ROUND_COLOR(c) (round(c) > 255.0 ? 255 : (byte)round(c))

typedef struct Color
{
    int r, g, b;
} Color;

typedef struct Sphere
{
    double radius;
    double center[3];
    Color color;
    double specular;
    double reflectiveness;
} Sphere;

typedef struct IntersectionData
{
    Sphere sphere;
    double closest_t;
    bool isSphereNull;
} IntersectionData;

typedef struct Light
{
    short lightType;
    double intensity;
    double position[3];
    double direction[3];
} Light;
__device__ Color BACKGROUND_COLOR = {0, 0, 0};

const short CANVAS_WIDTH = 1024;
const short CANVAS_HEIGHT = 1024;

__device__ double D = 1;
// TODO: I may need to swap CANVAS_WIDTH and CANVAS_HEIGHT
//       in this division if CANVAS_HEIGHT > CANVAS_WIDTH
__device__ const double VIEWPORT_WIDTH =
    (double)CANVAS_WIDTH / (double)CANVAS_HEIGHT;
__device__ const double VIEWPORT_HEIGHT = 1;
__device__ const double inf = DBL_MAX;
__device__ double cameraPosition[] = {0, 0, 0};

// TODO: recursion is causing issues, make the reflection code a loop instead
// it fails when this is > 1
__device__ int RECURSION_DEPTH_FOR_REFLECTIONS = 1;

__device__ Sphere spheres[] = {{.radius = 1.0f,
                                .center = {-2, 0, 4},
                                .color = {0, 255, 0},
                                .specular = 500,
                                .reflectiveness = 0.2f},
                               {.radius = 1.0f,
                                .center = {2, 0, 4},
                                .color = {0, 0, 255},
                                .specular = 500,
                                .reflectiveness = 0.3f},
                               {.radius = 1.0f,
                                .center = {0, -1, 3},
                                .color = {255, 0, 0},
                                .specular = 10,
                                .reflectiveness = 0.4f},
                               {.radius = 5000,
                                .center = {0, -5001, 0},
                                .color = {255, 255, 0},
                                .specular = 1000,
                                .reflectiveness = 0.5f}};

__device__ Light lights[] = {(Light){.lightType = LIGHT_TYPE_AMBIENT,
                                     .intensity = 0.2f,
                                     .position = {},
                                     .direction = {}},
                             (Light){.lightType = LIGHT_TYPE_POINT,
                                     .intensity = 0.6f,
                                     .position = {2.0f, 1.0f, 0.0f},
                                     .direction = {}},
                             (Light){.lightType = LIGHT_TYPE_DIRECTIONAL,
                                     .intensity = 0.2f,
                                     .position = {},
                                     .direction = {1.0f, 4.0f, 4.0f}}};
typedef struct
{
    short x, y;
} Pixel;

typedef struct
{
    int x, y;
    byte r, g, b;
} PixelRenderData;
