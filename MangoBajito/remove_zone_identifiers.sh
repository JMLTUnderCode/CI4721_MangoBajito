#!/bin/bash
# filepath: ./remove_zone_identifiers.sh

# Busca y elimina archivos que terminan en Zone.Identifier (incluyendo variantes Unicode)
find . -type f \( -name "*:Zone.Identifier" -o -name "*Zone.Identifier" \) -print -exec rm -f {} \;

echo "Archivos Zone.Identifier eliminados."