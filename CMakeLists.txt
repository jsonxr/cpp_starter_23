cmake_minimum_required(VERSION 4.0.2)

project(MyProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)

add_executable(MyApp main.cpp)
target_sources(MyApp
  PRIVATE
  FILE_SET cxx_modules TYPE CXX_MODULES FILES
    hello.cpp
)
