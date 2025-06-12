#!/bin/bash
BIN=./mango_bajito
ROOT=./tests/Lenguajes_III

TOTAL_VALID=0
PASSED_VALID=0
FAILED_VALID=0

GREEN='\033[0;32m'
RED='\033[0;31m'
BLINK='\033[5m'
NC='\033[0m'
ORANGE='\033[38;5;214m'
LIGHTBLUE='\033[38;5;51m'

echo -e "${ORANGE}==========================================================${NC}"
echo -e "${ORANGE}==========            SECTION: VALID            ==========${NC}"
echo -e "${ORANGE}==========================================================${NC}"

for valid_dir in $(find "$ROOT" -type d \( -iname "valid" \) | sort); do
	echo " "
	echo -e "${LIGHTBLUE}Analizando carpeta: $valid_dir${NC}"
	echo " "
	for file in $(find "$valid_dir" -maxdepth 1 -type f -name "*.mng" | sort); do
		[ -e "$file" ] || continue
		base=$(basename "$file" .mng)
		expected="$valid_dir/expected/$base.out"
		TOTAL_VALID=$((TOTAL_VALID+1))
		OUTPUT=$(echo -e "s\ns" | $BIN "$file" 2>&1)
		if [ -f "$expected" ]; then
			diff -u <(echo "$OUTPUT") "$expected" > /dev/null
			if [ $? -eq 0 ]; then
				echo -e "${GREEN} - [OK]${NC} $file"
				PASSED_VALID=$((PASSED_VALID+1))
			else
				echo " "
				echo -e "${RED}${BLINK} - [FAIL]${NC} $file [ESPERADO válido]"
				echo "----- Diff salida real vs esperada -----"
				diff -u <(echo "$OUTPUT") "$expected"
				FAILED_VALID=$((FAILED_VALID+1))
				echo " "
			fi
		else
			echo -e "${RED}${BLINK} - [FAIL]${NC} $file [NO SE ENCONTRÓ ARCHIVO ESPERADO: $expected]"
			FAILED_VALID=$((FAILED_VALID+1))
		fi
	done
done
echo " "

echo -e "${GREEN}=========================================================${NC}"
echo " "
echo -e "${GREEN}|-----  PASS TEST: $PASSED_VALID${NC}"
echo -e "${GREEN}|-----  FAIL TEST: $FAILED_VALID${NC}"
echo -e "${GREEN}|-----  TOTAL TEST: $TOTAL_VALID${NC}"
if [ "$TOTAL_VALID" -gt 0 ]; then
	echo -e "${GREEN}|-----  SUCCESS RATE: $((PASSED_VALID * 100 / TOTAL_VALID))%${NC}"
else
	echo -e "${GREEN}|-----  SUCCESS RATE: 0%${NC}"
fi
echo -e "${GREEN}=========================================================${NC}"
echo " "