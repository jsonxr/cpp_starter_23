@echo off
setlocal enabledelayedexpansion

rem
rem Adapted from:
rem https://github.com/mmozeiko/build-dawn/tree/main
rem

set SCRIPT_DIR=%~dp0
pushd "%SCRIPT_DIR%.." || exit /b 1
rem ensure dawn is placed beside the bin folder, regardless of invocation path

rem --------------------------------------------------------------------------
rem build architecture
rem --------------------------------------------------------------------------

set CHROME_VERSION=
if "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (
  set HOST_ARCH=x64
) else if "%PROCESSOR_ARCHITECTURE%" equ "ARM64" (
  set HOST_ARCH=arm64
)

set TARGET_ARCH=

:parse_args
if "%~1" equ "" goto args_done
set "ARG=%~1"
if /i "!ARG!" equ "x64" (
  set TARGET_ARCH=x64
) else if /i "!ARG!" equ "arm64" (
  set TARGET_ARCH=arm64
) else if /i "!ARG:~0,9!" equ "--chrome=" (
  set "CHROME_VERSION=!ARG:~9!"
) else (
  echo Unknown argument "!ARG!"
  exit /b 1
)
shift
goto parse_args
:args_done

if not defined TARGET_ARCH (
  set TARGET_ARCH=%HOST_ARCH%
)

set BUILD_DIR=build\dawn-%TARGET_ARCH%

rem --------------------------------------------------------------------------
rem dependencies
rem --------------------------------------------------------------------------

where /q git.exe    || echo ERROR: "git.exe" not found    && exit /b 1
where /q cmake.exe  || echo ERROR: "cmake.exe" not found  && exit /b 1
where /q python.exe || echo ERROR: "python.exe" not found && exit /b 1

for /f "tokens=*" %%i in ('"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.VisualStudio.Workload.NativeDesktop -property installationPath') do set VS=%%i
if "%VS%" equ "" (
  echo ERROR: Visual Studio installation not found
  exit /b 1
)

rem --------------------------------------------------------------------------
rem clone dawn
rem --------------------------------------------------------------------------
if defined CHROME_VERSION (
  echo Resolving Dawn commit for Chrome %CHROME_VERSION%
  for /f "usebackq delims=" %%i in (`
    python -c "import sys, urllib.request, base64, re; chrome=sys.argv[1]; url=f'https://chromium.googlesource.com/chromium/src.git/+/refs/tags/{chrome}/DEPS?format=TEXT'; deps_b64=urllib.request.urlopen(url).read(); deps=base64.b64decode(deps_b64).decode(); m=re.search(r'['\"']dawn_revision['\"']\s*:\s*['\"']([0-9a-f]+)['\"']', deps); print(m.group(1) if m else '')" "%CHROME_VERSION%"
  `) do set "DAWN_COMMIT=%%i"

  if "%DAWN_COMMIT%" equ "" (
    echo ERROR: Could not resolve Dawn commit for Chrome %CHROME_VERSION%
    exit /b 1
  )
)

if not exist dawn (  
  if "%DAWN_COMMIT%" equ "" (
    for /f "tokens=1 usebackq" %%F IN (`git ls-remote https://dawn.googlesource.com/dawn HEAD`) do set DAWN_COMMIT=%%F
  )

  call git init dawn                                                    || exit /b 1
  call git -C dawn remote add origin https://dawn.googlesource.com/dawn || exit /b 1
  call git -C dawn fetch --no-recurse-submodules origin %DAWN_COMMIT% || exit /b 1
  call git -C dawn reset --hard FETCH_HEAD                            || exit /b 1
  if exist dawn\third_party\dxc call git -C dawn\third_party\dxc reset --hard HEAD || exit /b 1

  rem --------------------------------------------------------------------------
  rem fetch dependencies
  rem --------------------------------------------------------------------------
  call python "dawn/tools/fetch_dawn_dependencies.py" --directory dawn
  
  rem --------------------------------------------------------------------------
  rem patches
  rem --------------------------------------------------------------------------
  rem call git apply -p1 --directory=dawn                 patches/dawn-static-dxc-lib.patch        || exit /b 1
  rem call git apply -p1 --directory=dawn/third_party/dxc patches/dxc-static-build.patch           || exit /b 1
)


rem --------------------------------------------------------------------------
rem configure dawn build
rem --------------------------------------------------------------------------
cmake.exe                                     ^
  -S dawn                                     ^
  -B %BUILD_DIR%                              ^
  -A %TARGET_ARCH%                            ^
  -D CMAKE_BUILD_TYPE=Release                 ^
  -D BUILD_SAMPLES=OFF                        ^
  -D DAWN_ENABLE_INSTALL=ON                   ^
  -D CMAKE_POLICY_DEFAULT_CMP0091=NEW         ^
  -D CMAKE_POLICY_DEFAULT_CMP0092=NEW         ^
  -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
  -D ABSL_MSVC_STATIC_RUNTIME=ON              ^
  -D DAWN_BUILD_SAMPLES=OFF                   ^
  -D DAWN_BUILD_TESTS=OFF                     ^
  -D DAWN_ENABLE_D3D12=ON                     ^
  -D DAWN_ENABLE_D3D11=OFF                    ^
  -D DAWN_ENABLE_NULL=OFF                     ^
  -D DAWN_ENABLE_DESKTOP_GL=OFF               ^
  -D DAWN_ENABLE_OPENGLES=OFF                 ^
  -D DAWN_ENABLE_VULKAN=OFF                   ^
  -D DAWN_USE_GLFW=ON                         ^
  -D DAWN_ENABLE_SPIRV_VALIDATION=OFF         ^
  -D DAWN_DXC_ENABLE_ASSERTS_IN_NDEBUG=OFF    ^
  -D DAWN_USE_BUILT_DXC=ON                    ^
  -D DAWN_FETCH_DEPENDENCIES=OFF              ^
  -D DAWN_BUILD_MONOLITHIC_LIBRARY=SHARED     ^
  -D TINT_BUILD_TESTS=OFF                     ^
  -D TINT_BUILD_SPV_READER=OFF                ^
  -D TINT_BUILD_SPV_WRITER=OFF                ^
  -D TINT_BUILD_CMD_TOOLS=OFF                 ^
  || exit /b 1

rem --------------------------------------------------------------------------
rem run the full dawn build
rem --------------------------------------------------------------------------

set CL=/Wv:18
REM cmake.exe --build %BUILD_DIR% --config Release --target webgpu_dawn tint_cmd_tint_cmd --parallel --verbose|| exit /b 1
cmake.exe --build %BUILD_DIR% --config Release --target webgpu_dawn --parallel --verbose|| exit /b 1

rem --------------------------------------------------------------------------
rem install to output
rem --------------------------------------------------------------------------
cmake --install %BUILD_DIR% --prefix %BUILD_DIR%/out

rem --------------------------------------------------------------------------
rem install glfw headers (cmake install omits them)
rem --------------------------------------------------------------------------
rem set GLFW_INCLUDE_SRC=%CD%\dawn\third_party\glfw\include\GLFW
rem set GLFW_INCLUDE_DST=%CD%\%BUILD_DIR%\out\include\GLFW
rem if exist "%GLFW_INCLUDE_SRC%" (
rem   if not exist "%GLFW_INCLUDE_DST%" mkdir "%GLFW_INCLUDE_DST%"
rem   xcopy "%GLFW_INCLUDE_SRC%\*" "%GLFW_INCLUDE_DST%\" /E /I /Y >NUL
rem )
rem copy /y %CD%\dawn\include\webgpu\webgpu_glfw.h            %CD%\%BUILD_DIR%\out\include\webgpu\webgpu_glfw.h || exit /b 1



rem --------------------------------------------------------------------------
rem prepare output folder
rem --------------------------------------------------------------------------
rem mkdir dawn-%TARGET_ARCH%
rem echo %DAWN_COMMIT% > dawn-%TARGET_ARCH%\commit.txt
rem copy /y %BUILD_DIR%\gen\include\dawn\webgpu.h               dawn-%TARGET_ARCH% || exit /b 1
rem copy /y %BUILD_DIR%\Release\webgpu_dawn.dll                 dawn-%TARGET_ARCH% || exit /b 1
rem copy /y %BUILD_DIR%\src\dawn\native\Release\webgpu_dawn.lib dawn-%TARGET_ARCH% || exit /b 1

rem copy /y %BUILD_DIR%\Release\tint.exe                        dawn-%TARGET_ARCH% || exit /b 1


popd
