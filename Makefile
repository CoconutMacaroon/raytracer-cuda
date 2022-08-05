HEADER_FILES=$(wildcard *.h)
SOURCE_FILES=$(wildcard *.cu *.cpp)
BIN_FOLDER=bin
MAIN_EXECUTABLE=main
SPHERE_GENERATOR=genSpheres.py

all: $(BIN_FOLDER)/$(MAIN_EXECUTABLE)

spheres: $(SPHERE_GENERATOR)
	/usr/bin/env python3 $(SPHERE_GENERATOR) > spheres

$(BIN_FOLDER)/$(MAIN_EXECUTABLE): $(SOURCE_FILES) $(HEADER_FILES) spheres Makefile
	mkdir -pv $(BIN_FOLDER)
	nvcc $(SOURCE_FILES) -I./Common -lGL -lGLU -lglut -arch native -o $(BIN_FOLDER)/$(MAIN_EXECUTABLE)

.PHONY:
clean:
	rm -rv $(BIN_FOLDER) spheres
