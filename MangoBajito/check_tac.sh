#!/bin/bash
# filepath: ./check_tac

if [ $# -ne 1 ]; then
    echo "Uso: $0 <ruta_al_archivo_mng>"
    exit 1
fi

ARCHIVO="$1"

if [ ! -f "$ARCHIVO" ]; then
    echo "Archivo no encontrado: $ARCHIVO"
    exit 1
fi

# Ejecuta mango_bajito y responde n, n, s
echo -e "n\nn\ns" | ./mango_bajito "$ARCHIVO"