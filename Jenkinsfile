pipeline
{
  // Only run on systems where we know we can build wheels already.
  agent { label 'wheel-builder' }

  environment
  {
    MLPACK_VERSION = '4.6.2'
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
          python3 -m venv venv/
          . venv/bin/activate
          pip3 install numpy pandas cython setuptools wheel twine cibuildwheel

          git clone https://github.com/mlpack/mlpack
          cd mlpack/
          git checkout $MLPACK_VERSION

          mkdir build/
          cd build/
          cmake -DBUILD_PYTHON_BINDINGS=ON ../
          make python_configured
        '''
        stash includes: 'mlpack/**', name: 'mlpack-configured'
        stash includes: 'venv/**', name: 'venv'
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
            values 'cp38', 'cp39', 'cp310', 'cp311', 'cp312', 'cp313',
                   'pp37', 'pp38', 'pp39'
          }

          axis
          {
            name 'ARCH'
            values 'x86_64', 'i686'
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
              unstash 'mlpack-configured'
              unstash 'venv'

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
                . venv/bin/activate
                cibuildwheel --output-dir wheelhouse mlpack/build/src/mlpack/bindings/python/
              '''
            }

            post
            {
              always
              {
                archiveArtifacts 'wheelhouse/*.whl'

                unstash 'venv'

                sh '''
                  . venv/bin/activate
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
