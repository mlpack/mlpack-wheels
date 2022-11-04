pip install cython numpy pandas

cd mlpack/
patch -p1 < ../reduce-lib-size.patch
rm -rf build/
mkdir build
cd build/
cmake -G "Visual Studio 16 2019" ^
    -DBLAS_LIBRARIES:FILEPATH=$(Agent.ToolsDirectory)\OpenBLAS.0.2.14.1\lib\native\lib\x64\libopenblas.dll.a ^
    -DLAPACK_LIBRARIES:FILEPATH=$(Agent.ToolsDirectory)\OpenBLAS.0.2.14.1\lib\native\lib\x64\libopenblas.dll.a ^
    -DARMADILLO_INCLUDE_DIR="..\..\armadillo-11.4.1\tmp\include" ^
    -DARMADILLO_LIBRARY="..\..\armadillo-11.4.1\Release\armadillo.lib" ^
    -DCEREAL_INCLUDE_DIR=$(Agent.ToolsDirectory)\unofficial-flayan-cereal.1.2.2\build\native\include ^
    -DENSMALLEN_INCLUDE_DIR=$(Agent.ToolsDirectory)\ensmallen.2.17.0\installed\x64-linux\include ^
    -DBUILD_CLI_EXECUTABLES=OFF ^
    -DBUILD_JULIA_BINDINGS=OFF ^
    -DBUILD_PYTHON_BINDINGS=ON ^
    -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target python --config Release
