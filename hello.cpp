module; // "global module fragment" begins here

#include <iostream>
#include <string>
#include <print>

// The global module fragment ends when a module declaration is encountered.
export module Hello;

export void hello()
{
    std::cout << "Hello World from module!\n";
    std::string name = "Modern Developer";
    std::println("Using std::println: Hello, {}!", name);
}
