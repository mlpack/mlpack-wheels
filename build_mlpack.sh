#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

ls

mkdir build
cd build
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make
