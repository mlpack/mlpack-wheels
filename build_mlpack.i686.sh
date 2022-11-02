#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment for an i686
# package.

# RHEL7 on i686 does not have openblas-devel; so, we use atlas-devel instead.
yum install -y atlas-devel armadillo-devel cereal-devel ensmallen-devel
pip install cython numpy pandas

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
cd build/
rm -rf *
cmake -DBUILD_PYTHON_BINDINGS=ON ../
make -j4
