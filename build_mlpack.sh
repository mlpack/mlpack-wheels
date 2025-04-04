#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

set -e -u -o pipefail

yum install -y openblas-devel armadillo-devel cereal-devel ensmallen-devel wget
pip install cython numpy pandas wheel setuptools

cd mlpack/
rm -rf build/
mkdir build/
cd build/
cmake \
    -DBUILD_PYTHON_BINDINGS=ON \
    -DBUILD_CLI_EXECUTABLES=OFF \
    -DSTB_IMAGE_INCLUDE_DIR="$PWD/../../stb/include/" \
    ../
make
