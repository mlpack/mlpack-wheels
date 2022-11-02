#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel musllinux environment.

# Enable the community repository.
apk add openblas-dev
pip install cython numpy pandas

# Armadillo must be built by hand.
wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo*/
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
make install
cd ../
rm -rf armadillo*/

# cereal must be installed by hand.
wget https://github.com/USCILab/cereal/archive/refs/tags/v1.3.2.tar.gz
tar -xvzpf v1.3.2.tar.gz
cd cereal*/
cp -vr include/* /usr/include/
cd ../
rm -rf cereal* v1.3.2.tar.gz

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
