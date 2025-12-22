## Build

```shell
mise trust

cmake --version # See note below...
 # On mac, the cmake command will fail. You need to see the error and cancel. Then go to Settings > Privacy and Security.  Scroll to the bottom ans allow cmake to open.

conan profile detect --force
#conan install . --output-folder=build --build=missing

# These don't work yet, but we want them to...
conan create . --build=missing -s compiler=clang -s compiler.version=21 -s compiler.libcxx=libc++ -s compiler.cppstd=20

cmake --preset Debug
cmake --build --preset Debug
build/Debug/MyApp
```