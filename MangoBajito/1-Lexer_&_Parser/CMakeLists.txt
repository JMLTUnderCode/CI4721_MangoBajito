cmake_minimum_required(VERSION 3.10)
project(MangoBajito)

set(CMAKE_CXX_STANDARD 17)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# Configuración de FLEX para el lexer
FLEX_TARGET(Lexer src/mango_lexer.l ${CMAKE_BINARY_DIR}/mango_lexer.cpp 
	COMPILE_FLAGS "-DYYHEADER=\"build/mango_lexer.yy.hpp\"")

# Configuración de BISON para el parser, usando la opción -d para generar el header
BISON_TARGET(Parser src/mango_parser.y ${CMAKE_BINARY_DIR}/mango_parser.cpp 
	DEFINES_FILE ${CMAKE_BINARY_DIR}/mango_parser.tab.hpp
	COMPILE_FLAGS "-Wcounterexamples -Wconflicts-sr -d")

# Aseguramos que FLEX se ejecute antes de BISON
ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)

# Directorio de inclusión para los archivos generados por FLEX y BISON
include_directories(${CMAKE_BINARY_DIR})

# Agregar el directorio src a las rutas de inclusión
include_directories(${CMAKE_SOURCE_DIR}/src)

# Crear el ejecutable
add_executable(mango_bajito src/main.cpp ${FLEX_Lexer_OUTPUTS} ${BISON_Parser_OUTPUTS} src/mango_bajito.cpp src/tac.hpp)
