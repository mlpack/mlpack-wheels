#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

set -e -u -o pipefail

brew install --force cereal gcc cmake hdf5 tree
pip install cython numpy pandas
pip install packaging==20.5

export rootdir=`pwd`

# Armadillo must be installed by hand.
#
# If we are building for an arm64 target, then we want to disable everything
# except OpenBLAS.
wget https://files.mlpack.org/armadillo-11.4.1.tar.gz
tar -xvzpf armadillo-11.4.1.tar.gz
cd armadillo-11.4.1/
if [ "$CIBW_ARCHS_MACOS" == "x86_64" ];
then
  cmake \
    -DCMAKE_OSX_ARCHITECTURES="$CIBW_ARCHS_MACOS" \
    .
elif [ "$CIBW_ARCHS_MACOS" == "arm64" ];
then
  cmake \
    -DCMAKE_OSX_ARCHITECTURES="$CIBW_ARCHS_MACOS" \
    -DDETECT_HDF5=OFF \
    .
else
  echo "Unknown architecture \"$CIBW_ARCHS_MACOS\"!"
  exit 1
fi

make
cd ../
rm -f armadillo-11.4.1.tar.gz

# ensmallen must also be installed by hand.
wget https://www.ensmallen.org/files/ensmallen-2.19.0.tar.gz
tar -xvzpf ensmallen-2.19.0.tar.gz
rm -f ensmallen-2.19.0.tar.gz

wget https://www.mlpack.org/files/stb.tar.gz
tar -xvzpf stb.tar.gz
rm -rf stb.tar.gz

cd mlpack/
rm -rf build/
mkdir build
cd build/
# _LIBCPP_DISABLE_AVAILABILITY is required to avoid compilation errors claiming
# that any_cast is not available.
cmake \
  -DBUILD_PYTHON_BINDINGS=ON \
  -DCMAKE_OSX_ARCHITECTURES="$CIBW_ARCHS_MACOS" \
  -DCMAKE_CXX_FLAGS="-D_LIBCPP_DISABLE_AVAILABILITY" \
  -DBUILD_CLI_EXECUTABLES=OFF \
  -DARMADILLO_LIBRARY=../../armadillo-11.4.1/libarmadillo.dylib \
  -DARMADILLO_INCLUDE_DIR=../../armadillo-11.4.1/tmp/include/ \
  -DENSMALLEN_INCLUDE_DIR=../../ensmallen-2.19.0/include/ \
  -DSTB_IMAGE_INCLUDE_DIR=../../stb/include/ \
  -DCMAKE_INSTALL_PREFIX=../install \
  ../
make -j4

# If we are building for ARM64, then all generation of .pyx files will have
# failed because we cannot run any programs compiled for ARM64 (which includes
# the `generate_pyx_*` targets that make the .pyx files).  But, we have a way
# out: earlier in the build, before we started emulating, we built all the .pyx
# files and stored them off to the side.  So, we will put them back into place,
# and we will then call setup.py build_ext again to build all the Cython
# modules.
ls ../py-old/*.pyx
cat setup.py # debugging
if [ "$CIBW_ARCHS_MACOS" == "arm64" ];
then
  cp ../py-old/*.pyx src/mlpack/bindings/python/mlpack/
  cp ../py-old/*.py src/mlpack/bindings/python/mlpack/
  cd src/mlpack/bindings/python
  python setup.py build_ext
  cd ../../../..
fi

# Manually change the @rpath/libarmadillo.11.dylib to a direct reference.
# This allows delocate-wheel to know exactly where libarmadillo is.
find src/mlpack/bindings/python/ -iname '*.so' -exec \
    install_name_tool -change "@rpath/libarmadillo.11.dylib" \
                              "$rootdir/armadillo-11.4.1/libarmadillo.11.dylib" \
                              \{\} \;

# Revert to a version of packaging that is sufficient for delocate-wheel.
pip install "packaging>=20.9"
