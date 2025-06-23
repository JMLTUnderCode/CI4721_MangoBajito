#include <iostream>
#include <mango_lexer.yy.hpp>
#include <mango_parser.tab.hpp>

extern int yyparse();
extern FILE* yyin;

using namespace std;

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            cerr << "No me dicen Baltazar para hacer milagros: '" << argv[1] << "' no existe chamo." << endl;
            return 1;
        }
    }

    cout << "| Acomódate que te lo estan analizando d:-)" << endl;

    // Incluir logistica de inclusion de librerias.
    

    yyparse();
    cout << "| Hay un poquito de código en tu marihuana d:-]" << endl;

    if (yyin) fclose(yyin);
    return 0;
}