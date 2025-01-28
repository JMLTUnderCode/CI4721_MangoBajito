# CI4721 - Lenguajes de Programación II - Mango Bajito
### Descripción
Repositorio asociado a la creación de un lenguaje de programación "Mango Bajito". Este proyecto nace bajo un ambiente académico proporcionado por la Universidad Simón Bolívar durante el trimestre Enero Marzo 2025 bajo la tutela del Prof. Ricardo Monascal en la materia CI4721 - Lenguajes de Programación II.
### Integrantes
* Astrid Alvarado, 18-10938
* Kenny Rojas 18-10595, 
* Jhonaiker Blanco, 
* Junior Lara, 17-10303

## Índice
- [CI4721 - Lenguajes de Programación II - Mango Bajito](#ci4721---lenguajes-de-programación-ii---mango-bajito)
		- [Descripción](#descripción)
		- [Integrantes](#integrantes)
	- [Índice](#índice)
- [Preámbulo](#preámbulo)
- [Definición](#definición)
	- [Características](#características)
		- [Tipos de Datos](#tipos-de-datos)
			- [Escalares](#escalares)
		- [Mecanismos](#mecanismos)
		- [Subrutinas](#subrutinas)
		- [Manejo de Errores](#manejo-de-errores)
	- [Ejemplos](#ejemplos)

# Preámbulo
Hace no mucho tiempo, en una oficina calurosa donde el aire acondicionado estaba "puro tirar frío pa' la calle", 
un grupo de programadores venezolanos, después de tres empanadas de pabellón y un par de jugos de guanábana, 
decidieron que ya estaba bueno de tanto sufrir con lenguajes de programación complicados. Que si Java, que si Python, 
que si C++. "¡Qué manguangua tan seria pa' entender esas vainas!", dijeron. Fue allí cuando uno de ellos, con el 
cerebro medio adormecido por el tequeño que se acababa de comer, soltó:

"¡Chamos, necesitamos un lenguaje que sea puro mango bajito! Algo que hasta el pana más nuevón pueda entender y 
no le dé dolor de cabeza ni le salga una 'luz roja' en el cerebro cada vez que quiera hacer un 'hola mundo'".

Y así nació Mango Bajito, el lenguaje que promete ser la arepa pelada del desarrollo. ¿La idea? Hacer que programar
sea tan fácil como pedir un kilo de queso rallado en la bodega de la esquina. Todas las palabras clave del lenguaje 
están inspiradas en la jerga venezolana para que hasta tu abuela diga: "Ah, bueno, esto sí lo entiendo".

Pero eso no es todo. Mango Bajito tiene su propio debugger que no te manda errores, te manda reclamos: 
"¡Chamo, revisa el código, que aquí metiste un peo!" O el compilador que, cuando terminas el código sin errores, te dice: 
"¡Esa es la actitud, mi rey!"

Entonces, ¿por qué deberías elegir Mango Bajito? Fácil: porque la vida ya tiene suficientes compliqueos. 
Deja la amargura y vente a la fiesta. ¡Mango Bajito, el lenguaje que no es paja! 👌

# Definición
Mango Bajito es un lenguaje de programación imperativo, diseñado para facilitar la creación de software mediante un enfoque intuitivo y accesible. Este lenguaje se caracteriza por su simplicidad en la sintaxis, inspirada en la jerga venezolana, y por su diseño estructurado, enfocado en reducir la complejidad del desarrollo. A continuación, se detallan sus principales características computacionales:

## Características

* Se basa en el paradigma de programación imperativa, donde el flujo del programa se controla mediante declaraciones explícitas que modifican el estado del sistema.

* Alcance estático con anidamiento arbitrario de bloques:
El lenguaje utiliza un modelo de alcance léxico estático, donde las variables y funciones son resueltas con base en el entorno donde fueron definidas, no donde son ejecutadas.

* Implementa un sistema de tipos fuertes, donde las operaciones entre tipos incompatibles son prevenidas por el lenguaje, evitando errores en tiempo de ejecución relacionados con conversiones implícitas o mal manejo de datos. Además, la verificación de tipos se realiza de forma estática, durante la fase de compilación, garantizando que el código sea consistente y seguro antes de ser ejecutado.

* Aunque no es estrictamente técnico, la sintaxis de Mango Bajito es intencionadamente sencilla y coloquial, con palabras clave diseñadas para ser intuitivas y fáciles de recordar. Esto hace que el lenguaje sea accesible para programadores principiantes sin sacrificar las capacidades necesarias para desarrollos complejos.

### Tipos de Datos

#### Escalares
  - #### Caracteres (`negro`)
    El tipo `negro` se utiliza para almacenar caracteres individuales, como letras, dígitos o símbolos. Es equivalente al tipo `char` en otros lenguajes de programación. Los valores deben definirse entre comillas simples.
	
	**Ejemplo:**
    ```
    negro letra = 'A';
    negro simbolo = '$';
    ```

  - #### Enteros (`mango`)
	El tipo `mango` representa números enteros, positivos o negativos, dentro de un rango dependiente de la implementación del lenguaje (normalmente 32 bits). Es ideal para contadores, índices y cálculos discretos.
	
	**Ejemplo:**
	```
	mango edad = 25;
	mango contador = -10;
	```

  - #### Flotantes (`manguita`)
	El tipo `manguita` se utiliza para representar números en coma flotante de precisión simple, adecuados para cálculos donde no se requiere una precisión extremadamente alta.
	
	**Ejemplo:**
	```
	manguita temperatura = 36.7;
	manguita precio = 12.50;
	```
    
  - #### Dobles (`manguangua`)
	El tipo `manguangua` se utiliza para números en coma flotante con doble precisión, siendo más adecuado para cálculos científicos o situaciones que requieren alta precisión en operaciones decimales.
	
	**Ejemplo:**
	```
	manguangua pi = 3.14159265359;
	manguangua distancia = 1.989e30;
	```

  - #### Booleanos (`tas_claro`)
	El tipo `tas_claro` representa valores lógicos, con dos valores posibles: Sisa (equivalente a True) y Nolsa (equivalente a False). Este tipo es ampliamente utilizado en estructuras condicionales y bucles para controlar el flujo del programa.
	
	**Ejemplo:**
	```
	tas_claro esMayor = Sisa;
	tas_claro esPar = Nolsa;
	```
	> [!IMPORTANT]IMPORTANTE
	> - Mango Bajito no realiza conversiones implícitas entre tipos de datos escalares. Por ejemplo, no se puede asignar un manguangua a un mango sin una conversión explícita. Esto refuerza su sistema de tipos fuertes.
	> - Los valores por defecto al declarar variables sin inicializar son:
	>    - `negro`: '\0' (carácter nulo)
	>    - `mango`: 0
	>    - `manguita` y `manguangua`: 0.0
	>    - `tas_claro`: Nolsa
 
* #### Compuestos
  - #### Cadena de Caracteres (`higuerote`)
  	El tipo `higuerote` se utiliza para representar cadenas de texto. Una cadena es un arreglo inmutable de caracteres (de tipo `negro`), ideal para manejar palabras, frases o cualquier dato textual.
	
	**Ejemplo:**
  	```
  	higuerote saludo = "Hola, chamo";
  	higuerote mensaje = "Esto es Mango Bajito";
	```
  - #### Arreglos
	Los arreglos permiten almacenar múltiples elementos del mismo tipo en una estructura indexada. Se definen utilizando el tipo de los elementos seguido de [].
	
	**Ejemplo:**
	```
	mango[] numeros = [1, 2, 3, 4];
	higuerote[] saludos = ["Hola", "Chamo", "Mango Bajito"];
	```
	Los arreglos pueden ser de tamaño fijo o dinámico, dependiendo de la implementación. Los índices comienzan en 0, y es posible acceder y modificar elementos usando corchetes:
	```
	numeros[0] = 10;  // Cambia el primer elemento del arreglo a 10
	mango numero = numeros[0];    // Extraer el primer elemento del arrglo.
	```
    
  - #### Registros (`arroz_con_mango`)
	El tipo `arroz_con_mango` es una estructura que permite agrupar múltiples variables de diferentes tipos bajo un mismo nombre. Es útil para representar objetos o datos relacionados.

	**Ejemplo:**
	```
	arroz_con_mango Persona {
  		higuerote nombre;
  		mango edad;
  		tas_claro estudiante;
	}

	Persona juan = { "Juan Pérez", 25, Sisa };
	rescata juan.nombre;  // Imprime: Juan Pérez
	```
	>[!NOTE] En caso de duda con `rescata`
	Ver definicion de [rescata](#Procedimientos-del-Lenguaje).
    
  - #### Variantes
    `vaina`
    `coroto`
    `negriados`

  - #### Apuntadores (`ahi_ta`)
	Los apuntadores (`ahi_ta`) permiten hacer referencia a valores en memoria dinámica (heap). Se usan para manejar estructuras dinámicas o referencias indirectas. Mango Bajito abstrae la complejidad del manejo de memoria para facilitar su uso.
	
	**Ejemplo:**
	```
	ahi_ta mango* numero = nuevo mango(10);
	rescata *numero;  // Imprime: 10
	```
	>[!NOTE] Mango Bajito no permite aritmética de apuntadores para mantener la seguridad de memoria.
    
* #### Void (`un_coño`)
	El tipo `un_coño` indica que una función no retorna ningún valor. Es equivalente al tipo void en otros lenguajes. Se utiliza principalmente para procedimientos o funciones que ejecutan acciones sin devolver datos.

	**Ejemplo:**
	```
	un_coño saluda() {
		rescata "Hola, chamo!";
	}
	```
	>[!NOTE] Dudas
	> * En caso de duda con `rescata` vea su definición en [rescata](#procedimientos-del-lenguaje).
	> * En caso de duda con se definen las funciones vaya a [funciones](#funciones)

* #### Operadores
  * #### Lógicos
    - Equal
      Se define con la palabra clave "`igualito`".
      
    - NotEqual
      Se define con la palabra clave "`nie`".

    - And
      Se define con la palabra clave "`yunta`".

    - Or
      Se define con la palabra clave "`o_sea`". (DEBATIBLE)

    - Not
      Se define con la palabra clave "`nelson`".

  * #### Aritméticos
    - Suma (+)
      
    - Resta (-)
      
    - Multiplicación (*)
      
    - División
      - Entera (//)
        
      - Decimal (/)
        
    - Potenciación (**)
      
  * #### Cadenas de Caracteres
    - Concatenación: Se tiene sobrecarga sobre el operador `+`.
    - Repetición: Se tiene sobrecarga sobre el operador `*`.

* #### Operaciones entre tipos de datos
  
  
### Mecanismos
* #### Instrucción
    Como operedor de secuenciación se utilizara el simbolo `;`. 
  
* #### Asignación

  Se utilizara el simbolo de `=` para asignarle un valor a una variable o una constante.

* #### Declaración
  * ##### Var
    Se define con la palabra clave "`culito`"

  * ##### Val
    Se define con la palabra clave "`jeva`"

    
* #### Selección
  Se define con la palabra "`si_es_asi`"/"`sino`"/"`nojoda`".
  ```
  si_es_asi Condicion {
    Instrucciones
  } sino Condicion {
    Instrucciones
  } nojoda {
    Instrucciones
  }
  ```
  
* #### Repetición
  * #### For
    Se define con la palabra clave "`repite_burda`"/"`entre`"/"`hasta`". (Determinada)
    ```
    repite_burda [var] entre [cota_inf] hasta [cota_sup] con_flow [mango]{
      Instrucciones
    }
    ```
    Donde
    * var pertenece a
    * cota_inf pertenece a
    * cota_sup pertenece a
  
  En este caso caso el rango en el que trabajara el `repite_burda` 
    
    
  * #### While
    Se define con la palabra clave "`echale_bolas_hasta`". (Intederminada)
    ```
    echale_bolas_hasta Condicion {
      Instrucciones
    }
    ```
  
### Subrutinas
* #### Procedimientos
  Se define como ...

  * #### Procedimientos del Lenguaje
    * `rescata`
  		Permite mostrar el contenido de una constante o variable.

    * `que_monda_ejesa(type var)`
		Permite retornar el tipo de dato que representa "`var`". Se caracteriza
      
    * `ah_vaina(type higuerote)`
		Permite retornar un error con el contenido de "higuerote".

* #### Funciones
  (retornos escalares)

  ```
  echar_cuento <nombre>(<parametros>) lanza <type> {
    '''Codigo'''
  }
  ```
  * #### Pasaje de parámetros
    * #### Por valor
    Los tipos de datos basicos Caracteres, Enteros, Flotantes, Double y Booleanos se pasaran a las funciones por valor, así como las Cadena de Caracteres
      
    * #### Por referencia
   
      
* #### Recursión
  "`bochinche`"

### Manejo de Errores
Se define con el conjunto de palabras clave "`meando`"/"`fuera_del_perol`".
```
meando {
  Instrucciones
} fuera_del_perol {
  Ah_vaina(type higuerote)
}
```

## Ejemplos


