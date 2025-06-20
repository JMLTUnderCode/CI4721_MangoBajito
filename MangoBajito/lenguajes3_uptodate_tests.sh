#!/bin/bash

# Define las secciones y los números de test a actualizar para valid
declare -A valid_tests
valid_tests["Apuntador"]=""
valid_tests["Bucle"]="00 02"
valid_tests["Casteo"]="00 01 02 03 04"
valid_tests["Condicional"]="00 01 02 03"
valid_tests["Declaracion"]="00 01 03 04 06 07 08 09 10 12 13"
valid_tests["Entrada_Salida"]="00 01"
valid_tests["Funcion"]="00 01 02"
valid_tests["Operacion"]="00 01 02 03 04 05 07 08 09 10 11"
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