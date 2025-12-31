
- [building dawn](https://dawn.googlesource.com/dawn/+/HEAD/docs/building.md)
- [dawn quickstart cmake](https://github.com/google/dawn/blob/main/docs/quickstart-cmake.md)
- [windows build instructions](https://chromium.googlesource.com/chromium/src/+/HEAD/docs/windows_build_instructions.md)


# Web

<i>Instructions are for macOS; they will need to be adapted to work on Linux and Windows.</i>

```shell
#--------------------------
# Install Pre-requisites
#--------------------------
#bin/setup.sh --chrome=143.0.7499.170 --emsdk=4.0.22
bin/setup.sh --chrome=144.0.7559.31 --emsdk=4.0.22

# To show to versions of chrome and emsdk
bin/setup.sh --chrome-channel=stable
bin/setup.sh --chrome-channel=beta
```

```shell
#--------------------------
# Build
#--------------------------
cmake --preset wasm
cmake --build --preset wasm
npx http-server build/wasm/www
```

# Mac

### Setup

```shell
curl https://mise.run | sh # mise
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # Homebrew
brew install llvm node

#-------------
# Configure
#-------------
mise trust

# IMPORTANT!  Enable
# System Settings > Privacy & Security > Developer Tools
# Add Terminal or iTerm or Ghosty here and enable

# On mac, the cmake command will fail. You need to see the error and cancel
# Then go to Settings > Privacy and Security.  Scroll to the bottom and allow
# cmake to open.
cmake --version # See note above

conan profile detect --force
```

### Build
```shell
# Run once
bin/setup.sh --chrome=144.0.7559.31 --emsdk=4.0.22
cmake --preset Debug
# change/build/run
cmake --build --preset Debug
./build/Debug/MyApp
#conan install . --output-folder=build --build=missing
# These don't work yet, but we want them to...
#conan create . --build=missing -s compiler=clang -s compiler.version=21 -s compiler.libcxx=libc++ -s compiler.cppstd=20
```

# Windows

### Install Pre-Requisites
```shell
winget install python
winget install Git.Git --source winget
winget install --id Ninja-build.Ninja --source winget
winget install --id Microsoft.VisualStudio.2022.Community --exact --override "--wait --passive --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.VC.ATLMFC --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 --add Microsoft.VisualStudio.Component.VC.MFC.ARM64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100 --includeRecommended" --source winget
```

### Optional
```shell
winget install Microsoft.VisualStudioCode --source winget
winget install GoLang.Go --source winget
winget install Kitware.CMake --source winget
winget install Microsoft.PowerShell --source winget
winget install jdx.mise --source winget
winget install LLVM.LLVM --source winget # 21.1.8
```

### Install dawn

<i>You need to make sure you run this from one of the "Native Tools Command Prompt for VS".  If you don't, you will have struggles getting dawn to download and compile.</i>

```shell
bin/setup.cmd
# git init dawn
# cd dawn
# git remote add origin https://dawn.googlesource.com/dawn
# git fetch --depth 1 origin 9bd45159352393f34bf70b4558d1ce75c2b1a574
# git checkout FETCH_HEAD
# python tools/fetch_dawn_dependencies.py

# cmake -S . -B out/Release -DDAWN_FETCH_DEPENDENCIES=ON -DDAWN_ENABLE_INSTALL=ON -DCMAKE_BUILD_TYPE=Release   -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF
# cmake --build out/Release --config Release --verbose
#cmake --install out/Release --prefix install/Release


# chatgpt ninja
# rmdir /s /q out
# rmdir /s /q install
# cmake -S . -B out -G "Ninja Multi-Config" `
#   -DDAWN_FETCH_DEPENDENCIES=ON `
#   -DDAWN_ENABLE_INSTALL=ON
# cmake --build out --config Release
# cmake --install out --config Release --prefix install/Release
```

### Build
```shell
#--------------------------
# Build
#--------------------------
# $env:PATH = "$env:LOCALAPPDATA\mise\shim;$env:PATH"
# mise activate pwsh | Out-String | Invoke-Expression

bin\setup.cmd
cmake --preset win64
cmake --build --preset win64 --parallel
./build/win64/MyApp.exe

#cmake -S . -B build/win
#cmake --build build/win

#cmake -S . -B build/win -D CMAKE_BUILD_TYPE=Release -D CMAKE_MODULE_PATH=C:/projects/cpp_starter_23/build/dawn-arm64/out/lib/cmake


#cmake -S . -B build/win -D CMAKE_BUILD_TYPE=Release -D CMAKE_MODULE_PATH=C:/projects/cpp_starter_23/build/dawn-arm64/out -D Dawn_DIR=C:/projects/cpp_starter_23/build/dawn-arm64/out/lib/cmake/Dawn





#cmake --preset Debug
#cmake --build --preset Debug
#./build/Debug/MyApp.exe
```



### Build Experimenting

```shell
cmake -S . -B out -G "Ninja Multi-Config" -DDAWN_FETCH_DEPENDENCIES=ON -DDAWN_ENABLE_INSTALL=ON
cmake --build out --config Release --verbose
cmake --install out --config Release --prefix install/Release
```



### Notes

- If you do this from a network folder or a folder mapped from a virtual machine, you will need to explicitly authorize git for every folder with a git. dawn has a lot of these. for example, on Parallels if you map e: to a folder on your mac mac...

```sh
#~/.gitconifg
[safe]
  directory = E:/cpp_blockworld_webgpu/dawn
  directory = E:/cpp_blockworld_webgpu/dawn/third_party/abseil-cpp
  directory = E:/cpp_blockworld_webgpu/dawn/third_party/angle
  #...etc
```
- [build.cmd](https://github.com/mmozeiko/build-dawn/tree/main) - original source of build.cmd
- [VisualStudio Component ids](https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?view=visualstudio&viewFallbackFrom=vs-2026&preserve-view=true)

# Ubuntu

<i>Not yet supported.</i>

### Install Pre-requisites
```shell
sudo apt update
# zsh
sudo apt install zsh libc++-dev libc++abi-dev


chsh -s $(which zsh) # The logout/login
# ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# llvm 21.1
sudo apt install -y build-essential ninja-build
git clone --branch llvmorg-21.1.8 --depth 1 https://github.com/llvm/llvm-project.git
sudo mv llvm-project /opt
mkdir /opt/llvm-project/build && cd /opt/llvm-project/build
cmake -G Ninja "-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra" -DCMAKE_BUILD_TYPE=Release ../llvm
ninja # Wait an hour...
ninja install
# mise
curl https://mise.run | sh
echo "eval \"\$(/home/parallels/.local/bin/mise activate zsh)\"" >> "/home/parallels/.zshrc"
mise trust
mise install
```

### Build
```shell
cmake --preset Debug
cmake --build --preset Debug
```
