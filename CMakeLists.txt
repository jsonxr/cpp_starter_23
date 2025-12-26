cmake_minimum_required(VERSION 3.28)

project(MyProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Check Features
include(cmake/FeatureChecks.cmake)
include(cmake/DisableExceptions.cmake)

add_subdirectory(src)
#add_subdirectory(tests)
