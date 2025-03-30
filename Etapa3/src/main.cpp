#include <iostream>
#include <mango-lexer.yy.hpp>
#include <mango-parser.tab.hpp>
#include "ast.hpp" // Para ASTNode
#include <stack>   // Para std::stack

extern int yyparse();
extern FILE *yyin;

// Variable global: pila de nodos AST
std::stack<std::shared_ptr<ASTNode>> ancestros;

int main(int argc, char **argv)
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (!yyin)
        {
            std::cerr << "No se pudo abrir el archivo: " << argv[1] << std::endl;
            return 1;
        }
    }

    std::cout << "Analizando el código en Mango Bajito..." << std::endl;
    yyparse();
    // printAST(ancestros.top()); // Imprime el AST completo
    std::cout << "Análisis finalizado." << std::endl;

    if (yyin)
        fclose(yyin);
    return 0;
}