

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

```shell
#-------------
# Install...
#-------------
bin/setup.sh --chrome=144.0.7559.31 --emsdk=4.0.22

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
./build/Debug/MyApp

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

# Ubuntu

```shell

<i>Not yet supported.</i>

#--------------------------
# Install Pre-requisites
#--------------------------
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

#--------------------------
# Build
#--------------------------
cmake --preset Debug
cmake --build --preset Debug
```




```

```