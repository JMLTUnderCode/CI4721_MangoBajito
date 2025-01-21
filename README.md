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
    - [Tipos de Datos](#tipos-de-datos)
    - [Mecanismos](#mecanismos)
    - [Subrutinas](#subrutinas)
    - [Manejo de Errores](#manejo-de-errores)
  - [Ejemplos](#ejemplos)

## Preámbulo


## Definición
* Es imperativo
* Alcance estatico con anidamiento arbitrario de bloques
* sistema de tipos fuertes con verificacion estatica

### Tipos de Datos
* #### Escalares
  - #### Caracteres
    Se define con la palabra clave "`negro`".
    
  - #### Enteros
    Se define con la palabra clave "`mango`".

  - #### Flotantes:
    Se define con la palabra clave "`manguita`".
    
  - #### Double
    Se define con la palabra clave "`manguangua`".
    
  - #### Booleanos
    Se define con la palabra clave "`tas_claro`". Cuyos valores son "`Sisa`" para True y "`Nolsa`" para False.

* #### Compuestos
  - #### Arreglos
    Se define con el tipo de todos los elementos que estaran en el array seguido de []. Ejemplo:

    arr1: mango[]  = [1, 2, 3, 4]
    arr2: higuerote[] = ["hola", "chamo"]
    
  - #### Registros
    Se define con la palabra clave "`arroz_con_mango`".
    
  - #### Cadena de Caracteres
    Se define con la palabra clave "`higuerote`".
    
  - #### Variantes
    `vaina`
    `coroto`
    `negriados`
  - #### Apuntadores
    Se define con la palabra clave "`ahi_ta`". (sólo al heap)
    
* #### Void
  Se define con la palabra clave "`un_coño`".

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
    * `que_monda_ejesa(type var)`
      Permite retornar el tipo de dato que representa "`var`". Se caracteriza
      
    * `Ah_vaina(type guarimba)`
      Permite retornar un error con el contenido de "guarimba".

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
  Ah_vaina(type guarimba)
}
```

## Ejemplos


