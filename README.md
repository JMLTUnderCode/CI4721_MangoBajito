# **CI4721 - Lenguajes de Programación II - Mango Bajito**

## **Descripción**
Repositorio asociado a la creación de un lenguaje de programación "Mango Bajito". Este proyecto nace bajo un ambiente académico proporcionado por la Universidad Simón Bolívar durante el trimestre Enero Marzo 2025 bajo la tutela del Prof. Ricardo Monascal en la materia CI4721 - Lenguajes de Programación II.

## **Integrantes**
|   Integrantes    |  Carnet  |
| :--------------: | :------: |
| Astrid Alvarado  | 18-10938 |
|   Kenny Rojas    | 18-10595 |
| Jhonaiker Blanco | 18-10784 |
|   Junior Lara    | 17-10303 |

## **Índice**
- [**CI4721 - Lenguajes de Programación II - Mango Bajito**](#ci4721---lenguajes-de-programación-ii---mango-bajito)
	- [**Descripción**](#descripción)
	- [**Integrantes**](#integrantes)
	- [**Índice**](#índice)
	- [🥭**Preámbulo**](#preámbulo)
	- [🥭**Definición**](#definición)
	- [🥭**Características**](#características)
	- [🥭**Mecanismos**](#mecanismos)
		- [**Instrucción**](#instrucción)
		- [**Declaración**](#declaración)
			- [*Reglas para nombres de variables y constantes*](#reglas-para-nombres-de-variables-y-constantes)
			- [*Variable*](#variable)
			- [*Constante*](#constante)
		- [**Asignación**](#asignación)
		- [**Selección**](#selección)
		- [**Repetición**](#repetición)
			- [*Bucle for (`repite_burda`)*](#bucle-for-repite_burda)
			- [*Bucle while (`echale_bolas_si`)*](#bucle-while-echale_bolas_si)
			- [*Control del flujo en Bucles*](#control-del-flujo-en-bucles)
	- [🥭**Tipos de Datos**](#tipos-de-datos)
		- [**Escalares**](#escalares)
			- [*Caracteres* (`negro`)](#caracteres-negro)
			- [*Enteros* (`mango`)](#enteros-mango)
			- [*Flotantes* (`manguita`)](#flotantes-manguita)
			- [*Doubles* (`manguangua`)](#doubles-manguangua)
			- [*Booleanos* (`tas_claro`)](#booleanos-tas_claro)
		- [**Compuestos**](#compuestos)
			- [*Cadena de Caracteres* (`higuerote`)](#cadena-de-caracteres-higuerote)
			- [*Arreglos*](#arreglos)
			- [*Registros* (`arroz_con_mango`)](#registros-arroz_con_mango)
			- [*Variantes* (`coliao`)](#variantes-coliao)
		- [**Void** (`un_coño`)](#void-un_coño)
		- [**Error** (`caramba_ñero`)](#error-caramba_ñero)
		- [**Apuntadores**](#apuntadores)
			- [*Asignación de Memoria y Creación de Apuntadores* (`cero_km`)](#asignación-de-memoria-y-creación-de-apuntadores-cero_km)
			- [*Acceso* (`aki_toy`)](#acceso-aki_toy)
			- [*Liberación de Memoría* (`borradol`)](#liberación-de-memoría-borradol)
			- [*Valor NULL*](#valor-null)
	- [🥭**Procedimientos y Funciones**](#procedimientos-y-funciones)
		- [**Función sin retorno (Procedimiento)**](#función-sin-retorno-procedimiento)
		- [**Pasaje de parámetros**](#pasaje-de-parámetros)
			- [*Por valor*](#por-valor)
			- [*Por referencia*](#por-referencia)
		- [**Procedimientos y Funciones del Lenguaje**](#procedimientos-y-funciones-del-lenguaje)
			- [*Entrada y Salida*](#entrada-y-salida)
			- [*Manipulación de Tipos*](#manipulación-de-tipos)
			- [*Excepciones*](#excepciones)
			- [*Manipulación de Arreglos y Cadenas*](#manipulación-de-arreglos-y-cadenas)
	- [🥭**Manejo de Errores**](#manejo-de-errores)
	- [🥭**Operadores**](#operadores)
		- [**Lógicos**](#lógicos)
			- [*Equal* (`igualito`)](#equal-igualito)
			- [*NotEqual* (`nie`)](#notequal-nie)
			- [*And* (`yunta`)](#and-yunta)
			- [*Or* (`o_sea`)](#or-o_sea)
			- [*Not* (`nelson`)](#not-nelson)
		- [**Aritméticos**](#aritméticos)
			- [*Suma* (+)](#suma-)
			- [*Resta* (-)](#resta--)
			- [*Multiplicación* (\*)](#multiplicación-)
			- [*División Entera* (//)](#división-entera-)
			- [*División Decimal* (/)](#división-decimal-)
			- [*Potenciación* (\*\*)](#potenciación-)
			- [*Incremento* (++)](#incremento-)
			- [*Decremento* (--)](#decremento---)
			- [*Asignación aditiva* (+=)](#asignación-aditiva-)
			- [*Asignación sustractiva* (-=)](#asignación-sustractiva--)
			- [*Asignación multiplicativa* (\*=)](#asignación-multiplicativa-)
	- [🥭**Conversión de Tipos de Datos**](#conversión-de-tipos-de-datos)

## 🥭**Preámbulo**

Hace no mucho tiempo, en una oficina calurosa donde el aire acondicionado estaba "puro tirar frío pa' la calle", un grupo de programadores venezolanos, después de tres empanadas de pabellón y un par de jugos de guanábana, decidieron que ya estaba bueno de tanto sufrir con lenguajes de programación complicados. Que si Java, que si Python, que si C++. "¡Qué manguangua tan seria pa' entender esas vainas!", dijeron. Fue allí cuando uno de ellos, con el cerebro medio fundio' por el tequeño que se acababa de comer, soltó:

"¡Chamos, necesitamos un lenguaje que sea puro mango bajito! Algo que hasta el pana más nuevón pueda entender y no le dé dolor de cabeza ni le salga una 'luz roja' en el cerebro cada vez que quiera hacer un 'hola mundo'".

Y así nació Mango Bajito, el lenguaje que promete ser la arepa pelada del desarrollo. ¿La idea? Hacer que programar sea tan fácil como pedir un kilo de queso rallado donde *el portu*. Todas las palabras clave del lenguaje están inspiradas en la jerga venezolana para que hasta tu abuela diga: "Ah, bueno, esto sí lo entiendo".

Pero eso no es todo. Mango Bajito tiene su propio debugger que no te manda errores, te manda reclamos: 

"¡Chamo, revisa el código, que aquí metiste un peo!" O el compilador que, cuando terminas el código sin errores, te dice: "¡Esa es la actitud, mi rey!"

Entonces, ¿por qué deberías elegir Mango Bajito? Fácil: porque la vida ya tiene suficientes peos. Deja la acidez y vente pa' la rumba. ¡Mango Bajito, el lenguaje que no es paja! 👌

## 🥭**Definición**

Mango Bajito es un lenguaje de programación imperativo, diseñado para facilitar la creación de software mediante un enfoque intuitivo y accesible. Este lenguaje se caracteriza por su simplicidad en la sintaxis, inspirada en la jerga venezolana, y por su diseño estructurado, enfocado en reducir la complejidad del desarrollo.

## 🥭**Características**

* Se basa en el paradigma de programación imperativa, donde el flujo del programa se controla mediante declaraciones explícitas que modifican el estado del sistema.

* Alcance estático con anidamiento arbitrario de bloques: El lenguaje utiliza un modelo de alcance léxico estático, donde las variables y funciones son resueltas con base en el entorno donde fueron definidas, no donde son ejecutadas.

* Implementa un sistema de tipos fuertes, donde las operaciones entre tipos incompatibles son prevenidas por el lenguaje, evitando errores en tiempo de ejecución relacionados con conversiones implícitas o mal manejo de datos. Además, la verificación de tipos se realiza de forma estática, durante la fase de compilación, garantizando que el código sea consistente y seguro antes de ser ejecutado.

* Aunque no es estrictamente técnico, la sintaxis de Mango Bajito es intencionadamente sencilla y coloquial, con palabras clave diseñadas para ser intuitivas y fáciles de recordar. Esto hace que el lenguaje sea accesible para programadores hartos de lenguajes formales sin sacrificar las capacidades necesarias para desarrollos complejos.

## 🥭**Mecanismos**

### **Instrucción**

Una `instrucción` es una unidad fundamental de ejecución dentro del lenguaje. Cada instrucción representa una acción específica que el programa debe realizar, como una asignación, una declaración, una operación matemática o una invocación de función.

Para separar instrucciones dentro de un bloque de código, se utiliza el operador de secuenciación `;` (punto y coma). Este operador indica el final de una instrucción y el comienzo de la siguiente.

**Sintaxis:**
```
Instruccion_1;
Instruccion_2;
```
>[!IMPORTANT]
> Si se omite el `;`, el compilador generará un error de sintaxis. ¡No busques peos!

### **Declaración**
La declaración en Mango Bajito es el proceso mediante el cual se introduce una nueva variable o constante en el programa. Cada variable o constante tiene un identificador único que sigue un conjunto de reglas sintácticas y semánticas para garantizar la claridad y consistencia del código.

#### *Reglas para nombres de variables y constantes*
En Mango Bajito, los identificadores (`nombres de variables` y `constantes`) deben cumplir con las siguientes reglas:

* Se permite `camelCase` y `snake_case`:
  * `camelCase`: La primera palabra inicia en minúscula y las siguientes con mayúscula. 
	
	Ejemplo: miVariable, contadorUsuarios.

  * `snake_case`: Las palabras se separan con guiones bajos `_`. 
  	
	Ejemplo: mi_variable, contador_usuarios.

* El nombre puede comenzar con una letra mayúscula o minúscula:
	
	Ejemplo: UsuarioActivo, persona, nombre_completo, saldoCuenta.

* No se permiten símbolos especiales en el nombre:

	❌ Prohibidos: + - * / & % $ | ( ) [ ] { } ^ # @ ! ¡ = ¿ ? \ ~ " ' ` < > , .

	Ejemplos inválidos: precio$, mi-variable, 123dato, nombre@correo.

* No se pueden usar números al inicio del nombre:
	
	❌ Inválido: 123valor, 9edad.

	✅ Válido: valor123, edad9.

* Deben ser únicas dentro de su ámbito:
	No se pueden declarar dos variables con el mismo nombre en el mismo alcance de código.

* Deben evitar colisión con palabras clave del lenguaje:
	No se puede declarar una variable con un nombre reservado como `culito`, `jeva`, `rescata`, `si_es_asi`, etc.

#### *Variable*
Las variables en Mango Bajito son identificadores que pueden cambiar su valor durante la ejecución del programa. Se declaran usando la palabra clave `culito`, seguida del nombre de la variable y el tipo. Establecer un valor en la declaración es opcional.

**Sintaxis:**
```
culito <nombre de variable> : tipo;
culito <nombre de variable> : tipo = valor;
```
>[!IMPORTANT]
> Reglas para las variables
> * Pueden cambiar de valor mediante asignación.
> * Deben ser declaradas antes de su uso.
> * No pueden cambiar de tipo después de declaradas en el mismo alcance.

#### *Constante*
Las constantes son identificadores cuyo valor no puede ser modificado después de su declaración. Se declaran con la palabra clave `jeva`, seguida del nombre, tipo y su valor obligatorio.

**Sintaxis:**
```
jeva <nombre de variable> : tipo = valor;
```
>[!IMPORTANT]
> Reglas para las constantes
> * Deben ser inicializadas en el momento de su declaración.
> * No pueden ser modificadas posteriormente.

### **Asignación**
La asignación en Mango Bajito se realiza con el operador `=`. Se usa para almacenar un valor en una variable o constante previamente declarada. La asignación evalúa la expresión a la derecha del `=` y almacena el resultado en la variable a la izquierda.

**Sintaxis:**
```
<tipo de declaracion> <nombre de variable> : <tipo> = <expresión>;
```

### **Selección**
La estructura de `selección` en Mango Bajito permite ejecutar diferentes bloques de código en función de condiciones `booleanas`. Se utiliza la palabra clave `si_es_asi`, junto con `o_asi` para manejar condiciones alternativas y `nojoda` para el caso por defecto.

**Sintaxis:**
```
si_es_asi <Condicion_1> {
	Instrucciones;
} o_asi <Condicion_2> {
	Instrucciones;
} nojoda {
	Instrucciones;
}
```
>[!NOTE]
> Consideraciones
> * `si_es_asi`: Evalúa una condición. Si es `Sisa` (verdadero), ejecuta el bloque de código.
> * `o_asi`: (Opcional) Se usa para evaluar una segunda condición si la primera es `Nolsa` (falsa).
> * `nojoda`: (Opcional) Se ejecuta solo si todas las condiciones anteriores son `Nolsa`.

### **Repetición**
En Mango Bajito, las estructuras de repetición permiten ejecutar un bloque de código múltiples veces. Existen dos tipos:
* Bucle determinado (`repite_burda`) → Se usa cuando se conoce la cantidad exacta de iteraciones.
* Bucle indeterminado (`echale_bolas_si`) → Se ejecuta mientras una condición sea `Sisa`.

#### *Bucle for (`repite_burda`)*
Se usa para repetir un bloque de código un número específico de veces. Se define con las palabras clave `repite_burda`/`entre`/`hasta`. Si se quiere que el bucle itere en un paso en concreto, se debe usar la instrucción `repite_burda`/`entre`/`hasta`/`con_flow`.

**Sintaxis:**
```
# Ciclo determinado con paso 1 (por defecto)
repite_burda [variable : mango] entre [inicio : mango] hasta [fin : mango] {
    Instrucciones;
}

# Ciclo determinado con paso especificado 
repite_burda [variable : mango] entre [inicio : mango] hasta [fin : mango] con_flow [paso : mango] {
    Instrucciones;
}
```
>[!NOTE]
> Consideraciones
> * `variable`: Es el contador del bucle.
> * `entre` y `hasta`: Especifican el rango del bucle (incluye el valor inicial, excluye el final).
> * `con_flow`: Define el incremento en cada iteración (puede ser negativo para iterar en reversa).
> 	* Si se quiere hacer una iteración en reversa, entonces el valor especificado en `entre` debe ser mayor que el especificado en `hasta` 

#### *Bucle while (`echale_bolas_si`)*
Se usa cuando el número de iteraciones es desconocido y depende de una condición booleana.

**Sintaxis:**
```
echale_bolas_si <Condicion> {
	Instrucciones;
}
```
El bloque se ejecuta mientras la condición sea `Sisa`. Si la condición es `Nolsa` desde el inicio, el bucle nunca se ejecuta.

#### *Control del flujo en Bucles*
Mango Bajito proporciona dos palabras clave para controlar el flujo de ejecución dentro de los bucles:

* **Salir de un Bucle (`uy_kieto`)**
  
	🔹 `uy_kieto` finaliza inmediatamente la ejecución del bucle en curso.

	🔹 No se ejecutarán más iteraciones, aunque la condición del bucle aún sea `Sisa`

	**Sintaxis:**
	```
	# Para ciclo `echale_bolas_si`
	echale_bolas_si <Condicion> {
		Instrucciones;
		uy_kieto;	# Con esto se sale del ciclo
	}

	# Para ciclo `repite_burda`
	repite_burda [variable : mango] entre [inicio : mango] hasta [fin : mango] {
    	Instrucciones;
		uy_kieto;	# Con esto se sale del ciclo
	}
	```
* **Saltar una Iteración (`rotalo`)**

	🔹 `rotalo` salta la iteración actual y continúa con la siguiente.
	
	🔹 Se usa cuando queremos omitir ciertos valores dentro de un bucle sin interrumpir su ejecución completa.

	**Sintaxis:**
	```
	# Para ciclo `echale_bolas_si`
	echale_bolas_si <Condicion> {
		Instrucciones1;
		rotalo;		# Con esto se avanca a la siguiente iteracion ignorando Instrucciones2
		Instrucciones2;
	}

	# Para ciclo `repite_burda`
	repite_burda [variable : mango] entre [inicio : mango] hasta [fin : mango] {
    	Instrucciones1;
		rotalo;		# Con esto se avanca a la siguiente iteracion ignorando Instrucciones2
		Instrucciones2;
	}
	```

## 🥭**Tipos de Datos**

### **Escalares**

#### *Caracteres* (`negro`)
El tipo `negro` se utiliza para almacenar caracteres individuales, como letras, dígitos o símbolos. Es equivalente al tipo `char` en otros lenguajes de programación.

**Ejemplo:**
```
jeva letra: negro = 'A';
culito simbolo: negro = '$';
```

#### *Enteros* (`mango`)
El tipo `mango` representa números enteros, positivos o negativos, dentro de un rango de 32 bits (números entre -2.147.483.648 y 2.147.483.647). Es ideal para contadores, índices y cálculos discretos.

**Ejemplo:**
```
culito edad: mango = 25;
culito contador: mango = -10;
```

#### *Flotantes* (`manguita`)
El tipo `manguita` se utiliza para representar números en coma flotante de precisión simple entre 1.18e-38 hasta 3.40e38, adecuados para cálculos donde no se requiere una precisión extremadamente alta.

**Ejemplo:**
```
culito temperatura: manguita = 36.7;
jeva precio: manguita = 12.50;
```

#### *Doubles* (`manguangua`)
El tipo `manguangua` se utiliza para números en coma flotante con doble precisión entre 2.23e-308 hasta 1.79e308, siendo más adecuado para cálculos científicos o situaciones que requieren alta precisión en operaciones decimales.

**Ejemplo:**
```
jeva pi: manguangua = 3.14159265359;
culito distancia: manguangua = 1.989e30;
```

#### *Booleanos* (`tas_claro`)
El tipo `tas_claro` representa valores lógicos, con dos valores posibles: `Sisa` (equivalente a `True`) y `Nolsa` (equivalente a `False`).
Este tipo es ampliamente utilizado en estructuras condicionales y bucles para controlar el flujo del programa.

**Ejemplo:**
```
culito esMayor: tas_claro = Sisa;
culito esPar: tas_claro = Nolsa;
```
> [!IMPORTANT]
> Consideraciones
> - Mango Bajito **NO** realiza conversiones implícitas entre tipos de datos escalares. Por ejemplo, no se puede asignar un `manguangua` 
a un `mango` sin una conversión explícita. Esto refuerza su sistema de tipos fuertes.
> - Los valores por defecto al declarar variables sin inicializar son:
>    - `negro`: '\0' (carácter nulo)
>    - `mango`: 0
>    - `manguita` y `manguangua`: 0.0
>    - `tas_claro`: Nolsa

### **Compuestos**

#### *Cadena de Caracteres* (`higuerote`)
El tipo `higuerote` se utiliza para representar cadenas de texto. Una cadena es un arreglo de caracteres (de tipo `negro`) mutables en tamaño y caracteres de la cadena, ideal para manejar palabras, frases o cualquier dato textual. 

**Ejemplo:**
```
jeva saludo: higuerote = "Hola, chamo";
culito mensaje: higuerote = "Esto es Mango Bajito";
```
#### *Arreglos*
Los arreglos permiten almacenar múltiples elementos del mismo tipo en una estructura indexada. Se definen utilizando el tipo de los elementos seguido de `[tamaño]` en corchetes, donde `tamaño : mango` es el número de elementos en el arreglo y debe ser estrictamente positivo.

**Ejemplo:**
```
culito numeros: mango[4] = [1, 2, 3, 4];
culito saludos: higuerote[3] = ["Hola", "Mango", "Bajito"];
```
Los arreglos son de tamaño fijo y los índices comienzan en 0, siendo posible acceder y modificar elementos usando corchetes:
```
numeros[0] = 10;  # Cambia el primer elemento del arreglo a 10
culito numero : mango = numeros[0];    # Extraer el primer elemento del arrglo.
```

#### *Registros* (`arroz_con_mango`)
El tipo `arroz_con_mango` es una estructura que permite agrupar múltiples variables de diferentes tipos bajo un mismo nombre. Es útil para representar objetos o datos relacionados. Se define utilizando la palabra clave `arroz_con_mango` seguida de una lista de pares de nombre y tipo dentro de llaves. El acceso a los atributos de este registro es mediante el simbolo punto `.`. 

**Ejemplo:**
```
arroz_con_mango Persona {
	jeva nombre: higuerote;
	culito edad: mango;
	culito estudiante: tas_claro;
}

culito juan : Persona = { "Juan Pérez", 25, Sisa };
rescata(juan.nombre);  # Imprime: Juan Pérez
```

> [!IMPORTANT]
> Consideraciones
> 
> Cuando un miembro de un `arroz_con_mango` es un `ahi_ta` a otro registro, se debe utilizar `->` en lugar de `.` para acceder a los atributos del apuntador.
> 
> **Ejemplo:**
> ```
> arroz_con_mango Persona {
> 	jeva nombre : higuerote;
> 	culito edad : mango;
> }
>
> arroz_con_mango Nodo {
> 	ahi_ta jeva datos : Persona;
> 	ahi_ta culito siguiente : Nodo;
> }
>
> # Declaración e inicialización
> ahi_ta nodo : Nodo = cero_km Nodo;
> nodo->datos = cero_km Persona("Juan", 25);
>
> # Acceso a miembros del registro a través del puntero
> rescata(nodo->datos->nombre);  # Correcto
> rescata(nodo->datos->edad);    # Correcto
> ```
> Ver [Apuntadores](#apuntadores)

#### *Variantes* (`coliao`)
El tipo `coliao` en Mango Bajito representa una estructura de datos que puede contener valores de distintos tipos, **uno a la vez**, reutilizando el mismo espacio de memoria. Un `coliao` se define especificando los miembros de los distintos tipos de datos que puede contener separados por punto y coma (`;`). Este enfoque permite manejar datos que pueden variar en tipo, pero sin desperdiciar memoria. 

**Ejemplo:**
```
coliao zaperoco {
	a : mango;
	b : manguita;
	c : manguangua;
	d : tas_claro;
	e : mango[5];
}
```
El acceso al valor almacenado en el `coliao` debe hacerse con precaución, verificando qué tipo está actualmente activo.
```
arroz_con_mango Persona {
	jeva nombre : higuerote;
	culito edad : mango;
};

coliao MiVariante {
	a : mango;
	p : Persona;
};

# Declarar e inicializar
culito datos : MiVariante;

# Asignamos un valor del tipo `mango`
datos.a = 42;
rescata(datos.a);  # Resultado: 42

# Ahora asignamos un registro del tipo `Persona`
Persona alguien = { "Juan Pérez", 25 };
datos = alguien;

# Accedemos al registro dentro del coliao
rescata(datos.p.nombre);  # Resultado: Juan Pérez
rescata(datos.p.edad);    # Resultado: 25
```

### **Void** (`un_coño`)
El tipo `un_coño` indica que una función no retorna ningún valor. Es equivalente al tipo `void` en otros lenguajes. Se utiliza principalmente para procedimientos o funciones que ejecutan acciones sin devolver datos. Ver el apartado de [Funciones](#funciones).

### **Error** (`caramba_ñero`)
El tipo `caramba_ñero` es un registro (`arroz_con_mango`) predefinido, con los siguientes campos:
```
arroz_con_mango caramba_ñero {
	jeva codigo : mango; 		# Código de error único
	jeva mensaje : higuerote;	# Descripción del error
	jeva origen : higuerote;	# Módulo o función donde ocurrió el error
}
```
En Mango Bajito existen errores predefinidos y una definición previa de códigos:

|    Codigo    |         Nombre         |                        Descripción                       |
| :----------: | :--------------------: | :------------------------------------------------------: |
|     49       | Pal pana               | El usuario puede personalizar el error con un mensaje.   |
|     94       | Escribe bien esa vaina | No sigue las reglas gramaticales del lenguaje.           |
|     58       | Te patina el coco      | Realizar una operación con tipos de datos incompatibles. |
|     85       | Divideme esta          | Cuando se trata de dividir por 0.                        | 
|     67       | No hay más pa' ti      | El sistema de memoria está agotado.                      |
|     76       | Pelaste el hueco       | Acceder a índices fuera del rango.                       |
|    139       | Leete esta             | Intentar abrir un archivo que no existe.                 |
|    193       | Apunta bien vale       | Referencias a punteros nulos o None.                     |
|    391       | No la veo wn           | Usar una variable antes de declararla.                   |
|    319       | Llamando a tu novia    | Llamar a una función inexistente.                        |
|    913       | Te pasaste loco        | Desbordamiento numérico (overflow).                      |
|    931       | Libera al preso        | No haber liberado memoria (`borradol`) a un `cero_km`.   |

### **Apuntadores**

#### *Asignación de Memoria y Creación de Apuntadores* (`cero_km`)
La palabra clave `cero_km` se usa para reservar espacio en el heap y asignar un valor inicial. Es equivalente a `new` en otros lenguajes.
Los apuntadores (`ahi_ta`) permiten hacer referencia a valores en memoria dinámica (heap). Se usan para manejar estructuras dinámicas o referencias indirectas.

**Sintaxis:**
```
ahi_ta <nombre de apuntador> : <tipo> = cero_km <tipo>(valor);	# Asignacion de valor a la direccion de memoria directamente
ahi_ta <nombre de apuntador> : <tipo> = cero_km <tipo>;			# Solo reservacion de memoria
ahi_ta <nombre de apuntador> : <tipo> = cero_km <tipo>[tamaño];	# Solo reservacion de memoria (arreglos)
```

>[!NOTE]
> Consideraciones
> * `cero_km` devuelve un apuntador (`ahi_ta`) que referencia el espacio de memoria asignado.
> * Mango Bajito <u><strong>NO</strong></u> permite aritmética de apuntadores para mantener la seguridad de memoria.
> * Las reglas para `nombre de apuntador` son las mismas que [Reglas para nombres de variables](#reglas-para-nombres-de-variables-y-constantes)

#### *Acceso* (`aki_toy`)

Para acceder al valor almacenado en la memoria referenciada por un `ahi_ta`, se usa la palabra clave `aki_toy`.

**Sintaxis:**
```
aki_toy <nombre de apuntador>;
aki_toy <nombre de apuntador>.<atributo>;	# En caso de arroz_con_mango o coliao
```
 
#### *Liberación de Memoría* (`borradol`)

La palabra clave `borradol` se usa para liberar la memoria previamente reservada con `cero_km`, evitando fugas de memoria. Es equivalente a `free` o `delete` en otros lenguajes.

**Sintaxis:**
```
borradol <nombre de apuntador>;
borradol <nombre de apuntador>.<atributo>;
```
> [!IMPORTANT]
> ⚠️Intentar acceder a `aki_toy <nombre de apuntador>` después de liberar la memoría resultará en un error "Apunta bien vale"

#### *Valor NULL*
El valor NULL se representa mediante la palabra clave `pelabola`. Esta constante especial indica que un apuntador (`ahi_ta`) no está asignado a ninguna dirección de memoria válida. Intentar acceder a un `ahi_ta` que contiene `pelabola` generará un error de ejecución.

**Sintaxis:**
```
ahi_ta <nombre de apuntador>: <tipo> = no_hay_mango;  # Apuntador sin asignar
```

## 🥭**Procedimientos y Funciones**
Las funciones permiten recibir parámetros y retornar un valor (opcional). Se definen con la palabra clave `echar_cuento`, seguida del nombre, los parámetros y el tipo de retorno usando `lanza`. Para devolver el valor se utiliza la palabra clave `lanzate`.

**Sintaxis:**
```
echar_cuento <nombre de funcion>(<lista de parametros>) lanza <tipo> {
    Instrucciones;
    lanzate <valor de retorno>;
}
```
> [!IMPORTANT]
> Consideraciones
> * `nombre de funcion`: Nombre único de la función. Este nombre sigue
> * `lista de parametros`: Lista de valores que recibe la función separados por coma y cada uno con su tipo.
> * `tipo`: Define el tipo de dato que devuelve la función.
> * `lanzate <valor de retorno>`: Retorna un valor del tipo especificado.

### **Función sin retorno (Procedimiento)**
Si la función no necesita devolver nada, se usa utiliza `un_coño` como tipo de retorno:

**Sintaxis:**
```
echar_cuento <nombre de funcion>(<lista de parametros>) lanza un_coño {
    Instrucciones;
}
```
> [!NOTE]
> Si se trata de un procedimiento, no es necesario el `lanzate <valor de retorno>`, de lo contrario habrá un error. Sin embargo se
> puede usar `lanzate` para cortar el flujo de la función:
>
> ```
> echar_cuento <nombre de funcion>(<lista de parametros>) lanza un_coño {
>	Instrucciones1;
>	lanzate;	# Detiene el flujo del procedimiento, ignorando Instrucciones2
>	Instrucciones2;
> }
> ```

### **Pasaje de parámetros**

#### *Por valor*
Se admite el pasaje de todos los tipos de datos escalares (`negro`, `mango`, `manguita`, `manguangua`, `tas_claro`). Esto significa que los cambios dentro de la función no afectan la variable original.

**Sintaxis:**
```
echar_cuento <nombre de funcion>(<param_1 : tipo_1>, <param_2 : tipo_2>, ...) lanza <tipo> {
	Instrucciones;
}
```

#### *Por referencia*
Para modificar directamente una variable dentro de una función, se pasa por referencia usando la palabra clave `aki_toy`. Esto permite que la función modifique el valor de la variable original. Se admite el pasaje de todos los tipos de datos escalares (`negro`, `mango`, `manguita`, `manguangua`, `tas_claro`) y compuestos (`higuerotes`, `arreglos`, `registros`, `variantes`).

**Sintaxis:**
```
echar_cuento <nombre de funcion>(<aki_toy param_1 : tipo_1>, ...) lanza <tipo> {
	Instrucciones;
}
```
> [!IMPORTANT]
> Reglas para el pasaje por referencia:
> * Solo se puede usar con variables (`culito`), no con constantes (`jeva`).
> * No se puede pasar expresiones o valores literales
> ```
> incrementar(aki_toy 5);  # ❌ Error: no se puede pasar un literal
> ```

### **Procedimientos y Funciones del Lenguaje**
Mango Bajito proporciona varias funciones y procedimientos predefinidos para facilitar el desarrollo.

#### *Entrada y Salida*
* `rescata`

	Imprime el valor de una variable o constante en la consola.

	**Definición:**
	```
	rescata (<variable o constante>) lanza un_coño;
	```

	**Sintaxis:**
	```
	rescata(<variable o constante>);
	```

* `hablame`

	Permite recibir entrada desde el usuario con posibilidad (opcional) de mostrar un mensaje.

	**Definición:**
	```
	hablame (mensage : higuerote) lanza higuerote;
	```

	**Sintaxis:**
	```
	<`culito` o `jeva`> <nombre de variable> : higuerote = hablame("Texto");
	```

#### *Manipulación de Tipos*

* `que_monda_ejesa`

	Devuelve el tipo de dato de una variable en formato de texto.

	**Definición:**
	```
	que_monda_ejesa (param : <tipo>) lanza higuerote;
	```

	**Sintaxis:**
	```
	<`culito` o `jeva`> <nombre de variable> : higuerote = que_monda_ejesa(<variable o constante>);
	```

#### *Excepciones*

* `ah_vaina`

	Genera un error con un mensaje personalizado.

	**Definición:**
	```
	ah_vaina (param : higuerote) lanza caramba_ñero;
	```

	**Sintaxis:**
	```
	ah_vaina("texto personalizado");
	```

#### *Manipulación de Arreglos y Cadenas*

* `pegao`

	Concatena dos cadenas de caracteres (`higuerote`) y forma una nueva.

	**Definición:**
	```
	pegao(aki_toy cadena_1 : higuerote, aki_toy cadena_2 : higuerote) lanza higuerote;
	```
	**Sintaxis:**
	```
	<culito o jeva> <nombre de variable> : higuerote = pegao(cadena_1, cadena_2);
	```

* `maelo`

	Repite una cadena de caracteres (`higuerote`) un número de veces indicado. (Referencia a 'Otra vez Maelo Ruiz')

	**Definición:**
	```
	maelo(aki_toy cadena : higuerote, repetidor : mango) lanza higuerote;
	```

	**Sintaxis:**
	```
	<culito o jeva> <nombre de variable> : higuerote = maelo(cadena, repetidor);
	```
* `me_mide`

	Devuelve la longitud de una cadena de caracteres (`higuerote`)

	**Definición**
	```
	me_mide(aki_toy cadena: higuerote) lanza mango;
	```
	**Sintaxis**
	```
	<culito o jeva> <nombre de la variable> : mango = me_mide(cadena);
	```
* `rellenamelo`

	Inicializa un arreglo con elementos de un valor determinado.

	**Definición**
	```
	rellenamelo(aki_toy arreglo: <tipo>[tamaño], valor: <tipo>) lanza un_coño;
	```
	**Sintaxis**
	```
	# Todos los elementos del arreglo serán inicializados como <valor>

	culito <nombre_arreglo> : <tipo>[tamaño]; 
	
	rellenamelo(<nombre_arreglo>, <valor>);
	```
    > [!IMPORTANT]
    > Consideraciones
    > * Solo los arreglos declarados como `culito` pueden ser inicializados con esta función.
    > * El `<valor>` para inicializar debe ser correspondiente con el `<tipo>` declarado del arreglo.

## 🥭**Manejo de Errores**
En Mango Bajito, el manejo de errores se implementa mediante los bloques `meando` y `fuera_del_perol`, que permiten capturar y gestionar excepciones de manera estructurada.
```
meando {
	Instrucciones;
	ah_vaina("Mensaje personalizado");
} fuera_del_perol (error : caramba_ñero) {
	Instrucciones;
}
```
>[!NOTE]
> Consideraciones
> * `meando`: Bloque de código que se ejecutará normalmente, pero que puede lanzar errores.
> * `fuera_del_perol`: Bloque de código que se ejecuta si ocurre un error dentro de meando.
> * `error`: Variable de tipo `caramba_ñero` que contiene detalles del error capturado. Para mas informacion ver [Error](#error-caramba_ñero)
> * `ah_vaina`: Función para generar errores personalizados. Para mas información ver [Excepciones](#excepciones).

## 🥭**Operadores**

### **Lógicos**
Los operadores lógicos en Mango Bajito permiten realizar comparaciones y operaciones booleanas de manera expresiva y directa:

#### *Equal* (`igualito`)

El operador `igualito` compara si dos valores son iguales. Retorna `Sisa` si los valores son iguales y `Nolsa` en caso contrario.

**Ejemplo:**
```
culito esIgual : tas_claro = 5 igualito 5;  # Resultado: Sisa
```

#### *NotEqual* (`nie`)

El operador `nie` compara si dos valores son diferentes. Retorna `Sisa` si los valores son distintos y `Nolsa` en caso contrario.

**Ejemplo:**
```
culito esDistinto : tas_claro = 5 nie 3;  # Resultado: Sisa
```

#### *And* (`yunta`)

El operador `yunta` retorna Sisa si ambos operandos son Sisa; de lo contrario, retorna `Nolsa`.

**Ejemplo:**
```
culito esVerdad : tas_claro = (5 igualito 5) yunta (3 nie 4);  # Resultado: Sisa
```

#### *Or* (`o_sea`)

El operador `o_sea` retorna Sisa si al menos uno de los operandos es Sisa; de lo contrario, retorna `Nolsa`.

**Ejemplo:**
```
culito esCierto : tas_claro  = (5 nie 5) o_sea (3 igualito 4);  # Resultado: Nolsa
```

#### *Not* (`nelson`)

El operador `nelson` invierte el valor lógico de un operando.

**Ejemplo:**
```
culito esFalso : tas_claro = nelson (5 igualito 3);  # Resultado: Sisa
```

### **Aritméticos**
Los operadores aritméticos se utilizan para realizar cálculos matemáticos de manera intuitiva:

#### *Suma* (+)

Realiza la suma de dos valores numéricos.

**Ejemplo:**
```
culito resultado1 : mango = 5 + 3;  # Resultado: 8
culito resultado2 : manguita = 1.29 + 0.71;  # Resultado: 2.0
culito resultado3 : manguangua = 1.989e30 + 1.502e29 = 2.1392e30
```

#### *Resta* (-)

Realiza la resta de dos valores numéricos.

**Ejemplo:**
```
culito resultado1 : mango = 5 - 3;  # Resultado: 2
culito resultado2 : manguita = 1.29 - 0.71;  # Resultado: 0.58
culito resultado3 : manguangua = 1.989e30 - 1.502e29 = 1.8388e30
```

#### *Multiplicación* (*)

Realiza la multiplicación de dos valores numéricos.

**Ejemplo:**
```
culito resultado1 : mango = 5 * 3;  # Resultado: 15
culito resultado2 : manguita = 1.29 * 0.71;  # Resultado: 0.9159
culito resultado3 : manguangua = 1.989e30 * 1.502e29 # Resultado: 2.987478e59
```

#### *División Entera* (//)

Realiza la división entre dos valores, truncando el resultado a un entero.

**Ejemplo:**
```
culito resultado1 : mango = 10 // 3;  # Resultado: 3
culito resultado2 : mango = 10 // 2.5; # Resultado: 4
culito resultado3 : mango = 1.989e30 // 1.502e29 # Resultado: 13
```

#### *División Decimal* (/)

Realiza la división entre dos valores, retornando un resultado en coma flotante.

**Ejemplo:**
```
culito resultado1 : manguangua = 10 / 3; # Resultado: 3.3333...
culito resultado2 : manguita = 10 / 2.5; # Resultado: 4.0
culito resultado3 : manguita = 1.989e30 / 1.502e29 # Resultado: 13.249
```

#### *Potenciación* (**)

Eleva un valor a la potencia especificada.

**Ejemplo:**
```
culito resultado1 : mango = 2 ** 3;  # Resultado: 8
culito resultado2 : manguita = 2 ** 0.5; # Resultado: 1.4142...
culito resultado3 : manguangua = 1.989e30 ** 0.5 # Resultado: 1.4142e15
```

#### *Incremento* (++)

Incrementa el valor de una variable en 1.

**Ejemplo:**
```
culito numero : mango = 5;
numero++;
rescata(numero);  # Imprime: 6
```
#### *Decremento* (--)

Disminuye el valor de una variable en 1.

**Ejemplo:**
```
culito numero : mango = 5;
numero--;
rescata(numero);  # Imprime: 4
```
#### *Asignación aditiva* (+=)

Suma un valor al existente en la variable.

**Ejemplo:**
```
culito numero : mango = 5;
numero += 3;  # Resultado: 8
rescata(numero); # Imprime: 8
```
#### *Asignación sustractiva* (-=)

Resta un valor al existente en la variable.

**Ejemplo:**
```
culito numero : mango = 5;
numero -= 3;  # Resultado: 2
rescata(numero); # Imprime: 2
```
#### *Asignación multiplicativa* (*=)

Multiplica un valor al existente en la variable.

**Ejemplo:**
```
culito numero : mango = 5;
numero *= 3;  # Resultado: 15
rescata(numero); # Imprime: 15
```
## 🥭**Conversión de Tipos de Datos**
Mango Bajito permite conversiones explícitas entre tipos para garantizar que las operaciones sean claras y controladas.

**Sintaxis:**
```
(<tipo>)<nombre de variable>
```
> [!NOTE]
> Consideraciones
> * Para el campo `<nombre de variable>` se pueden usar expresión literales(un `mango`, `manguangua`, etc) Ej. `(higuerote)123 -> "123"`.
> * Mango Bajito no permite conversiones implícitas que puedan dar lugar a pérdida de datos o ambigüedad. 
> 	*	Por ejemplo, convertir un manguangua a un mango requiere una conversión explícita para evitar errores inesperados.

Conversiones soportadas:
* **De `negro` hacia:** 
  * `mango`: Si es del '0' a '9' conversion literal, cualquier otro simbolo será su numero en sistema ASCII.
* **De `mango` hacia:**
  * `manguita`
  * `manguangua`
  * `higuerote`
  * `negro`: Si se habla de los números de un dígito (0 al 9).
* **De `manguita` hacia:**
  * `mango`
  * `manguangua`
  * `higuerote`
* **De `manguangua` hacia:**
  * `mango`
  * `manguita`
  * `higuerote`
* **De `higuerote` hacia:**
  * `mango`: Siempre y cuando la cadena sea el formato del número esperado. (Ej. "123")
  * `manguita`: Siempre y cuando la cadena sea el formato del número esperado. (Ej. "1.23")
  * `manguangua`: Simpre y cuando la cadena sea el formato del numero esperado. (Ej. "1.23e-10")