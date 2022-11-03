#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

brew install --force cereal gcc cmake ensmallen hdf5
pip install cython numpy pandas
pip install packaging==20.5

# Armadillo must be installed by hand.
wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo-11.4.1/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DOPENBLAS_PROVIDES_LAPACK=true .
make
make install
cd ../
rm -rf armadillo-11.4.1/ armadillo-11.4.1.tar.gz

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
  -DARMADILLO_LIBRARY=/usr/local/lib/libarmadillo.11.dylib
  ../
make -j4
