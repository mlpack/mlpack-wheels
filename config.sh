# Custom functionality for multibuilds.

function pre_build
{
  # We need to get mlpack dependencies.
  sudo apt-get install libboost-all-dev libarmadillo-dev cmake make g++ doxygen

  # Let's go ahead and build mlpack.
  cd mlpack/
  mkdir build
  cd build/
  cmake ../
  make -j2 python
  cd src/mlpack/bindings/python/

  # Maybe just leaving it in this directory is ok?
}

function run_test
{
  # I also have no idea what we should do here yet...
  python --version
}
