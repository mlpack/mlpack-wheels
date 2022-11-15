pipeline
{
  // Only run on systems where we know we can build wheels already.
  agent { label 'wheel-builder' }

  environment
  {
    MLPACK_VERSION = '4.0.0'
  }

  // We assume that the wheel-builder system already has cibuildwheel, twine,
  // and other dependencies installed and up-to-date.

  stages
  {
    stage('Checkout and configure Python bindings')
    {
      steps
      {
        sh '''
          git clone https://github.com/mlpack/mlpack
          pwd
          cd mlpack/
          git checkout $MLPACK_VERSION
          mkdir build/
          cd build/
          cmake -DBUILD_PYTHON_BINDINGS=ON ../
          make python_configured
        '''
      }
    }

    stage('Run cibuildwheel')
    {
      matrix
      {
        agent { label 'wheel-builder' }
        axes
        {
          axis
          {
            name 'PYTHON_VERSION'
            values 'cp36', 'cp37', 'cp38', 'cp39', 'cp310', 'cp311', 'pp37',
                   'pp38', 'pp39'
          }

          axis
          {
            name 'ARCH'
            values 'x86_64', 'i686', 'aarch64', 's390x', 'ppc64le'
          }

          axis
          {
            name 'PYTHON_IMAGE'
            values 'manylinux', 'musllinux'
          }
        }

        excludes
        {
          // s390x has a numpy build failure: "error: 'HWCAP_S390_VX'
          // undeclared".
          exclude
          {
            axis
            {
              name 'ARCH'
              values 's390x'
            }
          }

          // The pp* targets are not available with musllinux.
          exclude
          {
            axis
            {
              name 'PYTHON_VERSION'
              values 'pp37', 'pp38', 'pp39'
            }

            axis
            {
              name 'PYTHON_IMAGE'
              values 'musllinux'
            }
          }
        }

        stages
        {
          stage('Run cibuildwheel')
          {
            steps
            {
              sh '''
                # Set environment variables properly.
                if [ \"${PYTHON_IMAGE}\" == \"manylinux\" ];
                then
                  export CIBW_BEFORE_BUILD="./build_mlpack.sh"
                else
                  export CIBW_BEFORE_BUILD="./build_mlpack.musl.sh"
                fi

                export CIBW_ARCHS_LINUX="${ARCH}"
                pwd
                ls
                ls mlpack/
                ls mlpack/build/
                cibuildwheel --output-dir wheelhouse mlpack/build/src/mlpack/bindings/python/
              '''
            }

            post
            {
              always
              {
                archiveArtifacts 'wheelhouse/*.whl'
              }
            }
          }
        }
      }
    }
  }
}
