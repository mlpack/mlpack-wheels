#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

yum install -y openblas-devel armadillo-devel cereal-devel ensmallen-devel wget
pip install cython numpy pandas

# STB must be installed by hand.
wget https://www.mlpack.org/files/stb.tar.gz
tar -xvzpf stb.tar.gz
rm -f stb.tar.gz

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
rm -rf build/
mkdir build/
cd build/
cmake \
    -DBUILD_PYTHON_BINDINGS=ON \
    -DBUILD_CLI_EXECUTABLES=OFF \
    -DSTB_IMAGE_INCLUDE_DIR=../../stb/include/ \
    ../
make
