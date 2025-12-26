include_guard(GLOBAL)
include(CheckCXXSourceCompiles)

# std:expected
check_cxx_source_compiles([[
  #include <expected>
  int main() {
    std::expected<int, int> value{1};
    return value.value();
  }
]] HAVE_STD_EXPECTED)
if (NOT HAVE_STD_EXPECTED)
  message(FATAL_ERROR "This project requires std::expected support.")
endif ()

# std::format
check_cxx_source_compiles([[
  #include <format>
  int main() {
    auto s = std::format("{}", 42);
    return static_cast<int>(s.size());
  }
]] HAVE_STD_FORMAT)
if (NOT HAVE_STD_FORMAT)
  message(FATAL_ERROR "This project requires std::format support.")
endif ()

# std::println
check_cxx_source_compiles([[
  #include <print>
  int main() {
    std::println("{}", 42);
    return -1;
  }
]] HAVE_STD_PRINT)
if (NOT HAVE_STD_PRINT)
  message(FATAL_ERROR "This project requires <print> support.")
endif ()
