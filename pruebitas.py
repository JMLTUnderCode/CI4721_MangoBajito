# primero
print("Hola mundp")
# rescata("Hola mundo")

# Segundo
nombre = input('')
print("Hola" + nombre)
# culito n: higuerote = hablame('nombre de usuario: ')
# rescata("Hola " + n)

# Sumar todos los números de la entrada hasta que se ingrese cero (0)
suma = 0
while True:
    numero = int(input(''))
    if numero == 0:
        break # borralo | uy_kieto
    suma = suma + numero

# culito suma: mango = 0
# culito n: mango
# echale_bolas_hasta Sisa:
#	n = mango(hablame(''))
#	si_es_asi n igualito 0 {
#	    uy_kieto	
#   }
#  suma = suma + n


# TODO:
# Definir la funcion largo

# Cálculo del n-ésimo fibonacci (leyendo el entero de la entrada estándar)
n = int(input(''))
a = 0

b = 1
for i in range(n):
    temp = a
    a = b
    b = temp + b

# jeva n: mango = mango(hablame(""))
# culito a: mango = 0
# culito b: mango = 1
# culito temp: mango

# repite_burda i entre 1 hasta n con_flow 1{
# temp = a;
# a = b;
# b = temp + b;
# }



# Multiplicación de dos matrices, no necesariamente cuadradas

filas_A = len(A)
columnas_A = len(A[0])
filas_B = len(B)
columnas_B = len(B[0])

if columnas_A != filas_B:
    raise ValueError("El número de columnas de A debe ser igual al número de filas de B")

# Inicializar la matriz resultado con ceros
C = [[0 for _ in range(columnas_B)] for _ in range(filas_A)]

# Multiplicar matrices
for i in range(filas_A):
    for j in range(columnas_B):
        for k in range(columnas_A):
            C[i][j] += A[i][k] * B[k][j]


