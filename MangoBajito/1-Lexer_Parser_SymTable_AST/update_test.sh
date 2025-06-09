#!/bin/bash

# Define las secciones y los números de test a actualizar para valid
declare -A valid_tests
valid_tests["Bucle"]="00 02"
valid_tests["Condicional"]="00 01"
valid_tests["Declaracion"]="00 01 02 03 04 05 06 07 08 09 10 11 12 13"
valid_tests["Funcion"]="00 01 02"
valid_tests["Operacion"]="00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19"
valid_tests["ManejoError"]=""

# Define las secciones y los números de test a actualizar para errors
declare -A error_tests
error_tests["Bucle"]="00"
error_tests["Condicional"]="00"
error_tests["Declaracion"]=""
error_tests["Funcion"]="00 01 02"
error_tests["Operacion"]="16 17 18 19"
error_tests["ManejoError"]=""

# Ruta base de los tests
BASE_DIR="tests"

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
            echo -e "s\ns" | $BIN "$mngfile" > "$outfile"
        done
    done
done

# Actualizar tests de error
for section in "${!error_tests[@]}"; do
    echo "Actualizando sección de error: $section"
    for num in ${error_tests[$section]}; do
        for mngfile in "$BASE_DIR/$section/errors/${num}"*.mng; do
            [ -e "$mngfile" ] || continue
            base=$(basename "$mngfile" .mng)
            outdir="$BASE_DIR/$section/errors/expected"
            mkdir -p "$outdir"
            outfile="$outdir/$base.out"
            echo "Actualizando $outfile"
            echo "s" | $BIN "$mngfile" > "$outfile"
        done
    done
done