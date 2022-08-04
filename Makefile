HEADER_FILES=$(wildcard *.h)
SOURCE_FILES=$(wildcard *.cu *.cpp)
BIN_FOLDER=bin
MAIN_EXECUTABLE=main

all: $(BIN_FOLDER)/$(MAIN_EXECUTABLE)

$(BIN_FOLDER)/$(MAIN_EXECUTABLE): $(SOURCE_FILES) $(HEADER_FILES) Makefile
	mkdir -pv $(BIN_FOLDER)
	nvcc $(SOURCE_FILES) -I./Common -lGL -lGLU -lglut -arch native -o $(BIN_FOLDER)/$(MAIN_EXECUTABLE)

.PHONY:
clean:
	rm -rv $(BIN_FOLDER)
