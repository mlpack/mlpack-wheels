# Custom functionality for multibuilds.

function pre_build
{
  # Do the mlpack build so the Python package is ready before the multibuild
  # starts.

  # We need to get mlpack dependencies.  We are root inside the container, and
  # this is RHEL5.
  yum install -y wget make gcc-c++ openblas

  # We need to get our Python dependencies using the desired pip version.
  # (hardcoded for now)
  /opt/python/cp27-cp27m/bin/pip install Cython numpy pandas

  # Ha, because RHEL5 is so old we have to build CMake from source.  But we have
  # to use an older CMake version because new CMake versions don't build right.
  wget http://www.ratml.org/misc/cmake-3.13.5.tar.gz
  tar -xzpf cmake-3.13.5.tar.gz
  cd cmake-3.13.5/
  ./configure --prefix=/usr
  gmake -j4
  make install
  cd ../

  # Now download Armadillo and install that from a known non-HTTPS source
  # (because we don't have working HTTPS).
  wget http://www.ratml.org/misc/armadillo-9.400.4.tar.gz
  tar -xzpf armadillo-9.400.4.tar.gz
  cd armadillo-9.400.4
  cmake -DCMAKE_INSTALL_PREFIX=/usr .
  make install
  cd ../

  # We also need to download boost.
  wget http://www.ratml.org/misc/boost_1_70_0.tar.gz
  tar -xzpf boost_1_70_0.tar.gz
  cd boost_1_70_0/
  ./bootstrap.sh --with-libraries=serialization,program_options,test
  ./b2 -j4 install --prefix=/usr
  cd ../

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
  # Let's just make sure mlpack loads.  TODO: maybe run the tests?
  python --version
#  python -c 'import sys; import mlpack;'
}
