cmake_minimum_required(VERSION 3.10)
project(MangoBajito)

set(CMAKE_CXX_STANDARD 17)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# Configuración de FLEX para el lexer
FLEX_TARGET(Lexer src/mango-lexer.l ${CMAKE_BINARY_DIR}/mango-lexer.cpp 
    COMPILE_FLAGS "-DYYHEADER=\"build/mango-lexer.yy.hpp\"")

# Configuración de BISON para el parser, usando la opción -d para generar el header
BISON_TARGET(Parser src/mango-parser.y ${CMAKE_BINARY_DIR}/mango-parser.cpp 
    DEFINES_FILE ${CMAKE_BINARY_DIR}/mango-parser.tab.hpp)

# Aseguramos que FLEX se ejecute antes de BISON
ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)

# Directorio de inclusión para los archivos generados por FLEX y BISON
include_directories(${CMAKE_BINARY_DIR})

# Crear el ejecutable
add_executable(mango_bajito src/main.cpp ${FLEX_Lexer_OUTPUTS} ${BISON_Parser_OUTPUTS})
