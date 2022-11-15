rem Build mlpack's Python bindings on a Windows system.

pip install cython numpy pandas delvewheel

rem This is needed later for copying libopenblas.dll to the right place.
set rootdir=%cd%

rem Patch the code, clean any old build directory.
cd mlpack/
patch -p1 < ../reduce-lib-size.patch
patch -p1 < ../static-binding-linking.patch
rmdir /s /q build
mkdir build
cd build/

rem Configure CMake and build the Python bindings.
cmake -G "%VS_GENERATOR%" ^
    -A %WIN_ARCH% ^
    -DBLAS_LIBRARIES:FILEPATH="%OPENBLAS_LIB%" ^
    -DLAPACK_LIBRARIES:FILEPATH="%OPENBLAS_LIB%" ^
    -DARMADILLO_INCLUDE_DIR="%rootdir%\armadillo-11.4.1\tmp\include" ^
    -DARMADILLO_LIBRARY="%rootdir%\armadillo-11.4.1\Release\armadillo.lib" ^
    -DCEREAL_INCLUDE_DIR="%rootdir%\cereal-1.3.2\include" ^
    -DENSMALLEN_INCLUDE_DIR="%rootdir%\ensmallen-2.19.0\include" ^
    -DSTB_IMAGE_INCLUDE_DIR="%rootdir%\stb\include" ^
    -DBUILD_CLI_EXECUTABLES=OFF ^
    -DBUILD_JULIA_BINDINGS=OFF ^
    -DBUILD_PYTHON_BINDINGS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target python --config Release -- -verbosity:detailed

rem The tests cannot be run correctly by cibuildwheel because libopenblas.dll
rem must be in the right directory; so, we copy libopenblas.dll to the right
rem place and manually run a simple test here to ensure that everything is
rem working.
cd src\mlpack\bindings\python
cp %OPENBLAS_DLL% .

rem Debugging information...
dir mlpack\
dumpbin mlpack\*.pyd

set PYTHONPATH=%PYTHONPATH%;%rootdir%\mlpack\build\src\mlpack\bindings\python
python -c "import mlpack; import numpy as np; x = np.random.rand(100, 10); o = mlpack.pca(input_=x, new_dimensionality=5, verbose=True)"
