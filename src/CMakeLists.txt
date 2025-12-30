
# Libraries...
# add_subdirectory(core)
add_subdirectory(util)



add_executable(MyApp)
target_link_libraries(MyApp PRIVATE util)
target_sources(MyApp PRIVATE main.cpp)


if (EMSCRIPTEN)
  # WASM build with Emscripten
  set_target_properties(MyApp PROPERTIES
    SUFFIX ".html"
    OUTPUT_NAME "index"
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/www
  )

  target_link_libraries(MyApp PRIVATE emdawnwebgpu_cpp webgpu_glfw)

  # target_compile_options(MyApp PRIVATE
  #   "-pthread"
  #   "-sASYNCIFY=1"
  #   "-sUSE_GLFW=3"
  #   "-sUSE_PTHREADS=1"
  # )

  target_link_options(MyApp PRIVATE
    #"-pthread"
    "-sASYNCIFY=1"
    "-sUSE_GLFW=3"
    #"-sUSE_PTHREADS=1"
  )
else ()
  set_target_properties(MyApp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
  )

  # Native build defaults
  target_compile_options(MyApp PRIVATE -Wall -Wextra -Wpedantic)
  target_link_libraries(MyApp PRIVATE webgpu_dawn webgpu_glfw glfw)
endif ()
