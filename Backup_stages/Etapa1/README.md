# Etapa 1 - Definición del Lenguaje MangoBajito

Para esta primera etapa de construcion del lenguaje MangoBajito se quiere que se tengan las siguientes condiciones

- Ser imperativo.
- Alcance estático con anidamiento arbitrario de bloques.
- Sistema de tipos fuerte con verificación estática.
- Tipos escalares:
  - Caracteres
  - Enteros
  - Booleanos
  - Flotantes
- Tipos compuestos:
  - Arreglos
  - Cadenas de caracteres
  - Registros
  - Variantes
- Apuntadores (sólo al heap)
- Algún mecanismo de selección
- Algún mecanismo de repetición
  - Determinada
  - Indeterminada
- Subrutinas
  - Procedimientos
  - Funciones (retornos escalares)
  - Pasaje de parámetros
    - Por valor
    - Por referencia
  - Recursión

¡Y cualquier cosa que se quiera adicional!
>[!NOTE]
> Reconendación sobre qué cosas NO incluir:
> * Manejo automático de memoria dinámica
> * Compilación separada
> * Subrutinas con clausuras
> * Orientación a Objetos
> * Polimorfismo paramétrico

Para esta primera etapa se quiere los siguientes elementos:
- Definición completa del lenguaje (escrita a modo de README en su repositorio). La definición debe ser completa (incluyendo estructuras de control de flujo, tipos de datos, subrutinas, etc). Imaginen un enunciado de traductores y más o menos así.
- Programas escritos en su lenguaje, incluyendo:
  - Hola mundo
  - Hola usuario (recibe un nombre de la entrada y saluda a ese nombre)
  - Sumar todos los números de la entrada hasta que se ingrese cero (0)
  - Cálculo del n-ésimo fibonacci (leyendo el entero de la entrada estándar)
  - Multiplicación de dos matrices, no necesariamente cuadradas
  - Implementación del algoritmo de Kruskal, incluyendo implementación de cola de prioridades y conjuntos disjuntos
  - Intérprete del lenguaje Brainf*ck ( https://esolangs.org/wiki/Brainfuck )

>[!IMPORTANT]
> La documentación e información correspondiente al lenguaje MangoBajito se encuentra ubicado en el [README](https://github.com/JMLTUnderCode/CI4721_MangoBajito/blob/main/README.md) del directorio principal de este [repositorio](https://github.com/JMLTUnderCode/CI4721_MangoBajito).
