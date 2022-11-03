#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

brew install --force armadillo cereal gcc cmake ensmallen
pip install cython numpy pandas
pip install packaging==20.5

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
cd build/
rm -rf *
# _LIBCPP_DISABLE_AVAILABILITY is required to avoid compilation errors claiming
# that any_cast is not available.
cmake -DBUILD_PYTHON_BINDINGS=ON -DCMAKE_CXX_FLAGS="-D_LIBCPP_DISABLE_AVAILABILITY -DARMA_DONT_USE_WRAPPER" ../
make -j4
