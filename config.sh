# Custom functionality for multibuilds.

function pre_build
{
  # Do the mlpack build so the Python package is ready before the multibuild
  # starts.

  # We need to get mlpack dependencies.  We are root inside the container, and
  # this is RHEL5.
  yum install -y wget make gcc-c++ openblas-devel

  # Install RPMs that were manually made for this image.
  wget http://www.ratml.org/misc/cmake-3.13.5-1.x86_64.rpm
  rpm -ivh cmake-3.13.5-1.x86_64.rpm
  wget http://www.ratml.org/misc/armadillo-9.400.4-1.x86_64.rpm
  rpm -ivh armadillo-9.400.4-1.x86_64.rpm
  wget http://www.ratml.org/misc/boost-1.70.0-1.x86_64.rpm
  rpm -ivh boost-1.70.0-1.x86_64.rpm

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

function run_tests
{
  # Let's just make sure mlpack loads.  TODO: maybe run the tests.
  python --version
  python -c 'import sys; import mlpack;'
}
