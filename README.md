# CUDA + OpenGL Rayracer

This is [my original raytracer](https://github.com/coconutmacaroon/raytracer), but re-written in CUDA with OpenGL instead of Java. This is _significantly_ faster. The Java version takes up to several seconds to render one frame (on my machine, at 1024x1024). In contrast, this version can do around 40FPS (again, at 1024x1024 on my machine).

## Compiling

I'm assuming you've cloned the repo and are in the main directory. To build it, just run `make`, and to run it, do `./bin/main`. If you have hybrid graphics, you may need to run it with `optirun ./bin/main` (`optirun` is from [Bumblebee](https://wiki.archlinux.org/title/Bumblebee)).

## Explanation of code files

### `go.sh`

This is a simple file that build and runs it. If you use it, remember to change the `61` to the compute capability of your GPU, and remove the `optirun` if you don't have hybrid graphics.

### `main.cpp`

This is just a ton of setup for OpenGL. It should be modified very little, if at all. It is lightly modified from [a CUDA sample](https://github.com/NVIDIA/cuda-samples/blob/master/Samples/0_Introduction/simpleCUDA2GL/main.cpp).

### `simpleCUDA2GL.cu`

This contains the actual raytracer and a bit of pixel drawing code. It has a handful of utility functions (`clamp`, `rgbToInt`, etc.). It contains the actual raytracer, and then `cudaProcess`, which is what draws the pixels. In `cudaProcess`, we call the raytracer, and we have a few functions to move the camera as well.

### `simpleCUDA2GL.h`

A header file for the raytracer. We define a handful of things here.

-----

The `CUDA_LICENSE` file is for the portion of the codebase that uses code from the NVIDIA CUDA samples. Specifically, this is all files within the `Common` directory, the `CUDA_LICENSE` file, the `findgllib.mk` file, most of the `main.cpp` file, the two `clamp` functions, the `rgbToInt` function, the `launch_cudaProcess` function, and part of the `ccudaProcess` fucntion in `simpleCUDA2GL.cu`.
