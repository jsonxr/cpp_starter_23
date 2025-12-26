add_library(util STATIC)

target_sources(util
  PRIVATE
    hello.cpp
  PUBLIC
    FILE_SET HEADERS FILES
      hello.h
)
