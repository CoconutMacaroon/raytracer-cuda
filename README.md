# CUDA + OpenGL Rayracer

This is [my original raytracer](https://github.com/coconutmacaroon/raytracer), but re-written in CUDA with OpenGL instead of Java. This is _significantly_ faster. The Java version takes up to several seconds to render one frame (on my machine, at 1024x1024). In contrast, this version can do around 40FPS (again, at 1024x1024 on my machine) with just three spheres. For 32 spheres, I get about 15 FPS at 1280x720.

## System Requirements

* NVIDIA GPU that supports CUDA - I suggest Pascal (GTX 10xx) or newer, but the 9xx series will most likely work. I got around 40 FPS on a GTX 1050 at 1024x1024 with three spheres, with 32 spheres I got about 15 FPS.
* Linux distro - I tested on Arch Linux with the proprietary NVIDA drivers (`nvidia-dkms` for me), but other distros should work fine too. The required dependencies for compiling will vary based on your distro, so I will not list the packages here. However, expect to need MESA/OpenGL, GLUT, the NVIDIA CUDA toolkit, the NVIDIA proprietary drives, and a C++ compiler (I suggest `g++`, but Clang might work too). Other packages may be required as well.

  For a number of reasons, this is not setup to run on Windows and will almost certainly need modifications to work on Windows. I have not tested WSL2 and I suggest a full distro, but WSL2 may or may not work.

## Compiling

I'm assuming you've cloned the repo and are in the main directory. To build it, just run `make`, and to run it, do `./bin/main`. If you have hybrid graphics, you may need to run it with `optirun ./bin/main` (`optirun` is from [Bumblebee](https://wiki.archlinux.org/title/Bumblebee)). Note that `make` will automatically build the executable optimized for your specific system - it may not run on other systems.

## TODO:
- [x] Multiple random spheres
- [ ] Antialiasing

## Explanation of files

### `main.cpp`

This is just a ton of setup for OpenGL. It should be modified very little, if at all. It is lightly modified from [a CUDA sample](https://github.com/NVIDIA/cuda-samples/blob/master/Samples/0_Introduction/simpleCUDA2GL/main.cpp).

### `simpleCUDA2GL.cu`

This contains the actual raytracer and a bit of pixel drawing code. It has a handful of utility functions (`clamp`, `rgbToInt`, etc.). It contains the actual raytracer, and then `cudaProcess`, which is what draws the pixels. In `cudaProcess`, we call the raytracer, and we have a few functions to move the camera as well.

### `simpleCUDA2GL.h`

A header file for the raytracer. We define a handful of things here.

### `chars.h`

Defines the character codes for some keyboard keys

### `Makefile`

A simple Makefile to compile the code with optimizations

### `genSpheres.py`

Generates the data (color, location, etc.) for the spheres that will be rendered. This is done automatically in the Makefile

#### Makefile targets:
`all` - See `$(BIN_FOLDER)/$(MAIN_EXECUTABLE)`

`$(BIN_FOLDER)/$(MAIN_EXECUTABLE)` - Compiles the code into an executable (`bin/main` by default).

`clean` - Removes the build file(s)

## Screenshots

![image](https://user-images.githubusercontent.com/45187468/182931133-a8b6f50e-6923-4ef1-8a7a-d7d9cda7c4f4.png)

![image](https://user-images.githubusercontent.com/45187468/183159694-db7c988f-bfb7-4e97-91e5-f3de55d3dea3.png)

-----

The `CUDA_LICENSE` file is for the portion of the codebase that uses code from the NVIDIA CUDA samples. Specifically, this is all files within the `Common` directory, the `CUDA_LICENSE` file, most of the `main.cpp` file, the two `clamp` functions, the `rgbToInt` function, the `launch_cudaProcess` function, and part of the `ccudaProcess` fucntion in `simpleCUDA2GL.cu`.
