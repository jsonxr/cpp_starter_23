@echo off
setlocal enabledelayedexpansion

set DAWN_COMMIT=479f62d2194fd6e44c37d07654ca6e41c42bd332

rem
rem Adapted from:
rem https://github.com/mmozeiko/build-dawn/tree/main
rem

set SCRIPT_DIR=%~dp0
pushd "%SCRIPT_DIR%.." || exit /b 1
rem ensure dawn is placed beside the bin folder, regardless of invocation path

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
    python -c "import sys, urllib.request, base64, re; chrome=sys.argv[1]; url=f'https://chromium.googlesource.com/chromium/src.git/+/refs/tags/{chrome}/DEPS?format=TEXT'; deps_b64=urllib.request.urlopen(url).read(); deps=base64.b64decode(deps_b64).decode(); m=re.search(r\"['\\\"]dawn_revision['\\\"]\\s*:\\s*['\\\"]([0-9a-f]+)['\\\"]\", deps); print(m.group(1) if m else '')" "%CHROME_VERSION%"
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



popd
