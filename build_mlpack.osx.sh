#!/usr/bin/env bash
#
# Build mlpack's Python bindings inside the cibuildwheel environment.

set -e -u -o pipefail

brew install --force cereal gcc cmake
pip install cython numpy pandas wheel setuptools packaging

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
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_OSX_ARCHITECTURES="$CIBW_ARCHS_MACOS" \
    -DDETECT_HDF5=OFF \
    .
elif [ "$CIBW_ARCHS_MACOS" == "arm64" ];
then
  cmake \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_OSX_ARCHITECTURES="$CIBW_ARCHS_MACOS" \
    -DDETECT_HDF5=OFF \
    .
else
  echo "Unknown architecture \"$CIBW_ARCHS_MACOS\"!"
  exit 1
fi

make
sudo make install # So that libarmadillo.dylib is available in the search path.
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
  -DENSMALLEN_INCLUDE_DIR="$PWD/../../ensmallen-2.19.0/include/" \
  -DSTB_IMAGE_INCLUDE_DIR="$PWD/../../stb/include/" \
  -DCMAKE_INSTALL_PREFIX="$PWD/../install" \
  ../
make -j4

# Revert to a version of packaging that is sufficient for delocate-wheel.
pip install "packaging>=20.9"
