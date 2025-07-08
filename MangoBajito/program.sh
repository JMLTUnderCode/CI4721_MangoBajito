#!/bin/bash

TEST_DIR="tests/programas"
PROG="./mango_bajito"

for file in $(ls "$TEST_DIR" | grep -E '^[0-9]{2}.*\.mng$' | sort); do
	prog_name="${file%.mng}"
	while true; do
		echo " "
		# Línea 10: color azul turquesa (cyan)
		read -p $'\033[1;36m |--> Execute program: '"$prog_name"$'? (s/n) \033[0m' answer
		case "$answer" in
			[sS])
				# Ejecutar el programa y enviar cuatro 's' automáticos
				(echo -e "s\ns\ns\ns" | $PROG "$TEST_DIR/$file")
				break
				;;
			[nN])
				break
				;;
			*)
				# Línea 21: color naranja (ANSI 38;5;208)
				echo -e "\033[38;5;208mPlease enter y/Y or n/N.\033[0m"
				;;
		esac
	done
done