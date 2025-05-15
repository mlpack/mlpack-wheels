#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment for an i686
# package.

set -e -u -o pipefail

# RHEL7 on i686 does not have openblas-devel; so, we use atlas-devel instead.
# Armadillo and ensmallen must both be installed by hand.
yum install -y atlas-devel lapack-devel wget
pip install cython numpy pandas wheel setuptools

wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo-11.4.1/
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .
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
cmake -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_TESTS=OFF -DDEBUG=ON ../
make
make install
cd ../../
rm -rf ensmallen-2.19.0/ ensmallen-2.19.0.tar.gz

wget https://www.mlpack.org/files/stb.tar.gz
tar -xvzpf stb.tar.gz
rm -f stb.tar.gz

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
