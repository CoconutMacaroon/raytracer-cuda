# CUDA + OpenGL Rayracer

This is [my original raytracer](https://github.com/coconutmacaroon/raytracer), but re-written in CUDA with OpenGL instead of Java. This is _significantly_ faster. The Java version takes up to several seconds to render one frame (on my machine, at 1024x1024). In contrast, this version can do around 40FPS (again, at 1024x1024 on my machine).

## Compiling

I'm assuming you've cloned the repo and are in the main directory. In theory, you can just do `make clean all && ./simpleCUDA2GL`. Unfortunately, this did not work for me. To get it to compile, I had to do `GLPATH=/usr/lib make clean all`, and then `optirun ./simpleCUDA2GL` as I have hybrid graphics in my laptop. Additionally, my GPU has a compute level of 6.1, so I added `SMS="61"` to my make command. If you don't, it will just compile for all architectures (which will work, it is just slower).

The final command I ran to build and run was

```bash
GLPATH=/usr/lib make clean all SMS="61" && optirun ./simpleCUDA2GL
```

## Explanation of code files

### `go.sh`

This is a simple file that build and runs it. If you use it, remember to change the `61` to the compute capability of your GPU, and remove the `optirun` if you don't have hybrid graphics.

### `main.cpp`

This is just a ton of setup for OpenGL. It should be modified very little, if at all. It is lightly modified from [a CUDA sample](https://github.com/NVIDIA/cuda-samples/blob/master/Samples/0_Introduction/simpleCUDA2GL/main.cpp).

### `simpleCUDA2GL.cu`

This contains the actual raytracer and a bit of pixel drawing code. It has a handful of utility functions (`clamp`, `rgbToInt`, etc.). It contains the actual raytracer, and then `cudaProcess`, which is what draws the pixels. In `cudaProcess`, we call the raytracer, and we have a few functions to move the camera as well.

### `simpleCUDA2GL.h`

A header file for the raytracer. We define a handful of things here.
