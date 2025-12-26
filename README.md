
# Mac


```shell
#-------------
# Install...
#-------------
curl https://mise.run | sh # mise
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # Homebrew
brew install llvm

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

#-------------
# Build
#-------------
cmake --preset Debug
cmake --build --preset Debug
build/Debug/MyApp

#conan install . --output-folder=build --build=missing
# These don't work yet, but we want them to...
#conan create . --build=missing -s compiler=clang -s compiler.version=21 -s compiler.libcxx=libc++ -s compiler.cppstd=20
```

# Windows

```shell
#--------------------------
# Install Pre-requisites
#--------------------------
winget install Microsoft.PowerShell --source winget
winget install jdx.mise --source winget
winget install Git.Git --source winget
winget install LLVM.LLVM --source winget # 21.1.8
winget install --id Microsoft.VisualStudio.Community --exact --override "--wait --passive --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.Windows11SDK.26100 --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64" --source winget # rc.exe
winget install Microsoft.VisualStudioCode --source winget
winget install Kitware.CMake --source winget
winget install python

# Open new powershell 7 (not system powershell)
mise trust
mise install

#--------------------------
# Build
#--------------------------
$env:PATH = "$env:LOCALAPPDATA\mise\shim;$env:PATH"
mise activate pwsh | Out-String | Invoke-Expression
cmake --preset Debug
cmake --build --preset Debug
./build/Debug/MyApp.exe
```

# Web

```shell
#--------------------------
# Install Pre-requisites
#--------------------------
git clone https://github.com/google/dawn.git libs/dawn
git clone https://github.com/emscripten-core/emsdk.git libs/emsdk
cd libs/emsdk
./emsdk install 4.0.22
./emsdk activate 4.0.22

#--------------------------
# Build
#--------------------------
source libs/emsdk/emsdk_env.sh
cmake --preset wasm
```
