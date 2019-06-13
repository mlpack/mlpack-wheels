#!/bin/bash
#
# Build mlpack wheels in Jenkins.

export BUILD_COMMIT=mlpack-3.1.1
export BUILD_DEPENDS="Cython numpy pandas"
export TEST_DEPENDS="Cython numpy pandas" # Not sure, but probably ok.
export PLAT=x86_64
export UNICODE_WIDTH=32
export WHEELHOUSE_UPLOADER_USERNAME=mlpack-travis-worker

# This will have to be part of the build matrix configuration.
export MB_PYTHON_VERSION=2.7
export UNICODE_WIDTH=16

# before_install:
source multibuild/common_utils.sh
source multibuild/travis_steps.sh
before_install

# install:
clean_code mlpack $BUILD_COMMIT
build_wheel /io/mlpack/build/src/mlpack/bindings/python $PLAT
# We have direct access to the workspace.
#  - curl --upload-file wheelhouse/mlpack-3.1.1-cp27-cp27m-manylinux1_x86_64.whl https://transfer.sh/mlpack-wheel-test.whl

# script:
install_run $PLAT

# after_success:
echo "hooray!"
