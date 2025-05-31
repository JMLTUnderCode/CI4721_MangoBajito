# Makefile en la raíz del proyecto

all: clean build/mango_bajito

build/mango_bajito:
	@mkdir -p build
	@cd build && cmake .. && make
	@cp build/mango_bajito .

run: build/mango_bajito
	@./mango_bajito $(arg)

local: build/mango_bajito
	@if [ -z "$(arg)" ]; then \
		echo "Uso: make test arg=<número de prueba> (ejemplo: make test arg=0)"; \
	else \
		./mango_bajito local/$(arg).mng; \
	fi

unitest: build/mango_bajito
	@bash run_tests.sh

clean:
	@rm -rf build mango_bajito

.PHONY: all run local unitest clean