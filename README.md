# CI4721 - Lenguajes de Programación II - Mango Bajito
### Descripción
Repositorio asociado a la creación de un lenguaje de programación "Mango Bajito". Este proyecto nace bajo un ambiente académico proporcionado por la Universidad Simón Bolívar durante el trimestre Enero Marzo 2025 bajo la tutela del Prof. Ricardo Monascal en la materia CI4721 - Lenguajes de Programación II.
### Integrantes
* Astrid Alvarado, 18-10938
* Kenny Rojas, 
* Jhonaiker Blanco, 
* Junior Lara, 17-10303

## Índice
- [Preámbulo](#Preámbulo)
- [Definición](#Definición)
  - [Tipos de Datos](#Tipos-de-Datos)
    - [Escalares](#Escalares)
    - [Compuestos](#Compuestos)
    - [Void](#Void)
    - [Operaciones entre tipos de datos](#Operaciones-entre-tipos-de-datos)
    - [](#)
  - [Mecanismos](#Mecanismos)
    - [Instrucción](#Instrucción)
    - [Asignación](#Asignación)
    - [Declaración](#Declaración)
    - [Selección](#Selección)
    - [Repetición](#Repetición)
    - [](#)
  - [Subrutinas](#Subrutinas)
    - [Procedimientos](#Procedimientos)
      - [Procedimientos del Lenguaje](#Procedimientos-del-Lenguaje)
    - [Funciones](#Funciones)
    - [Recursión](#Recursión)
    - [](#)
  - [Manejo de Errores](#Manejo-de-Errores)
- [Ejemplos](#Ejemplos)
- [](#)

## Preámbulo


## Definición
* Es imperativo
* Alcance estatico con anidamiento arbitrario de bloques
* sistema de tipos fuertes con verificacion estatica

### Tipos de Datos
* #### Escalares
  - #### Caracteres
    Se define con la palabra clave "chamo".
    
  - #### Enteros
    Se define con la palabra clave "mango".

  - #### Flotantes:
    Se define con la palabra clave "manguita".
    
  - #### Double
    Se define con la palabra clave "manguangua".
    
  - #### Booleanos
    Se define con la palabra clave "tas_claro". Cuyos valores son "Sisa" para True y "Nolsa" para False.

* #### Compuestos
  - #### Arreglos
    Se define con la palabra clave "ta_cuadrao"
    
  - #### Registros
    Se define con la palabra clave "arroz_con_mango".
    
  - #### Cadena de Caracteres
    Se define con la palabra clave "guarimba".
    
  - #### Variantes
    (uniones)
    
  - #### Apuntadores
    (sólo al heap)
    
* #### Void
  Se define con la palabra clave "un_coño".

* #### Operadores
  * #### Lógicos
    - Equal
      Se define con la palabra clave "igualito".
    - NotEqual
      Se define con la palabra clave "negriado".
    - And
      Se define con la palabra clave "gua".
    - Or
      Se define con la palabra clave "".
    - Not
      Se define con la palabra clave "nie".
  * #### Aritméticos
    - Suma
      
    - Resta
      
    - Multiplicación
      
    - División
      - Entera
        
      - Decimal
        
    - Potenciación
      
  * #### 

* #### Operaciones entre tipos de datos

  
### Mecanismos
* #### Instrucción

  
* #### Asignación


* #### Declaración

    
* #### Selección
  Se define con la palabra "si_no_es"/"entonces_es"/"sino_esta".
  ```
  si_no_es Condicion {
    Instrucciones
  } entonces_es Condicion {
    Instrucciones
  } sino_esta {
    Instrucciones
  }
  ```
  
* #### Repetición
  * #### For
    Se define con la palabra clave "repite_burda"/"entre"/"hasta". (Determinada)
    ```
    repite_burda [var] entre [cota_inf] hasta [cota_sup] {
      Instrucciones
    }
    ```
    Donde
    * var pertenece a
    * cota_inf pertenece a
    * cota_sup pertenece a
    
    
  * #### While
    Se define con la palabra clave "echale_bolas_hasta". (Intederminada)
    ```
    echale_bolas_hasta Condicion {
      Instrucciones
    }
    ```
  
### Subrutinas
* #### Procedimientos
  Se define como ...

  * #### Procedimientos del Lenguaje
    * que_monda_ejesa(type var)
      Permite retornar el tipo de dato que representa "var". Se caracteriza
      
    * Ah_vaina(type guarimba)
      Permite retornar un error con el contenido de "guarimba".

* #### Funciones
  (retornos escalares)
  * #### Pasaje de parámetros
    * #### Por valor
   
      
    * #### Por referencia
   
      
* #### Recursión

### Manejo de Errores
Se define con el conjunto de palabras clave "meando"/"fuera_del_perol".
```
meando {
  Instrucciones
} fuera_del_perol {
  Ah_vaina(type guarimba)
}
```

## Ejemplos


