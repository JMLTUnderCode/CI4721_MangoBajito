# Mango Bajito Project

Módulo desarrollados del proyecto Mango Bajito.

- [x] Lexer
    - [x] Inicializado
    - [x] Desarrollando
    - [x] Terminado
- [x] Parser
    - [x] Inicializado
    - [x] Desarrollando
    - [ ] Terminado
- [x] Tabla de Símbolos LeBlanc-Cook
    - [x] Inicializado
    - [x] Desarrollando
    - [ ] Terminado
- [x] Manejo de errores
    - [x] Inicializado
    - [x] Desarrollando
    - [ ] Terminado
- [x] Árbol Sintáctico Abstracto (AST)
    - [x] Inicializado
    - [x] Desarrollando
    - [ ] Terminado
- [ ] Código de tres direcciones. (TAC)
    - [x] Inicializado
    - [x] Desarrollando
    - [ ] Terminado

## Guía
- Para preparar el ambiente de trabajo donde se pueda utilizar los elementos del Lexer, Parser y tabla de Simbolo se quiere instalar:
  - [Flex](https://westes.github.io/flex/manual/): Generador de analizadores léxicos.
  - [Bison](https://www.gnu.org/software/bison/manual/): Generador de analizadores sintácticos.
  - CMake: Para compilar y gestionar el proyecto.

	```
	sudo apt update && sudo apt install -y build-essential cmake flex bison
	```

- Para compilar y ejecutar el proyecto:
  
  Estando en la carpeta `MangoBajito` realizar los siguientes pasos:
  - Para la compilación del proyecto:
	```
	make
	```
	Esto generará el ejecutable `mango_bajito`. 
	>[!NOTE]
	>El comando `make` esta configurado para realizar clean y compilar en limpio.

  - Para ejecucion y prueba del proyecto directamente:
	```
	make run e=<dir de archivo.mng>
	```
  
	Ej.
	```
	make run e=tests/Declaracion/valid/00-mango.mng
	```
	Equivalentemente
	```
	./mango_bajito tests/Declaracion/valid/00-mango.mng
	```

  - Para ejecutar la suit de pruebas automzatizada:
	Actualmente hay dos suit de pruebas.
	- Lenguajes_II  : Pruebas asociadas a Lexer, Parser, Tabla de Símbolos y AST.
	- Lenguajes_III : TAC
	
	Para ejecutar la suit de pruebas de Lenguajes II:
	```
	make unitest2
	```
	Para ejecutar la suit de pruebas de Lenguajes III:
	```
	make unitest3
	```

	>[!NOTE]
	> * Esto ejecutará todas las pruebas unitarias definidas en el proyecto, contenidas en la carpeta `tests/Lenguajes_II` y `tests/Lenguajes_III`.
	> * El tipo de prueba es mediante `archivos de oro` contenidos en las subcarpetas 'expected' de cada sección de prueba en las subcarpetas  de `tests/`, estos `.out` representan la salida esperada de los archivos en la sección de prueba correspondiente.

  - Para realizar pruebas locales:
	```
	make local e=<nombre sin extension>
	```
	Se asume que los archivos de pruebas estan en la carpeta `local/` y tienen extensión `.mng` por defecto.
	Ej.
	```
	make local e=prueba // Se refiere a probar el archivo `prueba.mng`
	make local e=1      // Se refiere a probar el archivo `1.mng`
	```

  - Limpieza de archivos generados
	```
	make clean
	```
## Lexer-Parser-SymbolTable-AST: Implementaciones
- [x] Scopes
    - [x] Abrir alcances 
    - [x] Cerrar alcances
    - [x] Actualizacion de alcances
- [x] Declaración
    - [x] Tipos basicos
        - [x] Mango
        - [x] Manguita
        - [x] Manguangua
        - [x] Negro
        - [x] Higuerote
        - [x] Tas_claro
    - [x] Arrays
    - [x] Structs (`arroz_con_mango`)
    - [x] Union (`coliao`)
    - [x] Funciones (`echar_cuento`)
- [x] Asignación
    - [x] Literales
    - [x] Variables
    - [x] Constantes
    - [x] Funciones (`echar_cuento`)
    - [x] Atributo de Structs (`arroz_con_mango`)
    - [x] Atributo de Union (`coliao`)
- [ ] Funciones
    - [x] Llamada con cantidad de parametros correctos
    - [x] Llamada con tipos de parametros correctos
    - [ ] Funciones y Procedimientos del lenguajes
        - [ ] `lanzate`
		- [ ] `rescata`
		- [ ] `hablame`
        - [ ] `que_monda_ejesa`
        - [ ] `ah_vaina`
        - [ ] `pegao`
        - [ ] `maelo`
        - [ ] `me_mide`
        - [ ] `rellenamelo`
- [x] Condicional
    - [x] Bloque: si_es_asi
        - [x] Guardia
        - [x] Instrucciones
    - [x] Bloque: o_asi
        - [x] Guardia
        - [x] Instrucciones
    - [x] Bloque: nojoda
        - [x] Instrucciones
- [ ] Ciclo Determinado
    - [x] Variable de ciclo (repite_burda)
    - [x] Rango de ciclo (desde y hasta)
    - [x] Paso de ciclo (con_flow)
    - [ ] Verificar condiciones de rangos y pasos validos
- [x] Ciclo Indeterminado
    - [x] Guardia
    - [x] Bloque de Instrucciones
- [ ] Control de Flujo en Bucles
    - [ ] `uy_kieto`
    - [ ] `rotalo`
- [ ] Manejo de Errores
    - [ ] Variable de manejo (`fuera_del_perol` y `con`)
    - [ ] `caramba_ñero`
- [ ] Casteo
    - [ ] Verificacion de casteos
- [ ] Operaciones
	- [x] Compuestas (+=, -=, *=)
	- [x] Decremento y aumento ++ y --
	- [ ] Expresiones logicas.
    	- [x] yunta
    	- [x] o_sea
    	- [x] Nelson
    	- [x] igualito
    	- [x] nie
    	- [x] mayol
    	- [x] menol
    	- [x] lidel
    	- [x] peluche
    	- [x] Anidamiento
- [ ] Apuntadores
    - [ ] Guardar apuntadores en la tabla de símbolos.
	- [ ] Chequear la informacion de los elementos apuntadores(funcion print_info).
- [ ] Arreglos Multidimensionales
    - [ ] Guardado
    - [ ] informacion
    - [ ] Valores
- [x] Errores
	- [x] Utilizacion de variable sin definir.
	- [x] Redeclaracion de una variable en un mismo scope.
	- [x] Modificacion del valor de una variable asociada a un ciclo determinado.
	- [x] Modificacion del valor de una variable asociada a un try/catch.
	- [ ] Errores de Mango Bajito (lo usados en meando/fueral_del_perol: piaso e copion por ejemplo)
	- [ ] Cuando haya un syntax error retorna "Escribe bien esa vaina", entre otros.
	- [ ] Mostrar errores de context más informativos.


## TAC: Implementaciones

- [x] Expresiones (sin and, or, not, true, false)
- [x] Declaracion y asignacion
- [x] Asignacion (sin array ni apuntadores)
- [x] Sentencia if
- [x] Sentencia while
- [x] Sentencia for
- [x] Funciones
- [ ] Structs y Variantes
- [ ] Arrays
- [ ] jumping code

## Pruebas del Proyecto
- [ ] Suit de pruebas
    - [x] Construir un script para una suit de pruebas automatizada.
    - [x] Incluir casos de prueba por categorias y secciones.
    - [x] Validación de errores fuerte.
    - [ ] Suits
        - [ ] Asignaciones
            - [x] Validos
            - [ ] Errores
        - [ ] Bucles
            - [x] Validos
            - [ ] Errores
        - [ ] Condicional
            - [x] Validos
            - [ ] Errores
        - [ ] Operaciones
            - [x] Validos
            - [ ] Errores
        - [ ] Funcion
            - [x] Validos
            - [ ] Errores
        - [ ] Manejo de Errores (Meando Fuera del Perol)
            - [ ] Validos
            - [ ] Errores
        - [ ] Apuntadores
            - [ ] Validos
            - [ ] Errores
 