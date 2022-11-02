#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel musllinux environment.

apk add openblas-dev armadillo-dev cereal
pip install cython numpy pandas

# ensmallen must be built by hand.
wget https://www.ensmallen.org/files/ensmallen-latest.tar.gz
tar -xvzpf ensmallen-latest.tar.gz
cd ensmallen*/
cmake -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr ../
make install
cd ../
rm -rf ensmallen*

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
cd build/
rm -rf *
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make -j4
