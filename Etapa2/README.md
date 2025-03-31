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
- [x] Guardar variables declaradas (con valor).
  - [ ] Revisar guardado de literales.
  - [x] Actualizacion asignacion de variables. Si a = 4, b = 5, y luego se hace a = b entonces a vale 5.
- [x] Abrir y cerrar alcances. Actualizacion de scopes.
- [x] Guardar estructuras.
- [x] Guardar variantes.
- [x] Guardar informacion de ciclo determinado.
- [x] Guardar informacion de ciclo indeterminado.
- [ ] Funciones
  - [x] Guardar funciones.
  - [x] Guardar funciones con 1 parametro.
  - [x] Guardar funciones con multiples parametros.
  - [x] Actualizar el vector de informacion de una funcion con sus respectivos parametros.
  - [x] Al momento de llamar una funcion que sea llamada con la cantidad de parametros correcta.
  - [x] Verificar tipos de los parametros al momento de llamar a una funcion.
  - [ ] Al momento de asignar una funcion a una variable, verificar que la variable tenga el tipo correcto.
- [ ] Agregar a tipos nombres de struct/variantes.
- [x] Revisar la logica de la funcion `hablame`.
- [x] Revisar la logica de la funcion `rescata`.
- [ ] Casteo
  - [x] Agregarlo a la gramática
  - [ ] Lógica de guardado en Tabla de Símbolos
- [ ] Revisar operaciones
	- [x] Creacion de numeros negativos
	- [ ] Asignaciones +=, -=, *=
	- [ ] Decremento y aumento ++ y --
	- [ ] Expresiones logicas y anidamiento de ellas
- [ ] Guardar apuntadores en general.
	- [ ] Chequear la informacion de los elementos apuntadores(funcion print_info).
- [ ] Guardar lista de valores de un array.
	- [x] Inicializacion de arrays.
	- [x] Edit de valores en array.
	- [x] Verificacion de tipos.
	- [x] Diferenciacion negro e higuerote 
	- [x] Acceso directo a valores del array.
    - [ ] Analizar logica para multidimencion. Guardado, informacion, etc.
- [x] Errores:
	- [x] Utilizacion de variable sin definir.
	- [x] Redeclaracion de una variable en un mismo scope.
	- [x] Modificacion del valor de una variable asociada a un ciclo determinado.
	- [x] Modificacion del valor de una variable asociada a un try/catch.
	- [ ] Errores de Mango Bajito (lo usados en meando/fueral_del_perol: piaso e copion por ejemplo)
	- [ ] Cuando haya un syntax error retorna "Escribe bien esa vaina", entre otros.
	- [ ] Mostrar errores de context más informativos