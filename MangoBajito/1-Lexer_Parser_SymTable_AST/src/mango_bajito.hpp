#ifndef MANGO_BAJITO_HPP
#define MANGO_BAJITO_HPP

#include <iostream>
#include <cstdlib>
#include <string>
#include <cstring>
#include <sstream>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <stack>
#include <variant>
#include <set>
#include <math.h>

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
	VAR_FOR,
	ERROR_HANDLER,
	UNKNOWN
};

inline string categoryToString(Category cat) {
    switch (cat) {
        case CONSTANT:          return "CONSTANT";
        case VARIABLE:          return "VARIABLE";
        case FUNCTION:          return "FUNCTION";
        case PARAMETERS:        return "PARAMETERS";
        case STRUCT:            return "STRUCT";
        case UNION:             return "UNION";
        case FIELD:             return "FIELD";
        case TYPE:              return "TYPE";
        case POINTER_C:         return "POINTER_C";
        case POINTER_V:         return "POINTER_V";
        case STRUCT_ATTRIBUTE:  return "STRUCT_ATTRIBUTE";
        case ARRAY:             return "ARRAY";
        case ARRAY_ELEMENT:     return "ARRAY_ELEMENT";
		case VAR_FOR:           return "VAR_FOR";
		case ERROR_HANDLER:     return "ERROR_HANDLER";
        case UNKNOWN:           return "UNKNOWN";
        default:                return "UNKNOWN";
    }
}

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

// ======================================================
// =                   Error Handler                    =
// ======================================================

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
	EMPTY_STRUCT,
	NON_DEF_UNION,
	ALREADY_DEF_UNION,
	EMPTY_UNION,
	NON_DEF_TYPE,
	ALREADY_DEF_TYPE,
	NON_DEF_ATTR,
	ALREADY_DEF_ATTR,
	MODIFY_VAR_FOR,
	TRY_ERROR,
	NON_VALUE,
	TYPE_ERROR,
	MODIFY_CONST,
	SEGMENTATION_FAULT,
	FUNC_PARAM_EXCEEDED,
	FUNC_PARAM_MISSING,
	ALREADY_DEF_PARAM,
	EMPTY_ARRAY_CONSTANT,
	POINTER_ARRAY,
	INT_INDEX_ARRAY,
	SIZE_ARRAY_INVALID,
	INTERNAL,
	EMPTY
};

// Declaración de errorTypeToString como extern
extern vector<string> sysErrorToString;

// Define el diccionario para almacenar los errores
extern unordered_map<systemError, vector<string>> errorDictionary;

// Variables globales de contexto para el análisis sintáctico y semántico
extern systemError FLAG_ERROR;
extern bool FIRST_ERROR;

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
		
		void open_scope();                                          //Abrir nuevo scope
		void close_scope();											//Cerrar scope 
		bool contains_key(string key);                              //Verifica si la tabla contiene el simbolo
		bool insert_symbol(string symbol_name, Attributes &attr);   //Insertar simbolo en la tabla
		bool remove_symbol(string symbol_name);                     //Eliminar simbolo de la tabla
		Attributes* search_symbol(string symbol_name);              //Buscar simbolo en la tabla
		void finding_variables_in_scope(int scope);

		void print_table();                                         //Imprimir tabla de simbolos
		void print_attribute(Attributes &attr);
		void print_info(vector<pair<Information, Attributes*> > informations);
		void print_values(Values x);
};

// ======================================================
// =                Abstract Syntax Tree                =
// ======================================================

struct ASTNode {
	string name;     // Nombre del elemento (variable, función, struct, etc)
	string category; // "Declaración", "Asignación", "Función", "Bucle", "Operación", etc
	string type;     // Tipo de dato (para literales, variables, constantes, retorno de función, etc)
	string kind;     // Tipo de declaracion, por ejemplo: "variable", "constante", "pointer constante", "pointer variable".
	
	int ivalue;    // Valor entero
	float fvalue;  // Valor flotante
	double dvalue; // Valor doble
	string svalue; // Valor string
	char cvalue;   // Valor char
	bool bvalue;   // Valor booleano

	bool show_value = true; // Indica si se debe mostrar el valor del nodo

	// Hijos del nodo (estructura de árbol)
	vector<ASTNode*> children;

	ASTNode(const string& n, const string& c = "", const string& t = "", const string& k = "")
		: name(n), category(c), type(t), kind(k) {}
};


// Crea un nuevo nodo AST y devuelve un puntero al mismo.
// name: nombre del nodo, category: categoría del nodo, type: tipo de dato, kind: tipo de declaración.
ASTNode* makeASTNode(const string& name, const string& category = "", const string& type = "", const string& kind = "");

// Recolecta todos los nodos del AST que pertenezcan a las categorías especificadas.
// node: nodo raíz a partir del cual buscar, categories: conjunto de categorías a buscar, out: vector donde se almacenan los nodos encontrados.
void collect_nodes_by_categories(ASTNode* node, const set<string>& categories, vector<ASTNode*>& out);

// Recolecta todos los nodos de tipo guardia ("o_asi" o "nojoda") en el AST.
// node: nodo raíz a partir del cual buscar, out: vector donde se almacenan los nodos guardia encontrados.
void collect_guardias(ASTNode* node, vector<ASTNode*>& out);

// Verifica si el tipo de dato dado corresponde a un tipo numérico ("mango", "manguita" o "manguangua").
// typeStr: nombre del tipo a verificar.
// Retorna true si es numérico, false en caso contrario.
bool isNumeric(const string& typeStr);

// Realiza una operación binaria entre dos nodos AST y retorna el nodo resultado.
// left: nodo izquierdo, op: operador, right: nodo derecho, line_number y column_number: ubicación para reporte de errores.
// Retorna un puntero al nodo AST resultante de la operación.
ASTNode* solver_operation(ASTNode* left, const string& op, ASTNode* right, int line_number, int column_number);

// Muestra el AST en consola de forma jerárquica.
// node: nodo raíz a mostrar, depth: nivel de profundidad, prefix: prefijo para formato, isLast: indica si es el último hijo.
void showAST(const ASTNode* node, int depth = 0, const string& prefix = "", bool isLast = true);

// Imprime el AST completo en consola.
// node: nodo raíz del AST a imprimir.
void print_AST(const ASTNode* node);

#endif