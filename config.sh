# Custom functionality for multibuilds.
source gfortran-install/gfortran_utils.sh

function pre_build
{
  # Do the mlpack build so the Python package is ready before the multibuild
  # starts.

  # We need to get mlpack dependencies.  We are root inside the container, and
  # this is RHEL5.
  yum install -y wget make gcc-c++

  # Make sure OpenBLAS is available.  (not sure how to do LAPACK yet)
  local lib_plat=$PLAT
  if [ -n "$IS_OSX" ]; then
      install_gfortran
  fi
  build_libs $lib_plat

  # Install RPMs that were manually made for this image.
  wget http://www.ratml.org/misc/cmake-3.13.5-1.x86_64.rpm
  rpm -ivh cmake-3.13.5-1.x86_64.rpm
  wget http://www.ratml.org/misc/armadillo-9.400.4-1.x86_64.rpm
  rpm -ivh armadillo-9.400.4-1.x86_64.rpm
  wget http://www.ratml.org/misc/boost-1.70.0-1.x86_64.rpm
  rpm -ivh boost-1.70.0-1.x86_64.rpm

  # Install Python dependencies.
  /opt/python/cp27-cp27m/bin/pip install setuptools numpy pandas Cython

  # Finally let's go ahead and build mlpack.
  cd mlpack/
  mkdir build
  cd build/
  cmake \
      -DPYTHON_EXECUTABLE=/opt/python/cp27-cp27m/bin/python \
      -DBUILD_TESTS=OFF \
      -DBUILD_CLI_EXECUTABLES=OFF \
      -DBUILD_PYTHON_BINDINGS=ON \
      ../
  make -j2 python
  make install
}

function build_libs {
    local plat=${1:-$PLAT}
    local tar_path=$(abspath $(get_gf_lib "openblas-${OPENBLAS_VERSION}" "$plat"))
    # Sudo needed for macOS
    local use_sudo=""
    [ -n "$IS_OSX" ] && use_sudo="sudo"
    (cd / && $use_sudo tar zxf $tar_path)
}

function run_tests
{
  # Let's just make sure mlpack loads.  TODO: maybe run the tests.
  python --version
  python -c 'import sys; import mlpack; import numpy as np; x = np.random.rand(100, 10); o = mlpack.pca(input=x, new_dimensionality=5, verbose=True)'
}
