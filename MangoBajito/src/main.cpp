#include <iostream>
#include <fstream>
#include <sstream>
#include <regex>
#include <mango_lexer.yy.hpp>
#include <mango_parser.tab.hpp>

extern int yyparse();
extern FILE* yyin;

using namespace std;

int main(int argc, char** argv) {
	string input_file;
	if (argc > 1) {
		yyin = fopen(argv[1], "r");
		if (!yyin) {
			cerr << "No me dicen Baltazar para hacer milagros: '" << argv[1] << "' no existe chamo." << endl;
			return 1;
		}
		input_file = argv[1];
		fclose(yyin); // Cerramos porque vamos a procesar el archivo manualmente
	} else {
		cerr << "Debes pasar el archivo fuente como argumento." << endl;
		return 1;
	}

	// --- INICIO LOGICA DE INCLUSION DE LIBRERIAS ---
	ifstream fin(input_file);
	if (!fin) {
		cerr << "No se pudo abrir el archivo fuente para lectura." << endl;
		return 1;
	}
	ostringstream processed;
	string line;
	regex pide_regex(R"(^\s*\.me_pide\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*;)");
	while (getline(fin, line)) {
		processed << line << '\n';
		smatch match;
		if (regex_match(line, match, pide_regex)) {
			string libname = match[1];
			string libpath = "./src/lib/" + libname + ".mng";
			ifstream libfile(libpath);
			if (!libfile) {
				cerr << "No se pudo incluir la librería: " << libpath << endl;
				continue;
			}
			processed << libfile.rdbuf();
		}
	}
	fin.close();

	// Escribimos el archivo temporal para el parser
	string temp_file = "/tmp/mango_bajito_preproc.mng";
	ofstream fout(temp_file);
	fout << processed.str();
	fout.close();

	yyin = fopen(temp_file.c_str(), "r");
	if (!yyin) {
		cerr << "No se pudo abrir el archivo temporal preprocesado." << endl;
		return 1;
	}

	cout << "| Acomódate que te lo estan analizando d:-)" << endl;
	yyparse();
	cout << "| Hay un poquito de código en tu marihuana d:-]" << endl;

	if (yyin) fclose(yyin);
	return 0;
}