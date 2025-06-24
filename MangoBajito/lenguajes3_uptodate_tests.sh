#!/bin/bash

# Define las secciones y los números de test a actualizar para valid
declare -A valid_tests
valid_tests["Apuntador"]=""
valid_tests["Bucle"]=""
valid_tests["Casteo"]=""
valid_tests["Condicional"]=""
valid_tests["Declaracion"]=""
valid_tests["Entrada_Salida"]=""
valid_tests["Funcion"]=""
valid_tests["Operacion"]=""
valid_tests["ManejoError"]=""

# Ruta base de los tests
BASE_DIR="tests/Lenguajes_III"

# Ejecutable
BIN="./mango_bajito"

# Actualizar tests válidos
for section in "${!valid_tests[@]}"; do
    echo "Actualizando sección válida: $section"
    for num in ${valid_tests[$section]}; do
        for mngfile in "$BASE_DIR/$section/valid/${num}"*.mng; do
            [ -e "$mngfile" ] || continue
            base=$(basename "$mngfile" .mng)
            outdir="$BASE_DIR/$section/valid/expected"
            mkdir -p "$outdir"
            outfile="$outdir/$base.out"
            echo "Actualizando $outfile"
            echo -e "s\ns\ns" | $BIN "$mngfile" > "$outfile"
        done
    done
done