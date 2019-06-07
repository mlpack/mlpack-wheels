# Custom functionality for multibuilds.

function pre_build
{
  # We need to get mlpack dependencies.  We are root inside the container, and
  # this is RHEL5.
  yum install -y wget cmake make gcc-c++ boost-devel openblas

  # Now download Armadillo and install that.
  wget http://sourceforge.net/projects/arma/files/armadillo-9.400.4.tar.xz
  tar -xvpf armadillo-9.400.4.tar.xz
  cd armadillo-9.400.4
  cmake .
  make
  cd ../

  # Finally let's go ahead and build mlpack.
  cd mlpack/
  mkdir build
  cd build/
  cmake \
      -DARMADILLO_INCLUDE_DIR=../../armadillo-9.400.4/tmp/include/ \
      -DARMADILLO_LIBRARY=../../armadillo-9.400.4/libarmadillo.so \
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
