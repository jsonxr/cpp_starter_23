# add_subdirectory(core)
add_subdirectory(util)

add_executable(MyApp)
target_link_libraries(MyApp PRIVATE util)
target_sources(MyApp PRIVATE main.cpp)


if (NOT EMSCRIPTEN)
  set_target_properties(MyApp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
  )

  # Native build defaults
  target_compile_options(MyApp PRIVATE -Wall -Wextra -Wpedantic)
else ()
  # WASM build with Emscripten
  set_target_properties(MyApp PROPERTIES
    SUFFIX ".html"
    OUTPUT_NAME "index"
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/www
  )

  target_compile_options(MyApp PRIVATE
    "-pthread"
    "-sUSE_PTHREADS=1"
  )

  target_link_options(MyApp PRIVATE
    "-pthread"
    "-sUSE_PTHREADS=1"
    "-sALLOW_MEMORY_GROWTH=1"
  )
endif ()
