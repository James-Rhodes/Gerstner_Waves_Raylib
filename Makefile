# Note: can change the version of cpp and also the optimisation levels below (O0 being no optimisation and O3 being the most)

SRC_FILES := $(wildcard ./*.cpp)
CPP_VERSION = -std=c++17
BUILD_MODE ?= RELEASE

ifeq ($(BUILD_MODE),DEBUG)
    OPTIMISE_FLAG = -g -O0
else
    OPTIMISE_FLAG = -s -O1
endif

default:
	g++ $(SRC_FILES) -o output.exe $(OPTIMISE_FLAG) $(CPP_VERSION) -Wall -static-libstdc++ -Wno-missing-braces -I ./include/ -L ./lib/ -lraylib -lopengl32 -lgdi32 -lwinmm