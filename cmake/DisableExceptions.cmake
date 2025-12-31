include_guard(GLOBAL)

# Disable Exceptions
if (MSVC)
    #add_compile_options(/EHsc-)
    #add_compile_definitions(_HAS_EXCEPTIONS=0)
else()
    add_compile_options(-fno-exceptions)
    #add_compile_options(-fno-rtti)     
    add_compile_definitions(_LIBCPP_NO_EXCEPTIONS)
endif()
