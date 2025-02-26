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
	vector<string>,
	vector<RecursiveArray>   // Recursión para matrices anidadas
> Values;

void print_values(Values x);
// Estructura para representar arreglos anidados recursivos
struct RecursiveArray {
    vector<Values> data; // Puede contener cualquier tipo de Values
};

// Definicion de Category para almancenar las categorias de los simbolos
enum Category{
	CONSTANT,
	VARIABLE,
	FUNCTION,
	PARAMETERS,
	STRUCT,
	UNION,
	FIELD,
	TYPE,
	POINTER_C, 
	POINTER_V,
	STRUCT_ATTRIBUTE,
	UNKNOWN
};

// Implementacion de la estructura de Atributos
struct Attributes {
	string symbol_name;
	Category category;
	int scope;
	Attributes *type;
	vector<pair<Information, Attributes*> > info; // Informacion de los atributos (depende de Category)
	Values value;

	Attributes() : symbol_name(""), category(UNKNOWN), scope(0), type(nullptr), info({}), value(nullptr) {}
};

void print_info(vector<pair<Information, Attributes*> > informations);
// Implementacion Tabla de Simbolos Le-Blanc Cook
class SymbolTable {
	protected:
		unordered_map<string, vector<Attributes> > table;	//Tabla de simbolos
		vector<pair<int, bool> > scopes;					//Pila de scopes
		vector<string> predef_types = {"mango", "manguita", "manguangua", "negro", "higuerote", "tas_claro", "un_coño", "array$"};
		vector<string> predef_func = {"rescata", "hablame", "se_prende"};
	public:
		int current_scope;							//Scope actual
		int next_scope;								//Proximo scope
		stack<int> prev_scope;								//Scope antiguo
		SymbolTable();
		~SymbolTable() = default;
		void print_table();											//Imprimir tabla de simbolos
		void open_scope();											//Abrir nuevo scope
		void close_scope();											//Cerrar scope 
		bool insert_symbol(string symbol_name, Attributes &attr);	//Insertar simbolo en la tabla
		Attributes* search_symbol(string symbol_name);				//Buscar simbolo en la tabla
		bool contains_key(string key);						        //Verifica si la tabla contiene el simbolo
		void finding_variables_in_scope(int scope);
};
#endif