#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

brew install --force cereal gcc cmake hdf5
pip install cython numpy pandas
pip install packaging==20.5

# Armadillo must be installed by hand.
wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo-11.4.1/
cmake -DOPENBLAS_PROVIDES_LAPACK=true .
make
cd ../
rm -f armadillo-11.4.1.tar.gz

# ensmallen must also be installed by hand.
wget https://www.ensmallen.org/files/ensmallen-2.19.0.tar.gz
tar -xvzpf ensmallen-2.19.0.tar.gz
rm -f ensmallen-2.19.0.tar.gz

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
cd build/
rm -rf *
# _LIBCPP_DISABLE_AVAILABILITY is required to avoid compilation errors claiming
# that any_cast is not available.
cmake \
  -DBUILD_PYTHON_BINDINGS=ON \
  -DCMAKE_CXX_FLAGS="-D_LIBCPP_DISABLE_AVAILABILITY" \
  -DBUILD_CLI_EXECUTABLES=OFF \
  -DARMADILLO_LIBRARY=../../armadillo-11.4.1/libarmadillo.dylib \
  -DARMADILLO_INCLUDE_DIR=../../armadillo-11.4.1/tmp/include/ \
  -DENSMALLEN_INCLUDE_DIR=../../ensmallen-2.19.0/include/ \
  -DCMAKE_INSTALL_PREFIX=../install/ \
  ../
make -j4
make install
ls ../install/
ls ../install/lib/
