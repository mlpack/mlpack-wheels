#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel musllinux environment.
# Note that this script is not currently used, because the musllinux builds seem
# to get OOM-killed.

# Enable the community repository.
apk add openblas-dev
pip install cython numpy pandas

# Armadillo must be built by hand.
wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo-11.4.1/
cmake -DCMAKE_INSTALL_PREFIX=/usr -DOPENBLAS_PROVIDES_LAPACK=true .
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
cmake -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr ../
make install
cd ../../
rm -rf ensmallen-2.19.0 ensmallen-2.19.0.tar.gz

wget https://www.mlpack.org/files/stb.tar.gz
tar -xvzpf stb.tar.gz
cp stb/include/*.h /usr/include/
rm -rf stb/ stb.tar.gz

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
cd build/
rm -rf *
cmake -DBUILD_PYTHON_BINDINGS=ON -DBUILD_CLI_EXECUTABLES=OFF ../
make -j$NUM_CORES
