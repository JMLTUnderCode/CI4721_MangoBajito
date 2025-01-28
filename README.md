# CI4721 - Lenguajes de Programación II - Mango Bajito

## Descripción
Repositorio asociado a la creación de un lenguaje de programación "Mango Bajito". Este proyecto nace bajo un ambiente 
académico proporcionado por la Universidad Simón Bolívar durante el trimestre Enero Marzo 2025 bajo la tutela del 
Prof. Ricardo Monascal en la materia CI4721 - Lenguajes de Programación II.

## Integrantes
* Astrid Alvarado, 18-10938
* Kenny Rojas 18-10595, 
* Jhonaiker Blanco, 18-10
* Junior Lara, 17-10303

## Índice


## Preámbulo
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

## Definición
Mango Bajito es un lenguaje de programación imperativo, diseñado para facilitar la creación de software mediante 
un enfoque intuitivo y accesible. Este lenguaje se caracteriza por su simplicidad en la sintaxis, inspirada en la
jerga venezolana, y por su diseño estructurado, enfocado en reducir la complejidad del desarrollo. A continuación,
se detallan sus principales características computacionales:

### Características

* Se basa en el paradigma de programación imperativa, donde el flujo del programa se controla mediante declaraciones
explícitas que modifican el estado del sistema.

* Alcance estático con anidamiento arbitrario de bloques:
El lenguaje utiliza un modelo de alcance léxico estático, donde las variables y funciones son resueltas con base en 
el entorno donde fueron definidas, no donde son ejecutadas.

* Implementa un sistema de tipos fuertes, donde las operaciones entre tipos incompatibles son prevenidas por el 
lenguaje, evitando errores en tiempo de ejecución relacionados con conversiones implícitas o mal manejo de datos. 
Además, la verificación de tipos se realiza de forma estática, durante la fase de compilación, garantizando que 
el código sea consistente y seguro antes de ser ejecutado.

* Aunque no es estrictamente técnico, la sintaxis de Mango Bajito es intencionadamente sencilla y coloquial, con 
palabras clave diseñadas para ser intuitivas y fáciles de recordar. Esto hace que el lenguaje sea accesible para
programadores principiantes sin sacrificar las capacidades necesarias para desarrollos complejos.
  
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
  Se define con la palabra "`si_es_asi`"/"`y_asi`"/"`nojoda`".
  ```
  si_es_asi Condicion {
    Instrucciones
  } y_asi Condicion {
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
      
    * `ah_vaina(message)`
		Permite retornar un error con el contenido de "higuerote".

* #### Funciones
  (retornos escalares)

  ```
  echar_cuento <nombre>(<parametros>) lanza <type> {
    # Codigo
  }
  ```
  * #### Pasaje de parámetros
    * #### Por valor
    Los tipos de datos basicos Caracteres, Enteros, Flotantes, Double y Booleanos se pasaran a las funciones por valor, así como las Cadena de Caracteres.
      
    * #### Por referencia


### Manejo de Errores
Se define con el conjunto de palabras clave "`meando`"/"`fuera_del_perol`".
```
meando {
  Instrucciones
} fuera_del_perol {
  Ah_vaina(type higuerote)
}
```
### Tipos de Datos

#### Escalares
  - #### Caracteres (`negro`)
    El tipo `negro` se utiliza para almacenar caracteres individuales, como letras, dígitos o símbolos. Es equivalente al tipo `char` 
	en otros lenguajes de programación. Los valores deben definirse entre comillas simples.
	
	**Ejemplo:**
    ```
    jeva letra: negro = 'A';
    culito simbolo: negro = '$';
    ```

  - #### Enteros (`mango`)
	El tipo `mango` representa números enteros, positivos o negativos, dentro de un rango dependiente de la implementación del lenguaje 
	(normalmente 32 bits). Es ideal para contadores, índices y cálculos discretos.
	
	**Ejemplo:**
	```
	culito edad: mango = 25;
	culito contador: mango = -10;
	```

  - #### Flotantes (`manguita`)
	El tipo `manguita` se utiliza para representar números en coma flotante de precisión simple, adecuados para cálculos donde no se 
	requiere una precisión extremadamente alta.
	
	**Ejemplo:**
	```
	culito temperatura: manguita = 36.7;
	jeva precio: manguita = 12.50;
	```
    
  - #### Doubles (`manguangua`)
	El tipo `manguangua` se utiliza para números en coma flotante con doble precisión, siendo más adecuado para cálculos científicos 
	o situaciones que requieren alta precisión en operaciones decimales.
	
	**Ejemplo:**
	```
	jeva pi: manguangua = 3.14159265359;
	culito distancia: manguangua = 1.989e30;
	```

  - #### Booleanos (`tas_claro`)
	El tipo `tas_claro` representa valores lógicos, con dos valores posibles: Sisa (equivalente a True) y Nolsa (equivalente a False).
	Este tipo es ampliamente utilizado en estructuras condicionales y bucles para controlar el flujo del programa.
	
	**Ejemplo:**
	```
	culito esMayor: tas_claro = Sisa;
	culito esPar: tas_claro = Nolsa;
	```
	> [!IMPORTANT] IMPORTANTE
	> - Mango Bajito no realiza conversiones implícitas entre tipos de datos escalares. Por ejemplo, no se puede asignar un manguangua 
	a un mango sin una conversión explícita. Esto refuerza su sistema de tipos fuertes.
	> - Los valores por defecto al declarar variables sin inicializar son:
	>    - `negro`: '\0' (carácter nulo)
	>    - `mango`: 0
	>    - `manguita` y `manguangua`: 0.0
	>    - `tas_claro`: Nolsa
 
* #### Compuestos
  - #### Cadena de Caracteres (`higuerote`)
  	El tipo `higuerote` se utiliza para representar cadenas de texto. Una cadena es un arreglo inmutable de caracteres (de tipo `negro`), 
	ideal para manejar palabras, frases o cualquier dato textual. 
	
	**Ejemplo:**
  	```
  	jeva saludo: higuerote = "Hola, chamo";
  	jeva mensaje: higuerote = "Esto es Mango Bajito";
	```
  - #### Arreglos
	Los arreglos permiten almacenar múltiples elementos del mismo tipo en una estructura indexada. Se definen utilizando el tipo de los 
	elementos seguido de [tamaño] en corchetes, donde `tamaño : mango` es el número de elementos en el arreglo y debe ser estrictamente
	positivo.
	
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
    
  - #### Registros (`arroz_con_mango`)
	El tipo `arroz_con_mango` es una estructura que permite agrupar múltiples variables de diferentes tipos bajo un mismo nombre. 
	Es útil para representar objetos o datos relacionados. Se define utilizando la palabra clave `arroz_con_mango` seguida de una lista
	de pares de nombre y tipo dentro de llaves. El acceso a los atributos de este registro es mediante el simbolo punto `.`.

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

  - #### Variantes(`coliao`)
	El tipo `coliao` en Mango Bajito representa una estructura de datos que puede contener valores de distintos tipos, 
	**uno a la vez**, reutilizando el mismo espacio de memoria. Un `coliao` se define especificando los miembros de los
	distintos tipos de datos que puede contener separados por punto y coma. Este enfoque permite manejar datos que 
	pueden variar en tipo, pero sin desperdiciar memoria. 
	
	**Ejemplo:**
	```
	coliao zaperoco {
		a : mango;
		b : manguita;
		c : manguangua;
		d : tas_claro;
		e : arroz_con_mango;
		d : mango[5];
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

	# Accedemos al registro dentro del `coliao`
	rescata(datos.p.nombre);  # Resultado: Juan Pérez
	rescata(datos.p.edad);    # Resultado: 25
	```

  - #### Apuntadores (`ahi_ta`)
	Los apuntadores (`ahi_ta`) permiten hacer referencia a valores en memoria dinámica (heap). Se usan para manejar estructuras 
	dinámicas o referencias indirectas. Mango Bajito abstrae la complejidad del manejo de memoria para facilitar su uso.
	
	**Ejemplo:**
	```
	ahi_ta numero: mango = virgo mango(10);
	rescata(numero);  # Imprime: 10
	```
	>[!NOTE] Mango Bajito no permite aritmética de apuntadores para mantener la seguridad de memoria.
    
* #### Void (`un_coño`)
	El tipo `un_coño` indica que una función no retorna ningún valor. Es equivalente al tipo void en otros lenguajes. 
	Se utiliza principalmente para procedimientos o funciones que ejecutan acciones sin devolver datos.

	**Ejemplo:**
	```
	echar_cuento saluda() lanza un_coño{
		rescata("Hola, chamo!");
	}
	```

* #### Operadores
  * #### Lógicos
	Los operadores lógicos en Mango Bajito permiten realizar comparaciones y operaciones booleanas de manera expresiva y directa:
   
    - **Equal (`igualito`)**
		
		El operador `igualito` compara si dos valores son iguales. Retorna `Sisa` si los valores son iguales y `Nolsa` en caso contrario.
		
		**Ejemplo:**
  		```
		culito esIgual : tas_claro = 5 igualito 5;  # Resultado: Sisa
		```

    - **NotEqual (`nie`)**
		
		El operador `nie` compara si dos valores son diferentes. Retorna `Sisa` si los valores son distintos y `Nolsa` en caso contrario.
		
		**Ejemplo:**
		```
		culito esDistinto : tas_claro = 5 nie 3;  # Resultado: Sisa
		```

    - **And (`yunta`)**
		
		El operador `yunta` retorna Sisa si ambos operandos son Sisa; de lo contrario, retorna `Nolsa`.
		
		**Ejemplo:**
		```
		culito esVerdad : tas_claro = (5 igualito 5) yunta (3 nie 4);  # Resultado: Sisa
		```

    - **Or (`o_sea`) (debatible, se puede cambiar si es necesario)**
		
		El operador `o_sea` retorna Sisa si al menos uno de los operandos es Sisa; de lo contrario, retorna `Nolsa`.

		**Ejemplo:**
		```
		culito esCierto : tas_claro  = (5 nie 5) o_sea (3 igualito 4);  # Resultado: Nolsa
		```

    - **Not (`nelson`)**
		
		El operador `nelson` invierte el valor lógico de un operando.

		**Ejemplo:**
		```
		culito esFalso : tas_claro = nelson (5 igualito 3);  # Resultado: Sisa
		```

  * #### Aritméticos
	Los operadores aritméticos se utilizan para realizar cálculos matemáticos de manera intuitiva:

    - **Suma (+)**
	
		Realiza la suma de dos valores numéricos.
	
		**Ejemplo:**
		```
		culito resultado1 : mango = 5 + 3;  # Resultado: 8
		culito resultado2 : manguita = 1.29 + 0.71;  # Resultado: 2.0
		culito resultado3 : manguangua = 1.989e30 + 1.502e29 = 2.1392e30
		```

	- **Resta (-)**
	
		Realiza la resta de dos valores numéricos.
		
		**Ejemplo:**
		```
		culito resultado1 : mango = 5 - 3;  # Resultado: 2
		culito resultado2 : manguita = 1.29 - 0.71;  # Resultado: 0.58
		culito resultado3 : manguangua = 1.989e30 - 1.502e29 = 1.8388e30
		```
		
	- **Multiplicación (*)**
		
		Realiza la multiplicación de dos valores numéricos.

		**Ejemplo:**
		```
		culito resultado1 : mango = 5 * 3;  # Resultado: 15
		culito resultado2 : manguita = 1.29 * 0.71;  # Resultado: 0.9159
		culito resultado3 : manguangua = 1.989e30 * 1.502e29 # Resultado: 2.987478e59
		```

	- **División Entera (//)**
		
		Realiza la división entre dos valores, truncando el resultado a un entero.
		
		**Ejemplo:**
		```
		culito resultado1 : mango = 10 // 3;  # Resultado: 3
		culito resultado2 : mango = 10 // 2.5; # Resultado: 4
		culito resultado3 : mango = 1.989e30 // 1.502e29 # Resultado: 13
		```

	- **División Decimal (/)**
		
		Realiza la división entre dos valores, retornando un resultado en coma flotante.
		
		**Ejemplo:**
		```
		culito resultado1 : manguangua = 10 / 3; # Resultado: 3.3333...
		culito resultado2 : manguita = 10 / 2.5; # Resultado: 4.0
		culito resultado3 : manguita = 1.989e30 / 1.502e29 # Resultado: 13.249
		```

	- **Potenciación (**)**
		
		Eleva un valor a la potencia especificada.
		
		**Ejemplo:**
		```
		culito resultado1 : mango = 2 ** 3;  # Resultado: 8
		culito resultado2 : manguita = 2 ** 0.5; # Resultado: 1.4142...
		culito resultado3 : manguangua = 1.989e30 ** 0.5 # Resultado: 1.4142e15
		```

	- **Incremento (++)**
		
		Incrementa el valor de una variable en 1.
		
		**Ejemplo:**
		```
		culito numero : mango = 5;
		numero++;
		rescata(numero);  # Imprime: 6

	- **Asignación aditiva (+=)**
		
		Suma un valor al existente en la variable.
		
		**Ejemplo:**
		```
		culito numero : mango = 5;
		numero += 3;  # Resultado: 8
		rescata(numero); # Imprime: 8
		```
      
  * #### Caracteres
	Los operadores en Mango Bajito también están sobrecargados para trabajar con cadenas de caracteres de manera intuitiva:

	- **Concatenación de Cadenas de Caracteres (+)**

		Une dos cadenas en una sola.

		**Ejemplo:**
		```
		jeva saludo : higuerote = "Hola, " + "chamo";
		rescata(saludo);  # Imprime: Hola, chamo
		```

	- **Repetición de Cadenas de Caracteres (*)**

		Repite una cadena el número de veces indicado.
		
		**Ejemplo:**
		```
		jeva eco : higuerote = "Hola! " * 3;
		rescata(eco);  # Imprime: Hola! Hola! Hola!
		```

* #### Operaciones entre tipos de datos
	Mango Bajito permite conversiones explícitas entre tipos para garantizar que las operaciones sean claras y controladas. 
	Algunas de las operaciones soportadas incluyen:

	- **Conversión de mango a manguita o manguangua**

		Los números enteros pueden convertirse explícitamente a tipos en coma flotante:
		
		**Ejemplo:**
		```
		culito entero : mango = 5;
		culito decimal : manguangua = (manguangua)entero; # Resultado: 5.0
		```

	- **Conversión de `negro` (carácter) a `mango` (entero)**

		El valor ASCII de un carácter puede obtenerse explícitamente:
		
		**Ejemplo:**
		```
		culito letra : negro = 'A';
		culito valorASCII : mango = (mango)letra; # Resultado: 65
		```
		
	- **Conversión implícita en operaciones entre mango y manguita**

		En operaciones mixtas, el tipo entero se convierte automáticamente a flotante:

		**Ejemplo:**
		```
		culito resultado : manguita = 5 + 2.5;  # Resultado: 7.5
		```
	
	>[!NOTE] 
	> Mango Bajito no permite conversiones implícitas que puedan dar lugar a pérdida de datos o ambigüedad. 
	> Por ejemplo, convertir un manguangua a un mango requiere una conversión explícita para evitar errores inesperados.