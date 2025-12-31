cmake_minimum_required(VERSION 3.28)

project(MyProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#-----------------------------------------------------------------------------
# BUILD_DIR: win-arm64-debug, win-x64-debug, mac-arm64-debug
#-----------------------------------------------------------------------------
set(_sys "${CMAKE_SYSTEM_NAME}")
if (_sys STREQUAL "Windows")
    set(_sys "win")
elseif (_sys STREQUAL "Linux")
    set(_sys "linux")
elseif (_sys STREQUAL "Darwin")
    set(_sys "mac")
endif()
string(TOLOWER "build/${_sys}_${CMAKE_SYSTEM_PROCESSOR}_${CMAKE_BUILD_TYPE}" BUILD_DIR)
message(STATUS "CMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
message(STATUS "BUILD_DIR=${BUILD_DIR}")

#-----------------------------------------------------------------------------
# Check Features
#-----------------------------------------------------------------------------
#include(cmake/FeatureChecks.cmake)
#include(cmake/DisableExceptions.cmake)

add_executable(MyApp)
target_sources(MyApp PRIVATE src/main.cpp)


#-----------------------------------------------------------------------------
# Emscripten
#-----------------------------------------------------------------------------
if (EMSCRIPTEN)
  set_target_properties(MyApp PROPERTIES
    SUFFIX ".html"
    OUTPUT_NAME "index"
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/www
  )
  target_link_libraries(MyApp PRIVATE emdawnwebgpu_cpp webgpu_glfw)
  target_link_options(MyApp PRIVATE
    #"-pthread"
    "-sASYNCIFY=1"
    "-sUSE_GLFW=3"
    #"-sUSE_PTHREADS=1"
  )

#-----------------------------------------------------------------------------
# Desktop
#-----------------------------------------------------------------------------
else ()
  set_target_properties(MyApp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
  )
  
  # https://dawn.googlesource.com/dawn/+/refs/heads/main/CMakeLists.txt
  if (MSVC)
    message(STATUS "Detected MSVC")
    set(DAWN_ENABLE_WERROR OFF CACHE BOOL "" FORCE)
    set(DAWN_ENABLE_WARNINGS OFF CACHE BOOL "" FORCE)
    set(SPIRV_TOOLS_ENABLE_WERROR OFF CACHE BOOL "" FORCE)
    set(SPIRV_WERROR OFF CACHE BOOL "" FORCE)
    add_compile_options(/Wv:18)
  endif()
  set(DAWN_USE_GLFW ON)
  set(DAWN_FETCH_DEPENDENCIES ON)
  #set(DAWN_ENABLE_VULKAN OFF)
  #set(DAWN_ENABLE_D3D11 OFF)
  #set(DAWN_ENABLE_NULL OFF)
  set(DAWN_BUILD_SAMPLES OFF)
  #set(DAWN_ENABLE_SPIRV_VALIDATION OFF)
  #set(DAWN_ENABLE_DESKTOP_GL OFF)
  # tint
  #set(TINT_BUILD_GLSL_VALIDATOR OFF)
  #set(TINT_BUILD_CMD_TOOLS OFF)
  #set(TINT_BUILD_TESTS OFF)
  #set(TINT_ENABLE_IR_VALIDATION OFF)
  #set(DAWN_BUILD_PROTOBUF OFF) # Tint build IR binary
  #set(DAWN_BUILD_MONOLITHIC_LIBRARY STATIC)
  #set(DAWN_BUILD_TESTS OFF)
  #-D DAWN_ENABLE_D3D12=ON                     ^
  #-D DAWN_ENABLE_DESKTOP_GL=OFF               ^
  #-D DAWN_ENABLE_OPENGLES=OFF                 ^

  add_subdirectory("${CMAKE_SOURCE_DIR}/dawn")
  #target_include_directories(MyApp PRIVATE
  #  "${CMAKE_SOURCE_DIR}/dawn/include"
  #  "${CMAKE_SOURCE_DIR}/dawn/third_party/glfw/include"
  #)
  target_link_libraries(MyApp PRIVATE
    dawn::webgpu_dawn
    #dawn::dawn_public_config
    webgpu_glfw
    glfw
  )



  # Native build defaults
  if (MSVC)
    target_compile_options(MyApp PRIVATE /W4 /permissive-)
  else ()
    target_compile_options(MyApp PRIVATE -Wall -Wextra -Wpedantic)
  endif ()
  #target_link_libraries(MyApp PRIVATE webgpu_dawn webgpu_glfw glfw)

#  target_link_libraries(MyApp PRIVATE
#    dawn::dawn_public_config
#    dawn::webgpu_dawn
#    glfw
#  )

endif ()
