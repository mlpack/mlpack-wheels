#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

cd mlpack/build/
rm -rf *
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make
