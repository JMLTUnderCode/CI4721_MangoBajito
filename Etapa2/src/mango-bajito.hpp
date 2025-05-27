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
typedef variant<string, int, bool, char> Information;

// Definicion de tipo Values para almacenar el valor de los atributos
typedef variant<
	nullptr_t,
	char,
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
	ARRAY,
	ARRAY_ELEMENT,
	UNKNOWN
};

// Implementacion de la estructura de Atributos
struct Attributes {
	string symbol_name;
	Category category;
	int scope;
	Attributes *type;
	Values value;
	vector<pair<Information, Attributes*>> info; // Informacion de los atributos (depende de Category)

	Attributes() : symbol_name(""), category(UNKNOWN), scope(0), type(nullptr), value(nullptr), info({}) {}
};

void print_info(vector<pair<Information, Attributes*> > informations);

// ERROR_TYPE enum
enum errorType {
	SEMANTIC_TYPE,
    NON_DEF_VAR,
    ALREADY_DEF_VAR,
    NON_DEF_FUNC,
    ALREADY_DEF_FUNC,
    NON_DEF_STRUCT,
    ALREADY_DEF_STRUCT,
    NON_DEF_UNION,
    ALREADY_DEF_UNION,
    NON_DEF_TYPE,
    ALREADY_DEF_TYPE,
    NON_DEF_ATTR,
    ALREADY_DEF_ATTR,
    VAR_FOR,
    VAR_TRY,
	NON_VALUE,
    TYPE_ERROR,
	MODIFY_CONST,
    SEGMENTATION_FAULT,
    FUNC_PARAM_EXCEEDED,
    FUNC_PARAM_MISSING,
    EMPTY_ARRAY_CONSTANT,
    POINTER_ARRAY,
    INT_SIZE_ARRAY,
    INT_INDEX_ARRAY,
    DEBUGGING_TYPE
};

// Declaración de errorTypeToString como extern
extern vector<string> errorTypeToString;

// Define el diccionario para almacenar los errores
extern unordered_map<errorType, vector<string>> errorDictionary;

void addError(errorType type, const string& errorMessage);
void printErrors();

// Implementacion Tabla de Simbolos Le-Blanc Cook
class SymbolTable {
	protected:
		unordered_map<string, vector<Attributes> > table;	//Tabla de simbolos
		vector<pair<int, bool> > scopes;					//Pila de scopes
		vector<string> predef_types = {
			"mango", "manguita", "manguangua", "negro", "higuerote", "tas_claro", 
			"un_coño", 
			"array$", 
			"funcion$", 
			"error$"
		};
		vector<string> predef_func = {"rescata", "hablame", "se_prende"};
	public:
		int current_scope;                                          //Scope actual
		int next_scope;                                             //Proximo scope
		stack<int> prev_scope;                                      //Stack de scopes antiguos
		SymbolTable();
		~SymbolTable() = default;
		void print_table();                                         //Imprimir tabla de simbolos
		void open_scope();                                          //Abrir nuevo scope
		void close_scope();											//Cerrar scope 
		bool insert_symbol(string symbol_name, Attributes &attr);   //Insertar simbolo en la tabla
		Attributes* search_symbol(string symbol_name);              //Buscar simbolo en la tabla
		bool contains_key(string key);                              //Verifica si la tabla contiene el simbolo
		void finding_variables_in_scope(int scope);
		void print_attribute(Attributes &attr);
};
#endif