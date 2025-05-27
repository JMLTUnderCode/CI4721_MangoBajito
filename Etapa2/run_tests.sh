#!/bin/bash
BIN=./build/mango_bajito
ROOT=./suit_test
TOTAL=0
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
BLINK='\033[5m'
NC='\033[0m' # Sin color
ORANGE='\033[38;5;214m'   # Naranja claro (256-color)
LIGHTBLUE='\033[38;5;51m' # Azul celeste (256-color)

echo " "
echo -e "${ORANGE}==================== BLOQUE: VALIDOS ====================${NC}"
echo " "

# Buscar y procesar todas las carpetas de validos
for valid_dir in $(find "$ROOT" -type d \( -iname "Validos" \) | sort); do
  echo " "
  echo -e "${LIGHTBLUE}Analizando carpeta: $valid_dir${NC}"
  echo " "
  for file in $(find "$valid_dir" -maxdepth 1 -type f -name "*.mng" | sort); do
    [ -e "$file" ] || continue
    TOTAL=$((TOTAL+1))
    OUTPUT=$(echo n | $BIN "$file" 2>&1)
    if echo "$OUTPUT" | grep -q "Programa válido"; then
      echo -e "${GREEN} - [OK]${NC} $file"
      PASSED=$((PASSED+1))
    else
	  echo " "
      echo -e "${RED}${BLINK} - [FAIL]${NC} $file [ESPERADO válido]"
      echo "$OUTPUT"
      FAILED=$((FAILED+1))
	  echo " "
    fi
  done
done

echo " "
echo -e "${ORANGE}==================== BLOQUE: ERRORES ====================${NC}"
echo " "

# Buscar y procesar todas las carpetas de errores
for error_dir in $(find "$ROOT" -type d \( -iname "Errores" \) | sort); do
  echo " "
  echo -e "${LIGHTBLUE}Analizando carpeta: $error_dir${NC}"
  echo " "
  for file in $(find "$error_dir" -maxdepth 1 -type f -name "*.mng" | sort); do
    [ -e "$file" ] || continue
    TOTAL=$((TOTAL+1))
    OUTPUT=$(echo n | $BIN "$file" 2>&1)
    if echo "$OUTPUT" | grep -qi "error"; then
      echo -e "${GREEN} - [OK]${NC} $file"
      PASSED=$((PASSED+1))
    else
	  echo " "
      echo -e "${RED}${BLINK} - [FAIL]${NC} $file [ESPERADO error]"
      echo "$OUTPUT"
      FAILED=$((FAILED+1))
	  echo " "
    fi
  done
done

echo -e "${ORANGE}=========================================================${NC}"
echo -e "${ORANGE}|-----  PASS TEST: $PASSED${NC}"
echo -e "${ORANGE}|-----  FAIL TEST: $FAILED${NC}"
echo -e "${ORANGE}|-----  TOTAL TEST: $TOTAL${NC}"
if [ "$TOTAL" -gt 0 ]; then
  echo -e "${ORANGE}|-----  SUCCESS RATE: $((PASSED * 100 / TOTAL))%${NC}"
else
  echo -e "${ORANGE}|-----  SUCCESS RATE: 0%${NC}"
fi
echo -e "${ORANGE}=========================================================${NC}"
echo " "