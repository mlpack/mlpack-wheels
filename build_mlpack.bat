pip install cython numpy pandas

echo "cd at start"
echo "%cd%"
set rootdir=%cd%

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
patch -p1 < ../static-binding-linking.patch
rmdir /s /q build
mkdir build
cd build/

mkdir Release
cp ..\..\OpenBLAS-0.3.21\bin\libopenblas.dll Release/

cmake -G "Visual Studio 16 2019" ^
    -DBLAS_LIBRARIES:FILEPATH="%rootdir%\OpenBLAS-0.3.21\lib\libopenblas.lib" ^
    -DLAPACK_LIBRARIES:FILEPATH="%rootdir%\OpenBLAS-0.3.21\lib\libopenblas.lib" ^
    -DARMADILLO_INCLUDE_DIR="%rootdir%\armadillo-11.4.1\tmp\include" ^
    -DARMADILLO_LIBRARY="%rootdir%\armadillo-11.4.1\Release\armadillo.lib" ^
    -DCEREAL_INCLUDE_DIR="%rootdir%\cereal-1.3.2\include" ^
    -DENSMALLEN_INCLUDE_DIR="%rootdir%\ensmallen-2.19.0\include" ^
    -DBUILD_CLI_EXECUTABLES=OFF ^
    -DBUILD_JULIA_BINDINGS=OFF ^
    -DBUILD_PYTHON_BINDINGS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target python --config Release -- -verbosity:detailed
