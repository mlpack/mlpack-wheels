#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment for an i686
# package.

# RHEL7 on i686 does not have openblas-devel; so, we use atlas-devel instead.
# Armadillo and ensmallen must both be installed by hand.
yum install -y atlas-devel wget
pip install cython numpy pandas

wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo-11.4.1/
cmake -DCMAKE_INSTALL_PREFIX=/usr .
make
make install
cd ../
rm -rf armadillo-11.4.1/ armadillo-11.4.1.tar.gz

# cereal must be installed by hand.
wget https://github.com/USCILab/cereal/archive/refs/tags/v1.3.2.tar.gz
tar -xvzpf v1.3.2.tar.gz
cd cereal-1.3.2/
cp -vr include/* /usr/include/
cd ../
rm -rf cereal-1.3.2 v1.3.2.tar.gz

wget https://www.ensmallen.org/files/ensmallen-2.19.0.tar.gz
tar -xvzpf ensmallen-2.19.0.tar.gz
cd ensmallen-2.19.0/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_TESTS=OFF ../
make
make install
cd ../../
rm -rf ensmallen-2.19.0/ ensmallen-2.19.0.tar.gz

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
rm -rf build/
mkdir build/
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make -j4
