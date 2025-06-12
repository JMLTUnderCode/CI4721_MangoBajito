#include <iostream>
#include <mango-lexer.yy.hpp>
#include <mango-parser.tab.hpp>

extern int yyparse();
extern FILE* yyin;

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            std::cerr << "No se pudo abrir el archivo: " << argv[1] << std::endl;
            return 1;
        }
    }

    std::cout << "Analizando el código en Mango Bajito..." << std::endl;
    yyparse();
    std::cout << "Análisis finalizado." << std::endl;
    
    if (yyin) fclose(yyin);
    return 0;
}