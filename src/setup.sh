#!/bin/bash

#
# This is a simple script to
# generate a versitale C/C++
# project  structure with  a
# makefile to  work  with VS
# code.
#

if test "$#" -ne 2; then
  echo
  echo "ERROR: Correct usage should be:"
  echo
  echo "       setup <project name>"
  echo "             <directory>"
  echo

  exit
fi

echo
echo "VS-Code C/C++ project template generator V1.0"
echo
echo "Generating project \"${1}\" in directory \"${2}\""

cd ${2}

mkdir ${1}
cd ${1}

mkdir .vscode

mkdir build
mkdir include
mkdir src

echo "Generated folder structure"

touch src/main.cpp
cat > src/main.cpp << "EOF1"
#include <iostream>
#include <vector>
#include <string>

int main(){
    std::vector<std::string> message{"Hello", " ", "world", " ", "!", "\n"};
    
    for(const std::string& word : message){
        std::cout << word;
    }

    return 0;
}
EOF1

echo "Generated main.cpp"

touch makefile
cat > makefile << "EOF2"
#
# Simple and versatile makefile 
# for C/C++ projects. Configure 
# with the following variables:
#

CXX      := -c++
CXXFLAGS := -pedantic-errors -Wall -Wextra -Werror
LDFLAGS  := -L/usr/lib -lstdc++ -lm

BUILD    := ./build
OBJ_DIR  := $(BUILD)
BIN_DIR  := $(BUILD)/bin

TARGET   := PROJECTNAME
INCLUDE  := -Iinclude/

SRC      := $(shell find src/ -name "*.cpp")
OBJECTS  := $(SRC:%.cpp=$(OBJ_DIR)/%.o)

#
# Available make options:
# - make all
# - make clean
# - make program
# - make build
# - make release
# - make debug
#

all: build $(BIN_DIR)/$(TARGET)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@ $(LDFLAGS)

$(BIN_DIR)/$(TARGET): $(OBJECTS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -o $(BIN_DIR)/$(TARGET) $^ $(LDFLAGS)

.PHONY: all build clean debug release

build:
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(OBJ_DIR)

#
# Configure release and
# debug configuration
# here:
#

debug: CXXFLAGS += -DDEBUG -g
debug: all

release: CXXFLAGS += -O2
release: all

clean:
	-@rm -rvf $(BUILD)/*
EOF2

sed -i -e "s/PROJECTNAME/${1}/g" makefile
echo "Generated makefile"

touch .vscode/tasks.json
cat > .vscode/tasks.json << "EOF3"
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "release",
            "type": "shell",
            "command": "make clean release",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "debug",
            "type": "shell",
            "command": "make clean debug",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "run",
            "type": "shell",
            "command": "./build/bin/PROJECTNAME",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "clean",
            "type": "shell",
            "command": "make clean",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "launch - release",
            "dependsOn": ["release", "run"]
        }
    ]
}
EOF3

sed -i -e "s/PROJECTNAME/${1}/g" .vscode/tasks.json
echo "Generated custom build tasks"
echo

echo "ALL DONE."
echo

code .