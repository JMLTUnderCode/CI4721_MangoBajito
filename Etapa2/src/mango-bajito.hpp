#ifndef MANGO_BAJITO_HPP
#define MANGO_BAJITO_HPP

#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <stack>
#include <variant>

using namespace std;

struct RecursiveArray; // Declaración adelantada
class SymbolTable;

// Definicion de tipo Information para almacenar la informacion de los atributos
typedef variant<string, int, bool> Information;
// Definicion de tipo Values para almacenar el valor de los atributos
typedef variant<
	nullptr_t,
	int, 
	bool, 
	float, 
	double, 
	string,
	int*,                    // Puntero a int
	double*,                 // Puntero a double
	string*,                 // Puntero a string
	vector<int>, 
	vector<float>, 
	vector<double>, 
	vector<std::string>,
	vector<RecursiveArray>   // Recursión para matrices anidadas
> Values;

// Estructura para representar arreglos anidados recursivos
struct RecursiveArray {
    vector<Values> data; // Puede contener cualquier tipo de Values
};

// Definicion de Category para almancenar las categorias de los simbolos
enum Category {
	CONSTANT,
	VARIABLE,
	FUNCTION,
	PARAMETERS,
	ARRAY,
	STRUCT,
	UNION,
	FIELD,
	TYPE,
};

// Implementacion de la estructura de Atributos
struct Attributes {
	string symbol_name;
	Category category;
	int scope;
	SymbolTable *type;
	vector<pair<Information, Attributes*> > info = {{"", nullptr}}; // Informacion de los atributos (depende de Category)
	Values value = nullptr;
};

// Implementacion Tabla de Simbolos Le-Blanc Cook
class SymbolTable {
	protected:
		unordered_map<string, vector<Attributes> > table;	//Tabla de simbolos
		stack<pair<int, bool> > scopes;				//Pila de scopes
		int current_scope;							//Scope actual
		int next_scope;								//Proximo scope
		vector<string> predef_types = {"mango", "manguita", "manguangua", "negro", "higuerote", "tas_claro", "un_coño"};
		vector<string> predef_func = {"rescata", "hablame", "se_prende"};
	public:
		SymbolTable();
		~SymbolTable() = default;
		void print_table();											//Imprimir tabla de simbolos
		void open_scope();											//Abrir nuevo scope
		void close_scope();											//Cerrar scope 
		bool insert_symbol(string symbol_name, Attributes &attr);	//Insertar simbolo en la tabla
		Attributes* search_symbol(string symbol_name);				//Buscar simbolo en la tabla
		bool contains_key(string symbol_table);
};
#endif