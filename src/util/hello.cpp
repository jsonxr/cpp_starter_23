#include "hello.h"

#include <iostream>
#include <print>
#include <string>

void hello()
{
    std::cout << "Hello World from a header-based build!\n";
    std::string name = "Modern Developer";
    std::println("Using std::println: Hello, {}!", name);
}
