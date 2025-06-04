/*
 * mango_parser.y - Parser de Mango Bajito
 * ---------------------------------------------------------------
 * Definición de la gramática y semántica para el lenguaje Mango Bajito,
 * usando Bison. Este archivo contiene la lógica de análisis sintáctico,
 * manejo de errores, y estructuras auxiliares para la construcción de
 * la tabla de símbolos, control de errores y atributos de expresiones.
 *
 * Estructuras principales:
 *  - Type_and_Value: Representa el valor y tipo de una expresión.
 *  - ArrayValue: Maneja literales de arreglos y su tipo base.
 *  - SymbolTable: Tabla de símbolos para control de variables, funciones, etc.
 *  - errorDictionary: Diccionario para almacenar mensajes de error clasificados.
 *
 * Variables globales:
 *  - current_array_name, current_func_name, etc.: Controlan el contexto actual
 *    durante el análisis (nombre de array, función, tipo, etc).
 *  - FLAG_ERROR, FIRST_ERROR: Controlan el flujo de errores.
 *
 * Funciones auxiliares:
 *  - typeToString / stringToType: Conversión entre enums y strings de tipos.
 *  - isNumeric: Verifica si un tipo es numérico.
 *
 * Autores:
 *  - Junior Lara
 *  - Jhonaiker Blanco
 *  - Astrid Alvarado
 * Proyecto: Mango Bajito - CI4721
 * Fecha: 5/28/2025
 */

%{
#include "mango_bajito.hpp"
#include "tac.hpp"

#include <iostream>
#include <cstdlib>
#include <vector>
#include <cstring>
#include <vector>
#include <string>

using namespace std;

// Estructura para el manejo de ubicación de tokens (línea y columna)
typedef struct YYLTYPE {
	int first_line;
	int first_column;
} YYLTYPE;

// Prototipos de funciones requeridas por Bison
void yyerror(const char *s);
int yylex();
extern int yylineno;
extern YYLTYPE yylloc;

// Ininicializacion de nodo raiz para el AST.
ASTNode* ast_root = nullptr;

// Instancia global de la tabla de símbolos
SymbolTable symbolTable = SymbolTable();

// Diccionario global para almacenar errores clasificados por tipo
unordered_map<systemError, vector<string>> errorDictionary = {
	{ARRAY_LITERAL_SIZE_MISMATCH, {}},
	{SEMANTIC, {}},
	{NON_DEF_VAR, {}},
	{ALREADY_DEF_VAR, {}},
	{NON_DEF_FUNC, {}},
	{ALREADY_DEF_FUNC, {}},
	{NON_DEF_STRUCT, {}},
	{ALREADY_DEF_STRUCT, {}},
	{NON_DEF_UNION, {}},
	{ALREADY_DEF_UNION, {}},
	{NON_DEF_TYPE, {}},
	{ALREADY_DEF_TYPE, {}},
	{NON_DEF_ATTR, {}},
	{ALREADY_DEF_ATTR, {}},
	{VAR_FOR, {}},
	{VAR_TRY, {}},
	{NON_VALUE, {}},
	{TYPE_ERROR, {}},
	{MODIFY_CONST, {}},
	{SEGMENTATION_FAULT, {}},
	{FUNC_PARAM_EXCEEDED, {}},
	{FUNC_PARAM_MISSING, {}},
	{ALREADY_DEF_PARAM, {}},
	{EMPTY_ARRAY_CONSTANT, {}},
	{POINTER_ARRAY, {}},
	{INT_SIZE_ARRAY,{}},
	{INT_INDEX_ARRAY, {}},
	{SIZE_ARRAY_INVALID, {}},
	{INTERNAL, {}},
	{EMPTY, {}},
};

// Variables globales de contexto para el análisis sintáctico y semántico
systemError FLAG_ERROR = SEMANTIC;
bool FIRST_ERROR = false;

string current_array_name = "";
int current_array_size = 0;
string current_array_base_type = "";

string current_struct_name = "";
int current_struct_number_attr = 0;

string current_func_name = "";
int current_func_count_param = 0;
int current_func_max_param = 0;
string current_func_return_type = "";
string current_func_type = "";
%}

%code requires {
	#include "mango_bajito.hpp"
	#include <cstring>
	#include <vector>
	#include <string>

	//using std::shared_ptr;
	//using std::make_shared;

	using namespace std;

	// Estructura para literales de arreglos
	struct ArrayValue;

	// Atributos de expresiones para el parser
	struct Type_and_Value {
		enum Type { INT, FLOAT, DOUBLE, BOOL, STRING, POINTER, ID, CHAR, VOID, ARRAY_LITERAL } type;
		union {
			int ival;
			float fval;
			double dval;
			char* sval;
			char cval;
			ArrayValue* arr_val;
		};
		char* temp;
	};

	// Estructura para manejar arreglos literales
	struct ArrayValue {
		vector<Type_and_Value> elements;
		string type;
		
		ArrayValue(const string& t) : type(t) {}
		
		~ArrayValue() {
			for(auto& elem : elements) {
				if(elem.type == Type_and_Value::STRING && elem.sval) {
					delete[] elem.sval;
				}
			}
		}
	};

	// Función auxiliar: Enum a string
	inline const char* typeToString(Type_and_Value::Type type) {
		switch (type) {
			case Type_and_Value::INT:		return "mango";
			case Type_and_Value::FLOAT:		return "manguita";
			case Type_and_Value::DOUBLE:	return "manguangua";
			case Type_and_Value::BOOL:		return "tas_claro";
			case Type_and_Value::CHAR:		return "negro";
			case Type_and_Value::STRING:	return "higuerote";
			case Type_and_Value::POINTER:	return "pointer";
			case Type_and_Value::ID:		return "id";
			case Type_and_Value::VOID:		return "un_coño";
			default:						return "unknown";
		}
	}  

	// Función auxiliar: String a enum
	inline Type_and_Value::Type stringToType(const string& typeStr) {
		if (typeStr == "mango") {
			return Type_and_Value::INT;
		} else if (typeStr == "manguita") {
			return Type_and_Value::FLOAT;
		} else if (typeStr == "manguangua") {
			return Type_and_Value::DOUBLE;
		} else if (typeStr == "tas_claro") {
			return Type_and_Value::BOOL;
		} else if (typeStr == "negro") {
			return Type_and_Value::CHAR;
		} else if (typeStr == "higuerote") {
			return Type_and_Value::STRING;
		} else if (typeStr == "pointer") {
			return Type_and_Value::POINTER;
		} else if (typeStr == "id") {
			return Type_and_Value::ID;
		} else if (typeStr == "un_coño") {
			return Type_and_Value::VOID;
		} else {
			throw invalid_argument("Tipo desconocido: " + typeStr);
		}
	}

	// Verifica si un tipo es numérico
	inline bool isNumeric(const string& typeStr) {
		return typeStr == "mango" || typeStr == "manguita" || typeStr == "manguangua";
	}
}

%union {
	Type_and_Value att_val; // Usa el struct definido
	ArrayValue* array; 
	int ival;
	float fval;
	double dval;
	char* sval;
	char cval;
	ASTNode* ast;
}

%token <sval> T_MANGO       // Token para int
%token <sval> T_MANGUITA    // Token para float
%token <sval> T_MANGUANGUA  // Token para double
%token <sval> T_NEGRO       // Token para caracter
%token <sval> T_HIGUEROTE   // Token para string

%token T_SE_PRENDE T_ASIGNACION T_DOSPUNTOS T_PUNTOCOMA T_COMA
%token T_SIESASI T_OASI T_NOJODA
%token T_REPITEBURDA T_ENTRE T_HASTA T_CONFLOW
%token T_ECHALEBOLAS
%token T_ROTALO T_KIETO
%token T_CULITO T_JEVA
%token T_TASCLARO T_SISA T_NOLSA T_ARROZCONMANGO T_COLIAO T_PUNTO
%token T_AHITA T_AKITOY T_CEROKM T_BORRADOL T_PELABOLA T_FLECHA
%token T_UNCONO
%token T_ECHARCUENTO T_LANZA T_LANZATE
%token T_RESCATA T_HABLAME
%token T_T_MEANDO T_FUERADELPEROL T_COMO
%token T_OPSUMA T_OPRESTA T_OPINCREMENTO T_OPDECREMENTO T_OPASIGRESTA T_OPASIGSUMA T_OPASIGMULT
%token T_OPMULT T_OPDIVDECIMAL T_OPDIVENTERA T_OPMOD T_OPEXP
%token T_OPIGUAL T_OPDIFERENTE T_OPMAYORIGUAL T_OPMAYOR T_OPMENORIGUAL T_OPMENOR
%token T_YUNTA T_OSEA T_NELSON
%token <sval> T_ID 
%token <att_val> T_VALUE
%token T_IZQPAREN T_DERPAREN T_IZQLLAVE T_DERLLAVE T_IZQCORCHE T_DERCORCHE
%token T_CASTEO

// Declaracion de tipos de retorno para las producciones 
%type <ast> programa main 
%type <ast> asignacion operadores_asignacion operaciones_unitarias
%type <ast> instruccion secuencia_instrucciones instrucciones   
%type <ast> declaracion tipo_declaracion secuencia_declaraciones declaracion_aputador declaracion_funcion
%type <ast> tipos tipo_valor
%type <ast> expresion expresion_apuntador expresion_nuevo 
%type <ast> secuencia
%type <ast> condicion alternativa
%type <ast> bucle indeterminado determinado var_ciclo_determinado
%type <ast> firma_funcion funcion parametro secuencia_parametros entrada_salida
%type <ast> variante struct
%type <ast> casting
%type <ast> manejo_error manejador var_manejo_error

// Declaracion de precedencia y asociatividad de Operadores
// Asignacion
%right T_ASIGNACION 

// Logicos y comparativos
%left T_OSEA
%left T_YUNTA
%nonassoc T_OPIGUAL T_OPDIFERENTE T_OPMAYOR T_OPMENOR T_OPMAYORIGUAL T_OPMENORIGUAL

// Aritmeticos
%left T_OPSUMA T_OPRESTA 
%left T_OPMULT T_OPDIVENTERA T_OPDIVDECIMAL T_OPMOD
%right T_OPEXP
%nonassoc T_IZQPAREN T_DERPAREN

// Operaciones unarias
%left T_OPINCREMENTO T_OPDECREMENTO
%right T_NELSON
%left T_FLECHA

%right T_CASTEO  // Precedencia más alta para el casting

%start programa
%%

abrir_scope:
	{ symbolTable.open_scope(); }
	;

cerrar_scope:
	{ symbolTable.close_scope(); }
	;

programa:
	abrir_scope instrucciones main cerrar_scope {
		ast_root = makeASTNode("Programa");
		if ($2) {
			ASTNode* global_node = makeASTNode("Global");
			global_node->children.push_back($2);
			ast_root->children.push_back(global_node);
		}
		if ($3) {
			ASTNode* main_node = makeASTNode("Main");
			main_node->children.push_back($3);
			ast_root->children.push_back(main_node);
		}
		$$ = ast_root;
		if (FIRST_ERROR) printErrors();
		else symbolTable.print_table();
		if (ast_root) print_AST(ast_root);
		if (FIRST_ERROR) {
			cout << "\033[1;31m\033[5m\n               =======================================================\n";
			cout << "                       ---->        Error Program        <----        \n";
			cout << "               =======================================================\n\033[0m\n";
			
		} else {
			cout << "\033[1;32m\033[5m\n               =======================================================\n";
			cout << "                       ---->       Correct Program       <----        \n";
			cout << "               =======================================================\n\033[0m\n";
		}
	}
	;

main:
	T_SE_PRENDE abrir_scope T_IZQPAREN T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE T_PUNTOCOMA cerrar_scope { $$ = $6; }
	;

instrucciones:
	{ $$ = nullptr; }
	| secuencia_instrucciones { $$ = $1; }

secuencia_instrucciones:
	instruccion T_PUNTOCOMA { $$ = $1; }
	| secuencia_instrucciones instruccion T_PUNTOCOMA {
		$$ = makeASTNode("Instrucción");
		$$->children.push_back($1);
		$$->children.push_back($2);
	}
	;

instruccion:
	declaracion { $$ = $1; }
	| asignacion { $$ = $1; }
	| condicion { $$ = $1; }
	| bucle { $$ = $1; }
	| entrada_salida { $$ = $1; }
	| funcion { $$ = $1; }
	| manejo_error { $$ = $1; }
	| struct { $$ = $1; }
	| variante { $$ = $1; }
	| T_KIETO { $$ = nullptr; }
	| T_ROTALO { $$ = nullptr; }
	| T_LANZATE expresion { $$ = $2; }
	| expresion operaciones_unitarias {
		Attributes* var_attr = symbolTable.search_symbol($1->name);
		string op = $2->name;
		if (var_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1->name.c_str());
		} else {
			if (var_attr->type != nullptr && isNumeric(var_attr->type->symbol_name)) { // Verificar si es de tipo numerico.
				//string info_var_check = get<string>(var_attr->info[0].first);				
				if (var_attr->category != PARAMETERS){ // Si es parametro de una funcion no hay problema.
					if (holds_alternative<int>(var_attr->value)) { // De lo contrario hay que verificar si tiene valor numero asignado.
						int old_val = get<int>(var_attr->value);
						if (op == "--" ) var_attr->value = old_val - 1;
						if (op == "++" ) var_attr->value = old_val + 1;
					} else if (holds_alternative<float>(var_attr->value)) {
						float old_val = get<float>(var_attr->value);
						if (op == "--" ) var_attr->value = old_val - 1.0;
						if (op == "++" ) var_attr->value = old_val + 1.0;
					} else if (holds_alternative<double>(var_attr->value)) {
						double old_val = get<double>(var_attr->value);
						if (op == "--" ) var_attr->value = old_val - 1.0;
						if (op == "++" ) var_attr->value = old_val + 1.0;
					} else {
						FLAG_ERROR = NON_VALUE;
						yyerror($1->name.c_str());
					}
				}
			} else {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "\"" + $1->name + "\" de tipo '" + var_attr->type->symbol_name + "' y debe ser de tipo 'mango' | 'manguita' | 'manguangua', locota.";
				yyerror(error_msg.c_str());
			}
		}
		string category = op == "++" ? "Incremento" : "Decremento";
		$$ = makeASTNode("Operación", category, "", op);
		$$->children.push_back($1);
	}
	| T_BORRADOL T_ID { $$ = nullptr; }
	| T_BORRADOL T_ID T_PUNTO T_ID { $$ = nullptr; }
	;
	;

declaracion:
	tipo_declaracion T_ID T_DOSPUNTOS tipos {
		if ($4->category == "Array") {
			int size_array = 0;
			for (auto child : $4->children){
				if (child->category == "Array_Size"){
					try{
						size_array = stoi(child->value);
						if (size_array < 0){
							FLAG_ERROR = SIZE_ARRAY_INVALID;
							yyerror(child->value.c_str());
							size_array = 0;
						}
					} catch (const invalid_argument& e) {
						FLAG_ERROR = SIZE_ARRAY_INVALID;
						yyerror(child->value.c_str());
					}
					break;
				}
			}

			Attributes* type_attr = symbolTable.search_symbol($4->type);
			if (type_attr == nullptr){
				FLAG_ERROR = INTERNAL;
				yyerror("ERROR: Tipo no encontrado");
			}

			if (symbolTable.search_symbol($2) != nullptr){
				FLAG_ERROR = ALREADY_DEF_VAR;
				yyerror($2);
			} else {
				Attributes* array_attr = new Attributes();
				array_attr->symbol_name = $2;
				array_attr->category = ARRAY;
				array_attr->scope = symbolTable.current_scope;
				array_attr->type = type_attr;
				array_attr->value = size_array;
				
				// Crear atributos del array
				for (int i = 0; i < size_array; i++) {
					Attributes *elem = new Attributes();
					elem->symbol_name = string($2) + "[" + to_string(i) + "]";
					elem->scope = symbolTable.current_scope;
					elem->category = ARRAY_ELEMENT;
					elem->type = type_attr;
					elem->value = nullptr;

					// Usar el índice como clave en formato string
					array_attr->info.push_back({string($2) + "[" + to_string(i) + "]", elem});
		
					// \Insertar elemento en tabla de símbolos
					if (!symbolTable.insert_symbol(elem->symbol_name, *elem)) {
						FLAG_ERROR = ALREADY_DEF_VAR;
						yyerror(elem->symbol_name.c_str());
					}
				}
				// Insertar en tabla de símbolos
				symbolTable.insert_symbol($2, *array_attr);
			}
		// Declaracion de tipos basicos.
		} else { 
			if (symbolTable.search_symbol($4->type) == nullptr) {
				FLAG_ERROR = NON_DEF_TYPE;
				yyerror($4->type.c_str());
			}
			
			if (symbolTable.search_symbol($2) != nullptr) {
				FLAG_ERROR = ALREADY_DEF_VAR;
				yyerror($2);
			} else {
				Attributes *attribute = new Attributes();
				attribute->symbol_name = $2;
				attribute->scope = symbolTable.current_scope;
				attribute->type = symbolTable.search_symbol($4->type);

				if ($1->kind == "POINTER_V") attribute->category = POINTER_V;
				else if ($1->kind == "POINTER_C") attribute->category = POINTER_C;
				else if ($1->kind == "VARIABLE") attribute->category = VARIABLE;
				else if ($1->kind == "CONSTANTE") attribute->category = CONSTANT;
				
				// Insertar en tabla de símbolos
				symbolTable.insert_symbol($2, *attribute);
			}
		}
		// Actualizamos AST
		$$ = makeASTNode($2, "Declaración", $4->type, $1->kind);
		if ($4->category == "Array"){
			$$->children = $4->children;
		}
	}
	| tipo_declaracion T_ID T_DOSPUNTOS tipos T_ASIGNACION expresion {
		if ($4->category == "Array") {
			int size_array = 0;
			for (auto child : $4->children){
				if (child->category == "Array_Size"){
					try{
						size_array = stoi(child->value);
						if (size_array < 0){
							FLAG_ERROR = SIZE_ARRAY_INVALID;
							yyerror(child->value.c_str());
							size_array = 0;
						}
					} catch (const invalid_argument& e) {
						FLAG_ERROR = SIZE_ARRAY_INVALID;
						yyerror(child->value.c_str());
					}
					break;
				}
			}

			Attributes* type_attr = symbolTable.search_symbol($4->type);
			string declared_type = "Desconocido";
			if (type_attr == nullptr){
				FLAG_ERROR = INTERNAL;
				yyerror("ERROR: Tipo no encontrado");
			} else {
				declared_type = type_attr->symbol_name;
			}

			if (symbolTable.search_symbol($2) != nullptr){
				FLAG_ERROR = ALREADY_DEF_VAR;
				yyerror($2);
			} else {
				// Crear atributos del array
				Attributes* attribute = new Attributes();
				attribute->symbol_name = $2;
				attribute->category = ARRAY;
				attribute->scope = symbolTable.current_scope;
				attribute->type = type_attr;
				attribute->value = size_array;

				int count_elems = 0;
				set<string> categories = {"Identificador", "Number", "Char", "String"};
				vector<ASTNode*> array_elements;
				collect_nodes_by_categories($6, categories, array_elements);
				for (auto elem : array_elements) {
					count_elems++;
					if (size_array == 0) break;
					else if (count_elems > size_array) {
						FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
						string error_message = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(size_array) + "' cositas.";
						yyerror(error_message.c_str());
						break;
					}

					Attributes *attr_elem = new Attributes();
					attr_elem->symbol_name = string($2) + "[" + to_string(count_elems-1) + "]";
					attr_elem->scope = symbolTable.current_scope;
					attr_elem->category = ARRAY_ELEMENT;
					attr_elem->type = type_attr;

					if (declared_type != elem->type && (declared_type != "manguangua" || elem->type != "manguita")) {
						FLAG_ERROR = TYPE_ERROR;
						string error_message = "\"" + string($2) + "\" de tipo '" + declared_type + 
							"' y le quieres meter un tipo '" + elem->type + "', marbaa' bruja.";
						yyerror(error_message.c_str());
						attr_elem->value = nullptr;
					} else {
						if (elem->type == "mango") attr_elem->value = stoi(elem->value);
						else if (elem->type == "manguita") {
							if (declared_type == "manguangua") attr_elem->value = stod(elem->value);
							else attr_elem->value = stof(elem->value);
						}
						else if (elem->type == "manguangua") attr_elem->value = stod(elem->value);
						else if (elem->type == "tas_claro"){
							attr_elem->value = stoi(elem->value);
							if (!attr_elem->info.empty()) attr_elem->info[0].first = (elem->value == "1" ? "Sisa" : "Nolsa");
							else attr_elem->info.push_back({(elem->value == "1" ? "Sisa" : "Nolsa"), nullptr});
						} else if (elem->type == "negro") attr_elem->value = elem->value.empty() ? '\0' : elem->value[0];
						else if (elem->type == "higuerote") attr_elem->value = elem->value;
						else if (elem->type == "pointer"){
							/* POR IMPLEMENTAR */
							//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
							attr_elem->value = nullptr;
						} else {
							FLAG_ERROR = INTERNAL;
							string error_message = "TIPO DESCONOCIDO: Asignando 'nullptr' a: '" + string($2) + "'.";
							yyerror(error_message.c_str());
							attr_elem->value = nullptr;
						}
					}
					
					// Usar el índice como clave en formato string
					attribute->info.push_back({string($2) + "[" + to_string(count_elems-1) + "]", attr_elem});
		
					// \Insertar elemento en tabla de símbolos
					symbolTable.insert_symbol(attr_elem->symbol_name, *attr_elem);
				}

				// Verificar cantidad de elementos
				if (count_elems < size_array) {
					FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
					string error_message = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(count_elems) + "' de '" + to_string(size_array) + "'.";
					yyerror(error_message.c_str());
				}

				// Insertar en tabla de símbolos
				symbolTable.insert_symbol($2, *attribute);
			}	
		// Declaracion de tipos basicos, asignacion funcion.
		} else {	
			if (symbolTable.search_symbol($4->type) == nullptr){
				FLAG_ERROR = NON_DEF_TYPE;
				yyerror($4->type.c_str());
			}

			if (symbolTable.search_symbol($2) != nullptr) {
				FLAG_ERROR = ALREADY_DEF_VAR;
				yyerror($2);
			} else {
				Attributes *attribute = new Attributes();
				attribute->symbol_name = $2;
				attribute->scope = symbolTable.current_scope;
				attribute->info.push_back({"-", nullptr});
				attribute->type = symbolTable.search_symbol($4->type);

				// Verificacion de tipos.
				if ($4->type != $6->type && ($4->type != "manguangua" || $6->type != "manguita")) {
					FLAG_ERROR = TYPE_ERROR;
					string error_message = "\"" + string($2) + "\" de tipo '" + $4->type + "' y le quieres meter un tipo '" + $6->type + "', marbaa' bruja.";
					yyerror(error_message.c_str());
					attribute->value = nullptr; // Asignar valor nulo en caso de error
				} else {
					
					if ($1->kind == "POINTER_V") attribute->category = POINTER_V;
					else if ($1->kind == "POINTER_C") attribute->category = POINTER_C;
					else if ($1->kind == "VARIABLE") attribute->category = VARIABLE;
					else if ($1->kind == "CONSTANTE") attribute->category = CONSTANT;

					if ($6->type == "mango") attribute->value = stoi($6->value);
					else if ($6->type == "manguita") {
						if ($4->type == "manguangua") attribute->value = stod($6->value);
						else attribute->value = stof($6->value);
					} else if ($6->type == "manguangua") attribute->value = $6->dvalue; // Conserva precision.
					else if ($6->type == "tas_claro"){
						attribute->value = stoi($6->value);
						if (!attribute->info.empty()) attribute->info[0].first = ($6->value == "1" ? "Sisa" : "Nolsa");
						else attribute->info.push_back({($6->value == "1" ? "Sisa" : "Nolsa"), nullptr});
					} else if ($6->type == "higuerote") attribute->value = $6->value;
					else if ($6->type == "negro"){
						attribute->value = $6->value.empty() ? '\0' : $6->value[0];
					} else if ($6->type == "pointer"){
						/* POR IMPLEMENTAR */
						//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
						attribute->value = nullptr;
					} else {
						FLAG_ERROR = INTERNAL;
						string error_message = "TIPO DESCONOCIDO: Asignando 'nullptr' a: '" + string($2) + "'.";
						yyerror(error_message.c_str());
						attribute->value = nullptr;
					}
					symbolTable.insert_symbol($2, *attribute);
				}
			}
		}
		// Actualizamos AST
		$$ = makeASTNode("Asignación", "", "", "=");
		auto declarationNode = makeASTNode($2, "Declaración", $4->type, $1->kind);
		if ($4->category == "Array"){
			declarationNode->children = $4->children;
		}
		$$->children.push_back(declarationNode);
		$$->children.push_back($6);
		
	}
	| declaracion_funcion cerrar_scope { $$ = $1; }
	;

tipo_declaracion:
	declaracion_aputador T_CULITO {
		$1->kind = $1->name == "POINTER" ? "POINTER_V" : "VARIABLE";
		$1->category = "Declaración";
		$$ = $1;
	}
	| declaracion_aputador T_JEVA {
		$1->kind = $1->name == "POINTER" ? "POINTER_C" : "CONSTANTE";
		$1->category = "Declaración";
		$$ = $1;
	}
	;

declaracion_aputador:
	{ $$ = makeASTNode(""); }
	| T_AHITA { $$ = makeASTNode("POINTER"); }
	;

tipos:
	tipo_valor { $$ = $1; }
	| tipos T_IZQCORCHE expresion T_DERCORCHE {
		if ($3->type != "mango") {
			FLAG_ERROR = SIZE_ARRAY_INVALID;
			yyerror($3->type.c_str());
		}

		if ($3->value.empty()) {
			FLAG_ERROR = EMPTY_ARRAY_CONSTANT;
			yyerror("Tamaño de array vacío o inválido");
		}

		$$ = makeASTNode("Array", "Array", $1->type);
		$$->children.push_back(makeASTNode($3->name, "Array_Size", $3->type, "", $3->value));
	}
	| T_ID {
		Attributes* attr = symbolTable.search_symbol($1);
		if (attr == nullptr) {
			FLAG_ERROR = NON_DEF_TYPE;
			yyerror($1);
			$$ = makeASTNode($1, "Identificador", "Unknown");
		} else {
			$$ = makeASTNode($1, "Identificador", $1);
		}
	}
	| T_UNCONO { $$ = makeASTNode("un_coño", "Tipo_Funcion"); }
	;

tipo_valor:
	T_MANGO { $$ = makeASTNode("mango", "Type", "mango"); }
	| T_MANGUITA { $$ = makeASTNode("manguita", "Type", "manguita"); }
	| T_MANGUANGUA { $$ = makeASTNode("manguangua", "Type", "manguangua"); }
	| T_NEGRO { $$ = makeASTNode("negro", "Type", "negro"); }
	| T_HIGUEROTE { $$ = makeASTNode("higuerote", "Type", "higuerote"); }
	| T_TASCLARO { $$ = makeASTNode("tas_claro", "Type", "tas_claro"); }
	;

asignacion:
	T_ID operadores_asignacion expresion {
		Attributes* attribute = symbolTable.search_symbol($1);
		string id = string($1);
		string declared_type = "Desconocido";

		if (attribute == nullptr){
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else {
			if (!attribute->info.empty()) {
				string info_var_check = get<string>(attribute->info[0].first);
				if (info_var_check == "CICLO FOR"){
					FLAG_ERROR = VAR_FOR;
					yyerror($1);
				}
				if (info_var_check == "MANEJO ERROR"){
					FLAG_ERROR = VAR_TRY;
					yyerror($1);
				}
			}
			if (attribute->category == CONSTANT || attribute->category == POINTER_C) {
				FLAG_ERROR = MODIFY_CONST;
				yyerror($1);
			}
			
			if (!attribute->type) {
				FLAG_ERROR = INTERNAL;
				string error_message = "ERROR INTERNO: El tipo de \"" + id + "\" no esta definido.";
				yyerror(error_message.c_str());
			} else {
				declared_type = attribute->type->symbol_name;
				if (declared_type != $3->type && (declared_type != "manguangua" || $3->type != "manguita")) {
					FLAG_ERROR = TYPE_ERROR;
					string error_message = "\"" + id + "\" de tipo '" + declared_type + 
						"' y le quieres meter un tipo '" + $3->type + "', marbaa' bruja.";
					yyerror(error_message.c_str());
				}
			}
			
			string op = $2->kind;
			if (op != "=" && holds_alternative<nullptr_t>(attribute->value) && attribute->category != PARAMETERS) {
				FLAG_ERROR = NON_VALUE;
				yyerror($1);
			} else {
				if (declared_type == "mango") {
					if (op == "=") attribute->value = stoi($3->value);
					else if (op == "+=") attribute->value = get<int>(attribute->value) + stoi($3->value);
					else if (op == "-=") attribute->value = get<int>(attribute->value) - stoi($3->value);
					else if (op == "*=") attribute->value = get<int>(attribute->value) * stoi($3->value);
				} else if (declared_type == "manguita") {
					if (op == "=") attribute->value = stof($3->value);
					else if (op == "+=") attribute->value = get<float>(attribute->value) + stof($3->value);
					else if (op == "-=") attribute->value = get<float>(attribute->value) - stof($3->value);
					else if (op == "*=") attribute->value = get<float>(attribute->value) * stof($3->value);
				} else if (declared_type == "manguangua") {
					if ($3->type == "manguita") {
						if (op == "=") attribute->value = stof($3->value);
						else if (op == "+=") attribute->value = get<double>(attribute->value) + stof($3->value);
						else if (op == "-=") attribute->value = get<double>(attribute->value) - stof($3->value);
						else if (op == "*=") attribute->value = get<double>(attribute->value) * stof($3->value);
					} else {
						if (op == "=") attribute->value = $3->dvalue;
						else if (op == "+=") attribute->value = get<double>(attribute->value) + $3->dvalue;
						else if (op == "-=") attribute->value = get<double>(attribute->value) - $3->dvalue;
						else if (op == "*=") attribute->value = get<double>(attribute->value) * $3->dvalue;
					}
				} else if (declared_type == "tas_claro" && op == "="){
					attribute->value = stoi($3->value);
					if (!attribute->info.empty()) attribute->info[0].first = ($3->value == "1" ? "Sisa" : "Nolsa");
					else attribute->info.push_back({($3->value == "1" ? "Sisa" : "Nolsa"), nullptr});
				} else if (declared_type == "higuerote" && op == "=") attribute->value = $3->value;
				else if (declared_type == "negro") attribute->value = $3->value.empty() ? '\0' : $3->value[0];
				else if (declared_type == "pointer"){
					/* POR IMPLEMENTAR */
					//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
					attribute->value = nullptr;
				} else {
					FLAG_ERROR = INTERNAL;
					string error_message = "TIPO DESCONOCIDO: '" + declared_type + "'.";
					yyerror(error_message.c_str());
					attribute->value = nullptr;
				}
			}
		}

		$$ = $2;
		$$->children.push_back(makeASTNode($1, "Identificador", declared_type));
		$$->children.push_back($3);
	}    
	| T_ID T_IZQCORCHE expresion T_DERCORCHE operadores_asignacion expresion {
		// Verificar si el identificador es un array
		Attributes* array_attr = symbolTable.search_symbol($1);
		if (array_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else if (array_attr->category != ARRAY) {
			FLAG_ERROR = TYPE_ERROR;
			string error_message = "\"" + string($1) + "\" no es un array, marbaa' bruja.";
			yyerror(error_message.c_str());
		}

		if ($3->type != "mango") {
			FLAG_ERROR = INT_INDEX_ARRAY;
			yyerror($3->type.c_str());
		}

		int size_array = 0;
		if (holds_alternative<nullptr_t>(array_attr->value)) {
			FLAG_ERROR = NON_VALUE;
			yyerror($1);
		} else {
			size_array = get<int>(array_attr->value);
		}
		
		string declared_type = array_attr->type->symbol_name;
		if (declared_type != $6->type && (declared_type != "manguangua" || $6->type != "manguita")) {
			FLAG_ERROR = TYPE_ERROR;
			string error_message = "\"" + string($1) + "\" de tipo '" + declared_type + 
				"' y le quieres meter un tipo '" + $6->type + "', marbaa' bruja.";
			yyerror(error_message.c_str());
		}

		if (array_attr->info.empty()) {
			FLAG_ERROR = INTERNAL;
			yyerror("ERROR INTERNO: El array no tiene elementos.");
		}

		int index = stoi($3->value);
		Attributes* elem_attr = nullptr;
		if (index < 0 || index >= size_array) {
			FLAG_ERROR = SEGMENTATION_FAULT;
			yyerror($3->value.c_str());
			elem_attr = symbolTable.search_symbol(get<string>(array_attr->info[0].first));
		} else {
			elem_attr = symbolTable.search_symbol(get<string>(array_attr->info[index].first));
		}

		// =================================================
		// =                  Operaciones                  =
		// =================================================
		string op = $5->kind;
		if (op != "=" && holds_alternative<nullptr_t>(elem_attr->value)) {
			FLAG_ERROR = NON_VALUE;
			yyerror($1);
		} else if (op == "="){
			if (declared_type == "mango") elem_attr->value = stoi($6->value);
			else if (declared_type == "manguita") elem_attr->value = stof($6->value);
			else if (declared_type == "manguangua") {
				if ($6->type == "manguita") elem_attr->value = stof($6->value);
				else elem_attr->value = $6->dvalue; // Conserva precision.
			}
			else if (declared_type == "tas_claro"){
				elem_attr->value = stoi($6->value);
				if (!elem_attr->info.empty()) elem_attr->info[0].first = ($6->value == "1" ? "Sisa" : "Nolsa");
				else elem_attr->info.push_back({($6->value == "1" ? "Sisa" : "Nolsa"), nullptr});
			} else if (declared_type == "higuerote") elem_attr->value = $6->value;
			else if (declared_type == "negro"){
				elem_attr->value = $6->value.empty() ? '\0' : $6->value[0];
			} else if (declared_type == "pointer"){
				/* POR IMPLEMENTAR */
				//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
				elem_attr->value = nullptr;
			} else {
				FLAG_ERROR = INTERNAL;
				string error_message = "TIPO DESCONOCIDO: '" + declared_type + "'.";
				yyerror(error_message.c_str());
				elem_attr->value = nullptr;
			}
		} else {
			if (declared_type == "mango") {
				if (op == "+=") elem_attr->value = get<int>(elem_attr->value) + stoi($6->value);
				else if (op == "-=") elem_attr->value = get<int>(elem_attr->value) - stoi($6->value);
				else if (op == "*=") elem_attr->value = get<int>(elem_attr->value) * stoi($6->value);
			} else if (declared_type == "manguita") {
				if (op == "+=") elem_attr->value = get<float>(elem_attr->value) + stof($6->value);
				else if (op == "-=") elem_attr->value = get<float>(elem_attr->value) - stof($6->value);
				else if (op == "*=") elem_attr->value = get<float>(elem_attr->value) * stof($6->value);
			} else if (declared_type == "manguangua") {
				if ($6->type == "manguita"){
					if (op == "+=") elem_attr->value = get<double>(elem_attr->value) + stof($6->value);
					else if (op == "-=") elem_attr->value = get<double>(elem_attr->value) - stof($6->value);
					else if (op == "*=") elem_attr->value = get<double>(elem_attr->value) * stof($6->value);
				} else { // Conserva precision con $6->dvalue
					if (op == "+=") elem_attr->value = get<double>(elem_attr->value) + $6->dvalue;
					else if (op == "-=") elem_attr->value = get<double>(elem_attr->value) - $6->dvalue;
					else if (op == "*=") elem_attr->value = get<double>(elem_attr->value) * $6->dvalue;
				}
			} else if (declared_type == "pointer"){
				/* POR IMPLEMENTAR */
				//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
				elem_attr->value = nullptr;
			} else {
				FLAG_ERROR = INTERNAL;
				string error_message = "TIPO DESCONOCIDO: '" + declared_type + "'.";
				yyerror(error_message.c_str());
				elem_attr->value = nullptr;
			}
		}

		$$ = $5;
		$$->children.push_back(makeASTNode($1, "Identificador", declared_type));
		$$->children.push_back($6);
	}
	| T_ID T_PUNTO T_ID operadores_asignacion expresion {
		$$ = $5;
	}
	;

operadores_asignacion:
	T_ASIGNACION    { $$ = makeASTNode("Asignación", "", "", "="); }
	| T_OPASIGSUMA  { $$ = makeASTNode("Suma Compuesta", "", "", "+="); }
	| T_OPASIGRESTA { $$ = makeASTNode("Resta Compuesta", "", "", "-="); }
	| T_OPASIGMULT  { $$ = makeASTNode("Multiplicación Compuesta", "", "", "*="); }
	;

expresion:
	T_ID {
		Attributes* attr = symbolTable.search_symbol($1);
		if (attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		}
		string type, kind, valor = "";
		if (!holds_alternative<nullptr_t>(attr->value)) {
			type = attr->type->symbol_name;
			if (type == "mango") valor = to_string(get<int>(attr->value));
			else if (type == "manguita") valor = to_string(get<float>(attr->value));
			else if (type == "manguangua") {
				ostringstream oss;
				oss.precision(10); // Ajustar la precisión según lo que quieras mostrar.
				oss << scientific << get<double>(attr->value);
				valor = oss.str();
			}
			else if (type == "negro") valor = string(1, get<char>(attr->value));
			else if (type == "higuerote") valor = string(get<string>(attr->value));
			else if (type == "tas_claro") {
				valor = to_string(get<int>(attr->value));
				kind = valor == "1" ? "Sisa" : "Nolsa";
			} else if (type == "pointer") valor = "nullptr"; // POR IMPLEMENTAR
			else {
				FLAG_ERROR = INTERNAL;
				yyerror("ERROR INTERNO: Lexer proporciona un tipo invalido.");
			}
		}
		$$ = makeASTNode($1, "Identificador", type, kind, valor);
		if (type == "manguangua") $$->dvalue = get<double>(attr->value); // Conservar precisión de valor
	}
	| T_VALUE {
		string tipo = typeToString($1.type);
		string category = "Number";
		string kind, valor = "";
		if (tipo == "mango") valor = to_string($1.ival);
		else if (tipo == "manguita") valor = to_string($1.fval);
		else if (tipo == "manguangua") {
			ostringstream oss;
			oss.precision(10); //Ajustar la precisión según lo que quieras mostrar.
			oss << scientific << $1.dval;
			valor = oss.str();
		} else if (tipo == "negro") {
			valor = string(1, $1.cval);
			category = "Char";
		} else if (tipo == "higuerote") {
			valor = string($1.sval);
			category = "String";
		} else {
			FLAG_ERROR = INTERNAL;
			yyerror("ERROR INTERNO: Lexer proporciona tipo un tipo invalido.");
		}

		$$ = makeASTNode("Literal", category, tipo, kind, valor);
		if (tipo == "manguangua") $$->dvalue = $1.dval; // Conservar presicion de valor
	}
	| T_SISA { $$ = makeASTNode("Literal", "Bool", "tas_claro", "Sisa", "1"); }
	| T_NOLSA { $$ = makeASTNode("Literal", "Bool", "tas_claro", "Nolsa", "0"); }
	| T_PELABOLA { $$ = nullptr; }
	| expresion_apuntador 
	| expresion_nuevo
	| T_IZQCORCHE secuencia T_DERCORCHE { $$ = $2; } // Arreglos
	| T_ID T_IZQCORCHE expresion T_DERCORCHE {} // Acceso a elementos de un array
	| T_IZQPAREN expresion T_DERPAREN { $$ = $2; } // Expresion parantizada.
	| T_NELSON expresion { $$ = nullptr; }
	| T_OPRESTA expresion %prec T_OPRESTA {
		$$ = $2;
		$$->value = "-" + $$->value;
		if ($$->dvalue != 0.0) $$->dvalue = -$$->dvalue; // Negar el valor double si es necesario
	}
	| expresion T_FLECHA expresion
	| expresion T_OPSUMA expresion
	| expresion T_OPRESTA expresion
	| expresion T_OPMULT expresion
	| expresion T_OPDIVDECIMAL expresion
	| expresion T_OPDIVENTERA expresion
	| expresion T_OPMOD expresion
	| expresion T_OPEXP expresion
	| expresion T_OPIGUAL expresion
	| expresion T_OPDIFERENTE expresion
	| expresion T_OPMAYOR expresion
	| expresion T_OPMAYORIGUAL expresion
	| expresion T_OPMENOR expresion
	| expresion T_OPMENORIGUAL expresion
	| expresion T_OSEA expresion
	| expresion T_YUNTA expresion
	| entrada_salida
	| variante
	| funcion
	| casting
	;

operaciones_unitarias:
	T_OPDECREMENTO { $$ = makeASTNode("--", "Operación_Unitaria"); }
	| T_OPINCREMENTO { $$ = makeASTNode("++", "Operación_Unitaria"); }
	;

expresion_apuntador:
	T_AKITOY T_ID { $$ = nullptr; }
	| T_AKITOY T_ID T_PUNTO T_ID { $$ = nullptr; }
	;

expresion_nuevo:
	T_CEROKM tipos { $$ = $2; }
	| expresion_nuevo T_IZQPAREN expresion T_DERPAREN
	;

secuencia:
	{ $$ = nullptr; }
	| expresion { $$ = $1; }
	| secuencia T_COMA expresion {
		$$ = makeASTNode("Secuencia", "Expresión", "", ",");
		$$->children.push_back($1);
		$$->children.push_back($3);
	}

condicion:
	T_SIESASI T_IZQPAREN expresion T_DERPAREN {
		/* POR IMPLEMENTAR */
		
	} abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope {
		/* POR IMPLEMENTAR */
		
	} alternativa {
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	;

alternativa:
	{ $$ = nullptr; } 
	| T_OASI T_IZQPAREN expresion T_DERPAREN {
		/* POR IMPLEMENTAR */
	}
	abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope {
	   /* POR IMPLEMENTAR */
	} alternativa { 
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	| T_NOJODA abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope {
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	;

bucle:
	indeterminado { $$ = $1; }
	| determinado { $$ = $1; }
	;

indeterminado:
	T_ECHALEBOLAS T_IZQPAREN expresion T_DERPAREN {
		/* POR IMPLEMENTAR */
	} abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE {
		/* POR IMPLEMENTAR */
	} cerrar_scope { $$ = nullptr; }
	;

var_ciclo_determinado:
	T_ID T_ENTRE expresion T_HASTA expresion {
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	;

determinado:
	T_REPITEBURDA abrir_scope var_ciclo_determinado T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope{
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	| T_REPITEBURDA abrir_scope var_ciclo_determinado T_CONFLOW T_VALUE T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope{
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	;

entrada_salida:
	T_RESCATA T_IZQPAREN secuencia T_DERPAREN { $$ = nullptr; }
	| T_HABLAME T_IZQPAREN expresion T_DERPAREN { $$ = nullptr; }
	;

secuencia_declaraciones:
	{ $$ = nullptr; }
	| secuencia_declaraciones T_PUNTOCOMA T_ID T_DOSPUNTOS tipos { $$ = nullptr; }
	| T_ID T_DOSPUNTOS tipos { $$ = nullptr; }
	;

variante: 
	T_COLIAO T_ID {
		/* POR IMPLEMENTAR */
	} abrir_scope T_IZQLLAVE secuencia_declaraciones T_PUNTOCOMA T_DERLLAVE {
		/* POR IMPLEMENTAR */
	} cerrar_scope { $$ = nullptr; }
	;

struct: 
	T_ARROZCONMANGO T_ID {
		/* POR IMPLEMENTAR */
	} abrir_scope T_IZQLLAVE secuencia_declaraciones T_PUNTOCOMA T_DERLLAVE {
		/* POR IMPLEMENTAR */
	} cerrar_scope { $$ = nullptr; }
	;

firma_funcion: 
	T_ECHARCUENTO T_ID {
		if (symbolTable.search_symbol($2) != nullptr) {
			FLAG_ERROR = ALREADY_DEF_FUNC;
			yyerror($2);
		} else {
			Attributes* func_attr = new Attributes();
	        func_attr->symbol_name = $2;
	        func_attr->scope = symbolTable.current_scope; // Scope de la función
	        func_attr->type = symbolTable.search_symbol("funcion$");
	        func_attr->category = FUNCTION;
	        func_attr->value = nullptr;
			symbolTable.insert_symbol($2, *func_attr);
		}

		$$ = makeASTNode($2, "Firma_Funcion");
	}
	;

parametro:
	T_AKITOY T_ID T_DOSPUNTOS tipos { $$ = nullptr; }
	| T_ID T_DOSPUNTOS tipos {
		Attributes* param_attr = symbolTable.search_symbol($1);
		bool error = false;
		if (param_attr != nullptr) {
			if (param_attr->category == PARAMETERS && param_attr->scope == symbolTable.current_scope) {
				FLAG_ERROR = ALREADY_DEF_PARAM;
				string error_message = "'" + param_attr->symbol_name + "' dos veces en el mismo cuento?, te gusta la versatilidad locota.";
				yyerror($1);
				error = true;
			}
		}
		if (!error) {
			Attributes* param_attr = new Attributes();
			param_attr->symbol_name = $1;
			param_attr->scope = symbolTable.current_scope;
			param_attr->type = symbolTable.search_symbol($3->type);
			param_attr->category = PARAMETERS;
			param_attr->value = nullptr;
			symbolTable.insert_symbol($1, *param_attr);
		}

		$$ = makeASTNode($1, "Parámetro", $3->type);
	}

secuencia_parametros:
	{ $$ = nullptr; }
	| parametro { $$ = $1; }
	| secuencia_parametros T_COMA parametro {
		$$ = makeASTNode("Secuencia", "Declaración", "", ",");
		$$->children.push_back($1);
		$$->children.push_back($3);
	}
	;

declaracion_funcion:
	firma_funcion abrir_scope T_IZQPAREN secuencia_parametros T_DERPAREN T_LANZA tipos T_IZQLLAVE instrucciones T_DERLLAVE { 
		string func_name = $1->name;
		string func_type = $7->name;

		// Actualizamos el tipo de retorno de la funcion.
		Attributes* func_attr = symbolTable.search_symbol(func_name);
		if (func_attr != nullptr) {
			func_attr->type = symbolTable.search_symbol(func_type);

			// Recolectar todos los nodos de parámetro
			if ($4) {
				set<string> categories = {"Parámetro", "Parámetro_Referencia", "Parámetro_Puntero"};
				vector<ASTNode*> param_nodes;
				collect_nodes_by_categories($4, categories, param_nodes);
				for (auto param : param_nodes) {
					Attributes* param_attr = symbolTable.search_symbol(param->name);
				    if (param_attr) func_attr->info.push_back({"PARAM("+ param->name +")", param_attr});
				}
			}
			$$ = makeASTNode(func_name, "Declaración", func_type, "Función");
			if ($4) $$->children.push_back($4); // Agregar la secuencia de parámetros
			if ($9) $$->children.push_back($9); // Agregar instrucciones
		}
	}
	;

funcion:
	T_ID T_IZQPAREN secuencia T_DERPAREN {
		Attributes* func_attr = symbolTable.search_symbol($1);
		if (func_attr == nullptr) {
			FLAG_ERROR = NON_DEF_FUNC;
			yyerror($1);
			$$ = makeASTNode($1, "Llamada_Funcion", "Unknown");
		} else if (func_attr->category != FUNCTION) {
			FLAG_ERROR = TYPE_ERROR;
			string error_message = "\"" + string($1) + "\" y no es una función, marbaa' bruja.";
			yyerror(error_message.c_str());
			$$ = makeASTNode($1, "Llamada_Funcion", func_attr->type->symbol_name);
		} else {
			// Recolectar todos los nodos de argumentos.
			set<string> arg_categories = {"Identificador", "Number", "Char", "String", "Bool"};
			vector<ASTNode*> arg_nodes;
			collect_nodes_by_categories($3, arg_categories, arg_nodes);
			
			if (arg_nodes.size() > func_attr->info.size()) {
				FLAG_ERROR = FUNC_PARAM_EXCEEDED;
				yyerror($1);
			} else if (arg_nodes.size() < func_attr->info.size()) {
				FLAG_ERROR = FUNC_PARAM_MISSING;
				yyerror($1);
			} else {
				// Verificacion de tipo en cada argumento.
				for (int i = 0; i < arg_nodes.size(); i++) {
					ASTNode* arg_node = arg_nodes[i];
					Attributes* param_attr = func_attr->info[i].second;

					if (param_attr == nullptr) {
						FLAG_ERROR = INTERNAL;
						yyerror("ERROR: Parámetro no encontrado");
					} else if (param_attr->type->symbol_name != arg_node->type && (param_attr->type->symbol_name != "manguangua" || arg_node->type != "manguita")) {
						FLAG_ERROR = TYPE_ERROR;
						string error_message = "\"" + param_attr->symbol_name + "\" de tipo '" + param_attr->type->symbol_name + 
							"' y le quieres meter un tipo '" + arg_node->type + "', marbaa' bruja.";
						yyerror(error_message.c_str());
					}
				}
			}
			
			/* Implementar logica de value de retorno */
			string valor = "0";

			$$ = makeASTNode($1, "Llamada_Funcion", func_attr->type->symbol_name, "", valor);
			if ($3) $$->children.push_back($3); // Agregar la secuencia de parámetros
		}
	}

var_manejo_error:
	T_COMO abrir_scope T_ID {
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}

manejador:
	{ $$ = nullptr; }
	| T_FUERADELPEROL abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE {
		/* POR IMPLEMENTAR */
	} cerrar_scope { $$ = nullptr; }
	| T_FUERADELPEROL var_manejo_error T_IZQLLAVE instrucciones T_DERLLAVE {
		/* POR IMPLEMENTAR */
	} cerrar_scope { $$ = nullptr; }
	;

manejo_error:
	T_T_MEANDO abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE {
		/* POR IMPLEMENTAR */
	} cerrar_scope manejador {
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	;

casting:
	T_CASTEO expresion {
		/* POR IMPLEMENTAR */
		$$ = nullptr;
	}
	;

%%

void yyerror(const char *var) {
	FIRST_ERROR = true;

	string error_msg; // Variable para construir el mensaje de error

	if (FLAG_ERROR == SEMANTIC) {
		extern char* yytext;
		error_msg = "Qué garabato escribiste en línea " + to_string(yylineno) +
					", columna " + to_string(yylloc.first_column) +
					": '" + yytext + "'\n" + var;
		addError(FLAG_ERROR, error_msg);
	} else {
		error_msg = "Sendo peo en la linea " + to_string(yylineno) +
					", columna " + to_string(yylloc.first_column) + ": ";
		switch (FLAG_ERROR) {

			case ARRAY_LITERAL_SIZE_MISMATCH:
				error_msg += string(var);
				break;
			case NON_DEF_VAR:
				error_msg += "Esta variable \"" + string(var) + "\" es burro e' fantasma.";
				break;
			case ALREADY_DEF_VAR:
				error_msg += "Esta variable \"" + string(var) + "\" es convive, marbao' copion.";
				break;

			case NON_DEF_FUNC:
				error_msg += "Este cuento \"" + string(var) + "\" no lo echaste, marbaa' locota.";
				break;
			case ALREADY_DEF_FUNC:
				error_msg += "Este cuento \"" + string(var) + "\" ya lo echaron, marbao' copion.";
				break;

			case NON_DEF_STRUCT:
				error_msg += "Este arroz_con_mango \"" + string(var) + "\" esta en tu cabeza nada más. Deja la droga.";
				break;
			case ALREADY_DEF_STRUCT:
				error_msg += "Este arroz_con_mango \"" + string(var) + "\" ya se prendió locota.";
				break;

			case NON_DEF_UNION:
				error_msg += "Este coliao \"" + string(var) + "\" esta en tu cabeza nada más. Deja la droga.";
				break;
			case ALREADY_DEF_UNION:
				error_msg += "Quieres colear a \"" + string(var) + "\" dos veces, marbao' abusador.";
				break;

			case NON_DEF_TYPE:
				error_msg += "El tipo este \"" + string(var) + "\" lo tienes adentro debe ser. Nadie lo ve.";
				break;
			case ALREADY_DEF_TYPE:
				error_msg += "El tipo este \"" + string(var) + "\" ya existe. Dice que te extraña de anoche.";
				break;

			case NON_DEF_ATTR:
				error_msg += "Este atributo \"" + string(var) + "\" esta en tu cabeza nada más. Deja la droga.";
				break;
			case ALREADY_DEF_ATTR:
				error_msg += "Este atributo \"" + string(var) + "\" es de otro peo, marbao' copion.";
				break;

			case VAR_FOR:
				error_msg += "Esta variable \"" + string(var) + "\" es de `repite_burda`. Déjala quieta, no se cambia. Men tiende?";
				break;

			case VAR_TRY:
				error_msg += "Esta variable \"" + string(var) + "\" es de `Meando_fuera_del_perol`. Déjala quieta, no se cambia. Men tiendes marbao'?";
				break;

			case NON_VALUE: 
				error_msg += "Esta vaina \"" + string(var) + "\" tiene el amor que te dió ella, o sea vacío.";
				break;

			case TYPE_ERROR:
				error_msg += "Tas en droga?. Tienes " + string(var);
				break;

			case MODIFY_CONST:
				error_msg += "Aja y despues que cambies \"" + string(var) + "\" vas a pedir que un Chavista reparta plata, hasta err diablo rinde.";

			case SEGMENTATION_FAULT:
				error_msg += "Te fuiste pal quinto c#%o. Índice \"" + string(var) + "\" fuera de rango.";
				break;

			case FUNC_PARAM_EXCEEDED:
				error_msg += "No le metas al cuento \"" + string(var) + "\" más vainas, no caben loco.";
				break;
			case FUNC_PARAM_MISSING:
				error_msg += "Párale bolas al cuento \"" + string(var) + "\" que faltan más vainas.";
				break;
			case ALREADY_DEF_PARAM:
				error_msg += "Ay vale!. Te gusta tener " + string(var);
				break;

			case EMPTY_ARRAY_CONSTANT:
				error_msg += "El array \"" + string(var) + "\" es una jeva. No se cambia loco, respeta.";
				break;

			case POINTER_ARRAY:
				error_msg += "El array \"" + string(var) + "\" es un apuntador. Cuidao te dá.";
				break;

			case INT_SIZE_ARRAY:
				error_msg += "Los arrays solo reciben mangos en el size. Le estas metiendo un '" + string(var) + "', bruja.";
				break;
			case INT_INDEX_ARRAY:
				error_msg += "Al array no se le entra con \"" + string(var) + "\" solo con mangos piaso e' mongolico."; 
				break;
			case SIZE_ARRAY_INVALID:
				error_msg += "Le quieres meter vainas raras al tamaño de un array, mira esa vaina diske '" + string(var) + "', solo mangos positivos, loca perdia'.";
				break;

			case INTERNAL:
				error_msg += string(var);
				break;

			default:
				cout << "Este beta es: " << FLAG_ERROR;
				error_msg += "Error desconocido.";
				break;
		}
		addError(FLAG_ERROR, error_msg); // Agrega el mensaje al diccionario de errores
		FLAG_ERROR = SEMANTIC; // Resetea el tipo de error
	}
}