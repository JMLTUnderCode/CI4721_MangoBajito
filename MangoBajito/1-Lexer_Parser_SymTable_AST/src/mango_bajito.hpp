#ifndef MANGO_BAJITO_HPP
#define MANGO_BAJITO_HPP

#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <stack>
#include <variant>
#include <set>

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
enum systemError {
	ARRAY_LITERAL_SIZE_MISMATCH,
	SEMANTIC,
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
	ALREADY_DEF_PARAM,
	EMPTY_ARRAY_CONSTANT,
	POINTER_ARRAY,
	INT_SIZE_ARRAY,
	INT_INDEX_ARRAY,
	SIZE_ARRAY_INVALID,
	INTERNAL,
	EMPTY
};

// Declaración de errorTypeToString como extern
extern vector<string> sysErrorToString;

// Define el diccionario para almacenar los errores
extern unordered_map<systemError, vector<string>> errorDictionary;

void addError(systemError err, const string& msg);
void printErrors();

// ======================================================
// =                   Symbol Table                     =
// ======================================================

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

// ======================================================
// =                Abstract Syntax Tree                =
// ======================================================

struct ASTParam {
	string name;   // Nombre del parámetro
	string type;   // Tipo del parámetro

	ASTParam(const string& n, const string& t) : name(n), type(t) {}
};

struct ASTAttribute {
	string name;   // Nombre del atributo (campo de struct/union)
	string type;   // Tipo del atributo

	ASTAttribute(const string& n, const string& t) : name(n), type(t) {}
};

struct ASTElement {
	string name;   // Nombre del elemento (variable, constante, etc)
	string type;   // Tipo de dato del elemento
	string value;  // Valor del elemento (si aplica)

	ASTElement(const string& n = "", const string& t = "", const string& v = "" ) : name(n), type(t), value(v) {}
};

struct ASTNode {
	string name;    // Nombre del elemento (variable, función, struct, etc)
	string category; // "declaration", "assignment", "function", "while", "for", "error_handling", "array", "pointer", "operation", etc.
	string type;    // Tipo de dato (para variables, constantes, retorno de función, etc)
	string kind;	// Tipo de declaracion, por ejemplo: "variable", "constante", "pointer constante", "pointer variable".
	string value;   // Valor (si aplica)
	
	// Conservar valores con precision
	double dvalue = 0.0;

	// Para funciones
	vector<ASTParam> params; // Lista de parámetros (nombre y tipo)
	int param_count = 0;     // Cantidad de parámetros

	// Para structs/unions/variants
	vector<ASTAttribute> attributes; // Lista de atributos (nombre y tipo)

	// Para arrays: si este nodo es "ArrayElements", aquí van los valores como strings
    vector<ASTElement> elements;

	// Hijos del nodo (estructura de árbol)
	vector<ASTNode*> children;

	ASTNode(const string& n, const string& c = "", const string& t = "", const string& k = "", const string& v = "")
		: name(n), category(c), type(t), kind(k), value(v) {}
};

// Crear un nodo AST y devolver un puntero inteligente
inline ASTNode* makeASTNode(const string& name, const string& category = "", const string& type = "", const string& kind = "", const string& value = "") {
	return new ASTNode(name, category, type, kind, value);
}

// Recolecta nodos por una lista de categorías
inline void collect_nodes_by_categories(ASTNode* node, const set<string>& categories, vector<ASTNode*>& out) {
    if (!node) return;
    if (categories.count(node->category)) out.push_back(node);
    for (auto child : node->children) collect_nodes_by_categories(child, categories, out);
}

// Imprimir el AST (recursivo, para debug)
void showAST(const ASTNode* node, int depth = 0, const string& prefix = "", bool isLast = true);
void print_AST(const ASTNode* node);

#endif