#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Uso: $0 <ruta/al/archivo.mng>"
	exit 1
fi

ARCHIVO="$1"

# Ejecutar mango_bajito con las respuestas automáticas
(echo -e "n\nn\ns\nn\ns" | ./mango_bajito "$ARCHIVO")

# Obtener ruta y nombre base sin extensión
DIRNAME=$(dirname "$ARCHIVO")
BASENAME=$(basename "$ARCHIVO" .mng)
ASM_DEST="$DIRNAME/$BASENAME.asm"

# Mover output.asm al destino con el nuevo nombre
mv output.asm "$ASM_DEST"

# Ejecutar MARS sobre el archivo .asm en la nueva ubicación
java -jar Mars.jar nc sm we "$ASM_DEST"