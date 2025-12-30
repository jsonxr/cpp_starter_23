cmake_minimum_required(VERSION 3.28)

project(MyProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Check Features
include(cmake/FeatureChecks.cmake)
include(cmake/DisableExceptions.cmake)

# DAWN
set(DAWN_FETCH_DEPENDENCIES ON)
add_subdirectory("dawn" EXCLUDE_FROM_ALL)

add_subdirectory(src)
#add_subdirectory(tests)
