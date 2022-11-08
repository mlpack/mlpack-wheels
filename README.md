## mlpack-wheels

This repository contains CI scripts that use the [cibuildwheel
project](https://github.com/pypa/cibuildwheel) to build compiled wheels for
upload to PyPI, for a variety of Python versions, operating systems, and
architectures.

In general, this repository does not need to be touched except for when there is
a release; and then, only the environment variables in .ci/ci.yaml will need to
be updated.

### Configuration

We use both Azure Pipelines and Github Actions to build all the different
configurations that cibuildwheel supports.  Whether it is advisable to use two
different services is a question that it is not preferred to ask, for that ship
has already sailed.

The entrypoint for Azure Pipelines is `azure-pipelines.yml`, and this has three
sets of jobs:

 * Linux: builds wheels for `manylinux` and `musllinux` for `x86_64` and `i686`
   platforms

 * OS X: builds wheels for `x86_64` and `arm64`

 * Windows: builds wheels for `amd64` and `win32`

Github Actions is used for cross-compiled builds.  Its entrypoint is
`.github/workflows/build.yml`, and it builds two sets of jobs:

 * Linux: builds wheels for `manylinux` and `musllinux` for `aarch64` and
   `ppc64le` platforms

 * Windows: builds wheels for `ARM64` platform
