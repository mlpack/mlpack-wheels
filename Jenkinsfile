pipeline
{
  // Only run on systems where we know we can build wheels already.
  agent { label 'wheel-builder' }

  environment
  {
    MLPACK_VERSION = '4.3.0'
    TWINE_PYPI_TOKEN = credentials('twine-pypi-token')
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
          cd mlpack/
          git checkout $MLPACK_VERSION

          # Apply patches.
          cp ../ConfigureFileOnly.cmake CMake/
          cp ../mlpack.pc.in src/mlpack/bindings/python/
          patch -p1 < ../python-install-headers.patch

          mkdir build/
          cd build/
          cmake -DBUILD_PYTHON_BINDINGS=ON ../
          make python_configured
        '''
        stash includes: 'mlpack/**', name: 'mlpack-configured'
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
//            values 'cp36', 'cp37', 'cp38', 'cp39', 'cp310', 'cp311', 'pp37',
//                   'pp38', 'pp39'
            values 'cp312'
          }

          axis
          {
            name 'ARCH'
            values 'x86_64', 'i686', 'aarch64', 's390x', 'ppc64le'
          }

          axis
          {
            name 'PYTHON_IMAGE'
//            values 'manylinux', 'musllinux'
            values 'manylinux'
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
              unstash 'mlpack-configured'

              // Set environment variables properly.
              script
              {
                if (env.PYTHON_IMAGE == 'musllinux')
                {
                  env.CIBW_BEFORE_BUILD = './build_mlpack.musl.sh'
                }
                else if (env.ARCH != 'x86_64' && env.ARCH != 'i686')
                {
                  env.CIBW_BEFORE_BUILD = './build_mlpack.emulated.sh'
                }
                else if (env.PYTHON_IMAGE == 'manylinux' && env.ARCH == 'x86_64')
                {
                  env.CIBW_BEFORE_BUILD = './build_mlpack.sh'
                }
                else if (env.PYTHON_IMAGE == 'manylinux' && env.ARCH == 'i686')
                {
                  env.CIBW_BEFORE_BUILD = './build_mlpack.i686.sh'
                }

                env.CIBW_ARCHS_LINUX = env.ARCH
                env.CIBW_BUILD = env.PYTHON_VERSION + '-' + env.PYTHON_IMAGE + '_' + env.ARCH
              }

              sh '''
                echo "CIBW_BUILD: $CIBW_BUILD"
                cibuildwheel --output-dir wheelhouse mlpack/build/src/mlpack/bindings/python/
              '''
            }

            post
            {
              always
              {
                archiveArtifacts 'wheelhouse/*.whl'

                sh '''
                  echo "[pypi]" > ~/.pypirc
                  echo "username = __token__" >> ~/.pypirc
                  echo "password = $TWINE_PYPI_TOKEN" >> ~/.pypirc
                  twine upload wheelhouse/*.whl
                  rm -f ~/.pypirc
                '''
              }
            }
          }
        }
      }
    }
  }
}
