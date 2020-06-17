#!/bin/bash

# MIT License
# Copyright (c) 2020 Antonio de Haro

# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in the 
# Software without restriction, including without limitation the rights to use, copy, 
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the 
# following conditions:

# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if test "$#" -ne 2; then
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
mkdir build/release
mkdir build/debug

mkdir include
mkdir src

echo "Generated folder structure"

touch src/main.cpp
cat > src/main.cpp << "EOF1"
#include <iostream>
#include <vector>
#include <string>

int main(){
    std::vector<std::string> message{"Hello", " ", "world", "!", "\n"};
    
    for(const std::string& word : message){
        std::cout << word;
    }

    return 0;
}
EOF1

echo "Generated main.cpp"

touch makefile
cat > makefile << "EOF2"
CXX      := -c++
CXXFLAGS := -pedantic-errors -Wall -Wextra -Werror -std=c++17
LDFLAGS  := -L/usr/lib -lstdc++ -lm

BUILD    := ./build
OBJ_DIR  := $(BUILD)
BIN_DIR  := $(BUILD)/bin

TARGET   := PROJECTNAME
INCLUDE  := -Iinclude/

SRC      := $(shell find src/ -name "*.cpp")
OBJECTS  := $(SRC:%.cpp=$(OBJ_DIR)/%.o)

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

debug: CXXFLAGS += -DDEBUG -g
debug: all

release: CXXFLAGS += -O2
release: all

clean:
	-@rm -rfv $(BUILD)/release/*; \
	  rm -rfv $(BUILD)/debug/*
EOF2

sed -i -e "s/PROJECTNAME/${1}/g" makefile
echo "Generated makefile"

touch .vscode/tasks.json
cat > .vscode/tasks.json << "EOF3"
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "clean",
            "type": "shell",
            "command": "make clean",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "release",
            "type": "shell",
            "command": "make release BUILD=./build/release",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "debug",
            "type": "shell",
            "command": "make debug BUILD=./build/debug",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        },
        {
            "label": "launch - release",
            "type": "shell",
            "dependsOn": ["release"],
            "command": "./build/release/bin/PROJECTNAME",
            "options": {
                "cwd": "${workspaceFolder}"
            }
        }
    ]
}
EOF3

sed -i -e "s/PROJECTNAME/${1}/g" .vscode/tasks.json
echo "Generated custom build tasks"

touch .vscode/launch.json
cat > .vscode/launch.json << "EOF4"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "launch - debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/debug/bin/PROJECTNAME",
            "args": [],
            "stopAtEntry": true,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "debug",
            "miDebuggerPath": "/usr/bin/gdb"
        }
    ]
}
EOF4

sed -i -e "s/PROJECTNAME/${1}/g" .vscode/launch.json
echo "Generated custom debug task"
echo

echo "ALL DONE."
echo

code .
