# Etapa 2 - Definicion de Lexer, Parser y Table de Simbolos

Para esta segunda etapa del proyecto de creación del lenguaje MangoBajito se requiere implementar

- Lexer
- Parser (Sin Árbol Sintáctico Abstracto)
- Tabla de Símbolos LeBlanc-Cook
- Manejo de errores a nivel Sintáctico y Semántico.
	- Todos los errores de lexer.
	- El primer error de parser.
	- Todos los errores de tabla de símbolos menos errores de tipos.

## Guias
- Para preparar el ambiente de trabajo donde se pueda utilizar los elementos del Lexer, Parser y tabla de Simbolo se quiere instalar:
  - [Flex](https://westes.github.io/flex/manual/): Generador de analizadores léxicos.
  - [Bison](https://www.gnu.org/software/bison/manual/): Generador de analizadores sintácticos.
  - CMake: Para compilar y gestionar el proyecto.

	```
	sudo apt update && sudo apt install -y build-essential cmake flex bison
	```

- Para compilar y ejecutar el proyecto:
  
  Estando en la carpeta `Etapa2/` realizar los siguientes pasos:
  - Creación de carpeta Build
	```
	mkdir build && cd build
	```
  - Estando en `build` preparar el proyecto:
	```
	cmake ..
	```
  - Para compilar el proyecto
	```
	make
	```
	Para volver a recompilar solo hace falta ejecutar `make` estando en `build`. En caso de cambios con `CMakeLists.txt` o si hay problemas con dependencias, puedes limpiar el proyecto y recompilar con:
	```
	rm -rf ../build/*; cmake ..; make
	```
  - Para Ejecutar el proyecto (se debe estar en la carpeta `build/`)
	```
	./mango_bajito ../tests/<archivo de prueba>
	```