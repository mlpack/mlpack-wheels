# Custom functionality for multibuilds.

function pre_build
{
  # We need to get mlpack dependencies.  We are root inside the container, and
  # this is RHEL5.
  yum install -y wget make gcc-c++ boost-devel openblas

  # Ha, because RHEL5 is so old we have to build CMake from source.  But we have
  # to use an older CMake version because new CMake versions don't build right.
  wget http://www.ratml.org/misc/cmake-3.13.5.tar.gz
  tar -xzpf cmake-3.13.5.tar.gz
  cd cmake-3.13.5/
  ./configure
  gmake -j4
  make install
  cd ../

  # Now download Armadillo and install that from a known non-HTTPS source
  # (because we don't have working HTTPS).
  wget http://www.ratml.org/misc/armadillo-9.400.4.tar.gz
  tar -xzpf armadillo-9.400.4.tar.gz
  cd armadillo-9.400.4
  cmake .
  make
  cd ../

  # We also need to download boost.
  wget http://www.ratml.org/misc/boost_1_70_0.tar.gz
  tar -xzpf boost_1_70_0.tar.gz
  cd boost_1_70_0/
  ./bootstrap.sh --with-libraries=serialization,program_options,test
  ./b2 -j4 install
  cd ../

  # Finally let's go ahead and build mlpack.
  cd mlpack/
  mkdir build
  cd build/
  cmake \
      -DARMADILLO_INCLUDE_DIR=../../armadillo-9.400.4/tmp/include/ \
      -DARMADILLO_LIBRARY=../../armadillo-9.400.4/libarmadillo.so \
      -DPYTHON=/opt/python/cp27-cp27m \
      ../
  make -j2 python
  cd src/mlpack/bindings/python/

  # Maybe just leaving it in this directory is ok?
}

function run_test
{
  # I also have no idea what we should do here yet...
  python --version
}
