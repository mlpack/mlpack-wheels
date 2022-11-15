#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

yum install -y openblas-devel armadillo-devel cereal-devel ensmallen-devel
pip install cython numpy pandas

# STB must be installed by hand.
wget https://www.mlpack.org/files/stb.tar.gz
tar -xvzpf stb.tar.gz
rm -f stb.tar.gz

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
cd build/
rm -rf *
cmake \
    -DBUILD_PYTHON_BINDINGS=ON \
    -DBUILD_CLI_EXECUTABLES=OFF \
    -DSTB_IMAGE_INCLUDE_DIR=../../stb/include/ \
    ../
make
