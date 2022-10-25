## mlpack-wheels

This repository contains CI scripts that use the [cibuildwheel
project](https://github.com/pypa/cibuildwheel) to build compiled wheels for
upload to PyPI, for a variety of Python versions, operating systems, and
architectures.

In general, this repository does not need to be touched except for when there is
a release; and then, only the environment variables in .ci/ci.yaml will need to
be updated.
