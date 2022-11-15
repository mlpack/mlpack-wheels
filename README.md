## mlpack-wheels

This repository contains CI scripts that use the [cibuildwheel
project](https://github.com/pypa/cibuildwheel) to build compiled wheels for
upload to PyPI, for a variety of Python versions, operating systems, and
architectures.

In general, this repository does not need to be touched except for when there is
a release; and then, only the environment variables in .ci/ci.yaml will need to
be updated.

### Configuration

We use Jenkins, Azure Pipelines, and Github Actions to build all the different
configurations that cibuildwheel supports.  Whether it is advisable to use three
different services is a question that it is not preferred to ask, for that ship
has already sailed.

The Jenkins configuration is specified in `Jenkinsfile`, and defines all the
Linux jobs, along three axes: architecture, Python environment, and Python
version.

The entrypoint for Azure Pipelines is `azure-pipelines.yml`, and this has two
sets of jobs:

 * OS X: builds wheels for `x86_64` and `arm64`

 * Windows: builds wheels for `amd64` and `win32`

Github Actions is used for the Windows ARM64 build; however, that build is
currently disabled, since a suitable LAPACK implementation is not available in
`vcpkg`.
