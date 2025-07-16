#!/bin/bash

TEST_DIR="tests/programas"
EXPECTED_DIR="$TEST_DIR/expected"
PROG="./mango_bajito"

for file in $(ls "$TEST_DIR" | grep -E '^[0-9]{2}.*\.mng$' | sort); do
	prog_name="${file%.mng}"
	while true; do
		echo " "
		read -p $'\033[1;36m |--> Execute program: '"$prog_name"$'? (s/n) \033[0m' answer
		case "$answer" in
			[sS])
				tmp_out=$(mktemp)
				# Ejecutar el programa, mostrar salida en pantalla y guardar en archivo temporal
				(echo -e "s\ns\ns\ns\nn" | $PROG "$TEST_DIR/$file" | tee "$tmp_out")
				expected_file="$EXPECTED_DIR/$prog_name.out"
				if [ -f "$expected_file" ]; then
					if diff -q "$tmp_out" "$expected_file" > /dev/null; then
						echo -e "\033[5;32m[OK]\033[0m VALIDACION CONFIRMADA"
					else
						echo -e "\033[5;31m[FAIL]\033[0m ERROR DE VALIDACION"
						diff "$tmp_out" "$expected_file"
					fi
				else
					echo -e "\033[5;31m[FAIL]\033[0m SIN ARCHIVO PARA VALIDAR"
				fi
				rm -f "$tmp_out"
				break
				;;
			[nN])
				break
				;;
			*)
				echo -e "\033[38;5;208mPlease enter y/Y or n/N.\033[0m"
				;;
		esac
	done
done