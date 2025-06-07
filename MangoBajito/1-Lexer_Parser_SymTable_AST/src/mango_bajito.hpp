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
	EMPTY_STRUCT,
	NON_DEF_UNION,
	ALREADY_DEF_UNION,
	EMPTY_UNION,
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
		bool remove_symbol(string symbol_name);                     //Eliminar simbolo de la tabla
		Attributes* search_symbol(string symbol_name);              //Buscar simbolo en la tabla
		bool contains_key(string key);                              //Verifica si la tabla contiene el simbolo
		void finding_variables_in_scope(int scope);
		void print_attribute(Attributes &attr);
};

// ======================================================
// =                Abstract Syntax Tree                =
// ======================================================

struct ASTNode {
	string name;    // Nombre del elemento (variable, función, struct, etc)
	string category; // "declaration", "assignment", "function", "while", "for", "error_handling", "array", "pointer", "operation", etc.
	string type;    // Tipo de dato (para variables, constantes, retorno de función, etc)
	string kind;	// Tipo de declaracion, por ejemplo: "variable", "constante", "pointer constante", "pointer variable".
	
	int ivalue; // Valor entero
	float fvalue; // Valor flotante
	double dvalue; // Valor doble
	string svalue; // Valor string
	char cvalue; // Valor char
	bool bvalue; // Valor booleano

	bool show_value = true; // Indica si se debe mostrar el valor del nodo

	// Hijos del nodo (estructura de árbol)
	vector<ASTNode*> children;

	ASTNode(const string& n, const string& c = "", const string& t = "", const string& k = "")
		: name(n), category(c), type(t), kind(k) {}
};

// Crear un nodo AST y devolver un puntero inteligente
inline ASTNode* makeASTNode(const string& name, const string& category = "", const string& type = "", const string& kind = "") {
	return new ASTNode(name, category, type, kind);
}

// Recolecta nodos por una lista de categorías
inline void collect_nodes_by_categories(ASTNode* node, const set<string>& categories, vector<ASTNode*>& out) {
    if (!node) return;
    if (categories.count(node->category)) out.push_back(node);
    for (auto child : node->children) collect_nodes_by_categories(child, categories, out);
}

inline ASTNode* solver_operation(ASTNode* left, const string& op, ASTNode* right) {
    ASTNode* new_node = makeASTNode(op, "Operación");
	string type = "Desconocido";
    string kind = "Desconocido";
    
    // Ejemplo simple: suma, resta, multiplicación, división son numéricas
    set<string> ops_numericas = {"+", "-", "*", "/", "//", "%", "**"};
	if (ops_numericas.count(op)) kind = "Numérica";

    set<string> ops_booleana = {"igualito", "nie", "mayol", "lidel", "menol", "peluche", "yunta", "o_sea"};
	if (ops_booleana.count(op)) kind = "Booleana";

	string left_type = left ? left->type : "Desconocido";
	string right_type = right ? right->type : "Desconocido";

	if (left && right) {
		type = left_type;

		if (kind == "Numérica" && left_type == right_type) {
			if (type == "mango"){
				if (op == "+") new_node->ivalue = left->ivalue + right->ivalue;
				else if (op == "-") new_node->ivalue = left->ivalue - right->ivalue;
				else if (op == "*") new_node->ivalue = left->ivalue * right->ivalue;
				else if (op == "/") {
					if (right->ivalue != 0) {
						new_node->fvalue = static_cast<float>(left->ivalue) / right->ivalue;
					} else {
						addError(SEGMENTATION_FAULT, "Division by zero in operation.");
						return nullptr; // Error handling
					}
					type = "manguita";
				} else if (op == "//") {
					if (right->ivalue != 0) {
						new_node->ivalue = left->ivalue / right->ivalue;
					} else {
						addError(SEGMENTATION_FAULT, "Division by zero in operation.");
						return nullptr; // Error handling
					}
				} else if (op == "%") {
					if (right->ivalue != 0) {
						new_node->ivalue = left->ivalue % right->ivalue;
					} else {
						addError(SEGMENTATION_FAULT, "Modulo by zero in operation.");
						return nullptr; // Error handling
					}
				} else if (op == "**") {
					new_node->dvalue = pow(left->ivalue, right->ivalue);
					type = "manguangua";
				}
			
			} else if (type == "manguita"){
				if (op == "+") new_node->fvalue = left->fvalue + right->fvalue;
				else if (op == "-") new_node->fvalue = left->fvalue - right->fvalue;
				else if (op == "*") new_node->fvalue = left->fvalue * right->fvalue;
				else if (op == "/") {
					if (right->fvalue != 0.0) {
						new_node->fvalue = left->fvalue / right->fvalue;
					} else {
						addError(SEGMENTATION_FAULT, "Division by zero in operation.");
						return nullptr; // Error handling
					}
				} else if (op == "//") {
					if (right->fvalue != 0.0) {
						new_node->ivalue = static_cast<int>(left->fvalue / right->fvalue);
					} else {
						addError(SEGMENTATION_FAULT, "Division by zero in operation.");
						return nullptr; // Error handling
					}
					type = "mango";
				} else if (op == "%") {
						addError(TYPE_ERROR, "Modulo operation not supported for float types.");
						return nullptr; // Error handling
				} else if (op == "**") {
					float base = left->fvalue;
				    float exp = right->fvalue;
				    // Raíz impar de negativo: resultado negativo
					if (base < 0 && fmod(exp, 2.0f) != 0.0f) {
				        new_node->dvalue = -pow(-base, exp);
				    } else {
				        new_node->dvalue = pow(base, exp);
				    }
					type = "manguangua";
				}
			} else if (type == "manguangua"){
				if (op == "+") new_node->dvalue = left->dvalue + right->dvalue;
				else if (op == "-") new_node->dvalue = left->dvalue - right->dvalue;
				else if (op == "*") new_node->dvalue = left->dvalue * right->dvalue;
				else if (op == "/") {
					if (right->dvalue != 0.0) new_node->dvalue = left->dvalue / right->dvalue;
					else {
						addError(SEGMENTATION_FAULT, "Division by zero in operation.");
						return nullptr; // Error handling
					}
				} else if (op == "//") {
					if (right->dvalue != 0.0) {
						new_node->ivalue = static_cast<int>(left->dvalue / right->dvalue);
						type = "mango";
					} else {
						addError(SEGMENTATION_FAULT, "Division by zero in operation.");
						return nullptr; // Error handling
					}
				} else if (op == "%") {
						addError(TYPE_ERROR, "Modulo operation not supported for double types.");
						return nullptr; // Error handling
				} else if (op == "**"){
					double base = left->dvalue;
				    double exp = right->dvalue;
				    // Raíz impar de negativo: resultado negativo
					if (base < 0 && fmod(exp, 2.0) != 0.0f) {
				        new_node->dvalue = -pow(-base, exp);
				    } else {
				        new_node->dvalue = pow(base, exp);
				    }
				}
			} else {
				addError(TYPE_ERROR, "Unsupported type for operation: " + type);
				return nullptr; // Error handling
			}

		} else if (kind == "Numérica" && left_type != right_type) {
			addError(TYPE_ERROR, "Type mismatch in operation: " + left_type + " " + op + " " + right_type);
			return nullptr;

		} else if (kind == "Booleana") {
			if (type == "tas_claro") {
		        if (op == "yunta") { // and
					new_node->bvalue = left->bvalue && right->bvalue;
		        } else if (op == "o_sea") { // or
		            new_node->bvalue = left->bvalue || right->bvalue;
		        }

			} else {
				type = "tas_claro"; // Asignar tipo por defecto para operaciones booleanas
				if (op == "igualito") { // ==

				} else if (op == "nie"){ // !=

				} else if (op == "mayol") { // >

				} else if (op == "lidel") { // >=

				} else if (op == "menol") { // <

				} else if (op == "peluche") { // <=
				
				}
			}
		}
		new_node->type = type;
		new_node->kind = kind;
	    if (left) new_node->children.push_back(left);
	    if (right) new_node->children.push_back(right);
	    return new_node;

	} else {
		addError(INTERNAL, "Non operands finds.");
		return nullptr;
	}
}

// Imprimir el AST (recursivo, para debug)
void showAST(const ASTNode* node, int depth = 0, const string& prefix = "", bool isLast = true);
void print_AST(const ASTNode* node);

#endif