#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

sudo apt-get install libopenblas-dev libarmadillo-dev libcereal-dev libensmallen-dev

cd mlpack/build/
rm -rf *
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make
