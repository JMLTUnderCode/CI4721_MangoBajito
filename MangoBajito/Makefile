# Makefile en la raíz del proyecto

all: clean build/mango_bajito

build/mango_bajito:
	@mkdir -p build
	@cd build && cmake .. && make
	@cp build/mango_bajito .

run: build/mango_bajito
	@./mango_bajito $(e)

local: build/mango_bajito
	@if [ -z "$(e)" ]; then \
		echo "Uso: make local e=<nombre sin extension> (ejemplo: make local e=test //Donde 0 referencia a test.mng)"; \
	else \
		./mango_bajito local/$(e).mng; \
	fi

unitest2: build/mango_bajito
	@bash lenguajes2_run_tests.sh

unitest3: build/mango_bajito
	@bash lenguajes3_run_tests.sh

clean:
	@rm -rf build mango_bajito

.PHONY: all run local unitest2 unitest3 clean