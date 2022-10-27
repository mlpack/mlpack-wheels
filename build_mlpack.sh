#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

yum install openblas-devel armadillo-devel cereal-devel ensmallen-devel

cd mlpack/build/
rm -rf *
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make
