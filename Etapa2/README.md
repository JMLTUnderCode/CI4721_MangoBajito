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
  - Para ejecucion y prueba del proyecto usando la suit de `tests`:
	```
	make test arg=<nombre de archivo>
	```
	Se asume que los archivos de pruebas estan en la carpeta `tests/` y tienen extensión `.mng` por defecto.
	Ej.
	```
	make test arg=prueba // Se refiere a probar el archivo prueba.mng
	make test arg=1      // Se refiere a probar el archivo 1.mng
	```
  - Para ejecucion y prueba del proyecto directamente:
	```
	make run arg=<dir de archivo>
	```
	Ej.
	```
	make run arg=tests/0.mng  // Probar el archivo ubicado en `tests` de nombre `0.mng`
	make run arg=otrodir/t1.mng  // Probar el archivo ubicado en `otrodir` de nombre `t1.mng`
	```
  - Para ejecucion manual:
	Compilar y generar el ejecutable
	```
	make
	```
	Ejecutar la etapa
	```
	./mango_bajito <dir del archivo>
	```
  - Limpieza de archivos generados
	```
	make clean
	```

## Realizado
- [x] Guardar variables declaradas (sin valor).
- [x] Guardar variables declaradas (con valor) (🐞❗).
  - [ ] Revisar guardado de literales.
- [x] Abrir y cerrar alcances. Actualizacion de scopes.
- [x] Guardar estructuras.
- [x] Guardar variantes.
- [x] Guardar informacion de ciclo determinado.
- [x] Guardar informacion de ciclo indeterminado.
- [x] Guardar funciones.
- [x] Guardar funciones con 1 parametro.
- [ ] Guardar funciones con multiples parametros.
- [ ] Agregar a tipos nombres de struct/varinates
- [x] Revisar la logica de la funcion `hablame`.
- [x] Revisar la logica de la funcion `rescata`.
- [ ] Casteo
  - [x] Agregarlo a la gramática
  - [ ] Lógica de guardado en Tabla de Símbolos
- [ ] Revisar operaciones
	- [ ] Asignaciones +=, -=, *=
	- [ ] Decremento y aumento ++ y --
	- [ ] Expresiones logicas y anidamiento de ellas
- [ ] Guardar apuntadores en general.
	- [ ] Chequear la informacion de los elementos apuntadores(funcion print_info).
- [ ] Guardar lista de valores de un array.
	- [ ] Guardar informacion relevante de los array.
    - [ ] Analizar logica para multidimencion. Guardado, informacion, etc.
- [x] Errores:
	- [x] Utilizacion de variable sin definir.
	- [x] Redeclaracion de una variable en un mismo scope.
	- [x] Modificacion del valor de una variable asociada a un ciclo determinado.
	- [x] Modificacion del valor de una variable asociada a un try/catch.
	- [ ] Errores de Mango Bajito
	- [ ] Mostrar errores de context más informativos