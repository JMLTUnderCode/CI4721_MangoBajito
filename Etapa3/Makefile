# Makefile en la raíz del proyecto

all: build/mango_bajito

build/mango_bajito:
	@mkdir -p build
	@cd build && cmake .. && make
	@cp build/mango_bajito .

run: build/mango_bajito
	@./mango_bajito $(arg)

test: build/mango_bajito
	@if [ -z "$(arg)" ]; then \
		echo "Uso: make test <número de prueba> (ejemplo: make test 0)"; \
	else \
		./mango_bajito tests/$(arg).mng; \
	fi

clean:
	@rm -rf build mango_bajito

.PHONY: all run test clean