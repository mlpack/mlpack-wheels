#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel musllinux environment.
# Note that this script is not currently used, because the musllinux builds seem
# to get OOM-killed.

set -e -u -o pipefail

# Enable the community repository.
apk add openblas-dev
pip install cython numpy pandas wheel setuptools

# Armadillo must be built by hand.
wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo-11.4.1/
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DOPENBLAS_PROVIDES_LAPACK=true \
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

# ensmallen must be built by hand.
wget https://www.ensmallen.org/files/ensmallen-2.19.0.tar.gz
tar -xvzpf ensmallen-2.19.0.tar.gz
cd ensmallen-2.19.0/
mkdir build/
cd build/
cmake -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ../
make install
cd ../../
rm -rf ensmallen-2.19.0 ensmallen-2.19.0.tar.gz

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
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DSTB_IMAGE_INCLUDE_DIR="$PWD/../../stb/include/" \
    ../
make
