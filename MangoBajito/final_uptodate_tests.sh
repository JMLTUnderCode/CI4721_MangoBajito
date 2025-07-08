#!/bin/bash

# Define las secciones y los números de test a actualizar para valid
declare -A valid_tests
valid_tests["programas"]="01 02 03 04"

# Ruta base de los tests
BASE_DIR="tests"

# Ejecutable
BIN="./mango_bajito"

# Actualizar tests válidos
for section in "${!valid_tests[@]}"; do
    echo "Actualizando sección válida: $section"
    for num in ${valid_tests[$section]}; do
        for mngfile in "$BASE_DIR/$section/${num}"*.mng; do
            [ -e "$mngfile" ] || continue
            base=$(basename "$mngfile" .mng)
            outdir="$BASE_DIR/$section/expected"
            mkdir -p "$outdir"
            outfile="$outdir/$base.out"
            echo "Actualizando $outfile"
            echo -e "s\ns\ns\ns" | $BIN "$mngfile" > "$outfile"
        done
    done
done