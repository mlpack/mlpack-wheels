#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

yum install -y openblas-devel armadillo-devel cereal-devel ensmallen-devel
pip install cython numpy pandas

cd mlpack/build/
rm -rf *
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make
