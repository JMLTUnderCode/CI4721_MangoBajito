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
	{EMPTY_STRUCT, {}},
	{NON_DEF_UNION, {}},
	{ALREADY_DEF_UNION, {}},
	{EMPTY_UNION, {}},
	{NON_DEF_TYPE, {}},
	{ALREADY_DEF_TYPE, {}},
	{NON_DEF_ATTR, {}},
	{ALREADY_DEF_ATTR, {}},
	{MODIFY_VAR_FOR, {}},
	{TRY_ERROR, {}},
	{NON_VALUE, {}},
	{TYPE_ERROR, {}},
	{MODIFY_CONST, {}},
	{SEGMENTATION_FAULT, {}},
	{FUNC_PARAM_EXCEEDED, {}},
	{FUNC_PARAM_MISSING, {}},
	{ALREADY_DEF_PARAM, {}},
	{EMPTY_ARRAY_CONSTANT, {}},
	{POINTER_ARRAY, {}},
	{INT_INDEX_ARRAY, {}},
	{SIZE_ARRAY_INVALID, {}},
	{INTERNAL, {}},
	{EMPTY, {}},
};

// Variables globales de contexto para el análisis sintáctico y semántico
systemError FLAG_ERROR = SEMANTIC;
bool FIRST_ERROR = false;

// Label Generator
LabelGenerator labelGen;
%}

%code requires {
	#include "mango_bajito.hpp"

	using namespace std;

	// Atributos de expresiones para el parser
	struct Type_and_Value {
		enum Type { INT, FLOAT, DOUBLE, BOOL, STRING, POINTER, ID, CHAR, VOID, ARRAY_LITERAL } type;
		union {
			int ival;
			float fval;
			double dval;
			char* sval;
			char cval;
		};
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

	// Función auxiliar: string a enum
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
}

%union {
	Type_and_Value att_val; // Usa el struct definido
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
%type <ast> instruccion secuencia_instrucciones instrucciones bloque_instrucciones
%type <ast> declaracion tipo_declaracion declaracion_aputador 
%type <ast> estructura firma_estructura clase_estructura atributo secuencia_atributos
%type <ast> tipos tipo_valor
%type <ast> expresion expresion_apuntador expresion_nuevo 
%type <ast> secuencia
%type <ast> condicion guardia_siesasi alternativa guardia guardia_con_bloque
%type <ast> bucle indeterminado determinado var_ciclo_determinado
%type <ast> firma_funcion parametro secuencia_parametros funcion llamada_funcion entrada_salida
%type <ast> manejo_error manejador var_manejo_error
%type <ast> casting

// Declaracion de precedencia y asociatividad de Operadores
// Asignacion
%right T_ASIGNACION 

// Logicos y comparativos
%left T_OSEA
%left T_YUNTA
%nonassoc T_OPIGUAL T_OPDIFERENTE T_OPMAYOR T_OPMENOR T_OPMAYORIGUAL T_OPMENORIGUAL

// Aritmeticos
%left T_OPSUMA T_OPRESTA T_OPMULT T_OPDIVENTERA T_OPDIVDECIMAL T_OPMOD
%nonassoc T_IZQPAREN T_DERPAREN
%right T_OPEXP


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
		concat_TAC(ast_root, $2, $3);
		$$ = ast_root;
		if (FIRST_ERROR) printErrors();
		else {
			symbolTable.print_table();
			if (ast_root) print_AST(ast_root);
			if (ast_root){
				print_TAC(ast_root);
			};
		}
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
	T_SE_PRENDE abrir_scope T_IZQPAREN T_DERPAREN bloque_instrucciones T_PUNTOCOMA cerrar_scope { $$ = $5; }
	;

bloque_instrucciones:
	T_IZQLLAVE instrucciones T_DERLLAVE { $$ = $2; }

instrucciones:
	{ $$ = nullptr; }
	| secuencia_instrucciones { $$ = $1; }

secuencia_instrucciones:
	instruccion T_PUNTOCOMA { $$ = $1; }
	| secuencia_instrucciones instruccion T_PUNTOCOMA {
		$$ = makeASTNode("Instrucción", "", "", ";");
		$$->children.push_back($1);
		$$->children.push_back($2);
		concat_TAC($$, $1, $2);
	}
	;

instruccion:
	declaracion { $$ = $1; }
	| asignacion { $$ = $1; }
	| llamada_funcion { $$ = $1; }
	| condicion { $$ = $1; }
	| bucle { $$ = $1; }
	| entrada_salida { $$ = $1; }
	| manejo_error { $$ = $1; }
	| T_KIETO { $$ = nullptr; }
	| T_ROTALO { $$ = nullptr; }
	| T_LANZATE expresion { 
		$$ = $2;
		concat_TAC($$, $2);
		if ($2) {
			$$->tac.push_back("return " + $2->temp);
		}else{
			$$->tac.push_back("return");
		};
	}
	| expresion operaciones_unitarias {
		ASTNode* new_node = makeASTNode("Operación", $2->category);
		new_node->children.push_back($1);
		
		Attributes* var_attr = symbolTable.search_symbol($1->name);
		if (var_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1->name.c_str());
		} else {
			if (var_attr->type != nullptr && isNumeric(var_attr->type->symbol_name)) { // Verificar si es de tipo numerico.		
				new_node->type = var_attr->type->symbol_name;
				if (var_attr->category != PARAMETERS){ // Si es parametro de una funcion no hay problema.
					if(var_attr->category == CONSTANT || var_attr->category == POINTER_C) {
						FLAG_ERROR = MODIFY_CONST;
						yyerror($1->name.c_str());
					} else {
						string op = $2->name;
						if (holds_alternative<int>(var_attr->value)) { // De lo contrario hay que verificar si tiene valor numero asignado.
							int old_val = get<int>(var_attr->value);
							if (op == "--" ) var_attr->value = --old_val;
							if (op == "++" ) var_attr->value = ++old_val;
							new_node->ivalue = old_val;

						} else if (holds_alternative<float>(var_attr->value)) {
							float old_val = get<float>(var_attr->value);
							if (op == "--" ) var_attr->value = --old_val;
							if (op == "++" ) var_attr->value = ++old_val;
							new_node->fvalue = old_val;

						} else if (holds_alternative<double>(var_attr->value)) {
							double old_val = get<double>(var_attr->value);
							if (op == "--" ) var_attr->value = --old_val;
							if (op == "++" ) var_attr->value = ++old_val;
							new_node->dvalue = old_val;
						} else {
							FLAG_ERROR = NON_VALUE;
							yyerror($1->name.c_str());
						}
					}
				}
			} else {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "\"" + $1->name + "\" de tipo '" + var_attr->type->symbol_name + "' y debe ser de tipo 'mango' | 'manguita' | 'manguangua', locota.";
				yyerror(error_msg.c_str());
			}
		}
		$$ = new_node;
		if ($2->name == "--"){
			$$->tac.push_back($1->temp + " := " + $1->temp + " - 1");
		} else {
			$$->tac.push_back($1->temp + " := " + $1->temp + " + 1");
		}
	}
	| T_BORRADOL T_ID { $$ = nullptr; }
	| T_BORRADOL T_ID T_PUNTO T_ID { $$ = nullptr; }
	;

declaracion:
	tipo_declaracion T_ID T_DOSPUNTOS tipos {
		string declared_type = $4->type;
		
		Attributes* type_attr = symbolTable.search_symbol(declared_type);
		if (type_attr == nullptr){
			FLAG_ERROR = INTERNAL;
			yyerror("ERROR: Tipo no encontrado");
		} else {
			// Declaracion de Arreglos
			if ($4->category == "Array") {
				int size_array = 0;
				for (auto child : $4->children){
					if (child->category == "Array_Size"){
						size_array = child->ivalue;
						if (size_array < 0){
							FLAG_ERROR = SIZE_ARRAY_INVALID;
							yyerror(to_string(size_array).c_str());
							size_array = 0;
						}
						break;
					}
				}
				if (size_array > 0) {
					Attributes* array_attr = new Attributes();
					array_attr->symbol_name = $2;
					array_attr->category = ARRAY;
					array_attr->scope = symbolTable.current_scope;
					array_attr->type = type_attr;
					array_attr->value = size_array;
					
					// Crear atributos del array
					string elem_name = "";
					for (int i = 0; i < size_array; i++) {
						elem_name = string($2) + "[" + to_string(i) + "]";

						if (symbolTable.search_symbol(elem_name)) {
							FLAG_ERROR = ALREADY_DEF_VAR;
							yyerror(elem_name.c_str());
						} else {
							Attributes *elem = new Attributes();
							elem->symbol_name = elem_name;
							elem->scope = symbolTable.current_scope;
							elem->category = ARRAY_ELEMENT;
							elem->type = type_attr;
							elem->value = nullptr;

							// Usar el índice como clave en formato string
							array_attr->info.push_back({elem_name, elem});
				
							// \Insertar elemento en tabla de símbolos
							symbolTable.insert_symbol(elem_name, *elem);
						}
					}
					// Insertar en tabla de símbolos
					if (!symbolTable.insert_symbol($2, *array_attr)){
						FLAG_ERROR = ALREADY_DEF_VAR;
						yyerror($2);
					}
				}
			// Declaracion de tipos basicos
			} else {
				Attributes* attribute = new Attributes();
				attribute->symbol_name = $2;
				attribute->scope = symbolTable.current_scope;
				attribute->type = type_attr;
				attribute->value = nullptr; // Inicializar valor como nulo

				if ($1->kind == "POINTER_V") attribute->category = POINTER_V;
				else if ($1->kind == "POINTER_C") attribute->category = POINTER_C;
				else if ($1->kind == "VARIABLE") attribute->category = VARIABLE;
				else if ($1->kind == "CONSTANTE") attribute->category = CONSTANT;

				if ($4->category == "Identificador") { // Estructuras
					for (const auto& field : type_attr->info) {
						string full_field = get<string>(field.first);
						size_t dot_pos = full_field.find('.');
						if (dot_pos == string::npos) continue; // No es un campo válido

						string attr_name = full_field.substr(dot_pos + 1);
						string new_field_name = string($2) + "." + attr_name;
						if (symbolTable.search_symbol(new_field_name)) {
							FLAG_ERROR = ALREADY_DEF_VAR;
							yyerror(new_field_name.c_str());
						} else {
							Attributes* new_attr = new Attributes();
							new_attr->symbol_name = new_field_name;
							new_attr->scope = symbolTable.current_scope;
							new_attr->type = field.second->type;
							new_attr->category = STRUCT_ATTRIBUTE;
							new_attr->value = nullptr;

							// Agregar a la info de la variable y a la tabla de símbolos
							attribute->info.push_back({new_field_name, new_attr});
							symbolTable.insert_symbol(new_field_name, *new_attr);
						}
					}
				}

				// Insertar en tabla de símbolos
				if (!symbolTable.insert_symbol($2, *attribute)) {
					FLAG_ERROR = ALREADY_DEF_VAR;
					yyerror($2);
				}
			}
		}
		
		// Actualizamos AST
		$$ = makeASTNode($2, "Declaración", declared_type, $1->kind);
		$$->show_value = false;
		if ($4->category == "Array"){
			$$->children = $4->children;
		}

		if ($1->kind == "VARIABLE"){
			int scope_level = symbolTable.search_symbol($2)->scope;
			int size_to_reserve = 0;
			// Agregar variable a .declaration
			if ($4->category == "Identificador"){ //Estructuras y variantes
				Attributes* attr = symbolTable.search_symbol($4->name);
				if (attr->category == STRUCT) size_to_reserve = sumOfSizeTypes(attr->info);
				if (attr->category == UNION) size_to_reserve = maxOfSizeType(attr->info);
			} else if($4->category == "Array"){ // arrays
				/* por implementar */
			}else{ // tipos definidos
				size_to_reserve = strToSizeType(declared_type);
			}
			$$->tac_declaraciones.push_back({scope_level, {string($2), size_to_reserve}});
		}
	}
	| tipo_declaracion T_ID T_DOSPUNTOS tipos T_ASIGNACION expresion {
		string left_type = $4->type;
		string right_type = $6->type;
		
		Attributes* type_attr = symbolTable.search_symbol(left_type);
		if (type_attr == nullptr){
			FLAG_ERROR = INTERNAL;
			yyerror("ERROR: Tipo no encontrado");
		} else {
			// Declaracion de Arreglo con asignacion
			if ($4->category == "Array") {
				int size_array = 0;
				for (auto child : $4->children){
					if (child->category == "Array_Size"){
						size_array = child->ivalue;
						if (size_array < 0){
							FLAG_ERROR = SIZE_ARRAY_INVALID;
							yyerror(to_string(size_array).c_str());
							size_array = 0;
						}
						break;
					}
				}
				if (size_array > 0) {
					// Crear atributos del array
					Attributes* attribute = new Attributes();
					attribute->symbol_name = $2;
					attribute->category = ARRAY;
					attribute->scope = symbolTable.current_scope;
					attribute->type = type_attr;
					attribute->value = size_array;

					int count_elems = 0;
					set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Atributo_Estructura"};
					vector<ASTNode*> array_elements;
					collect_nodes_by_categories($6, categories, array_elements);
					for (auto elem : array_elements) {
						count_elems++;
						if (count_elems > size_array) {
							FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
							string error_msg = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(size_array) + "' cositas.";
							yyerror(error_msg.c_str());
							break;
						}

						Attributes *attr_elem = new Attributes();
						attr_elem->symbol_name = string($2) + "[" + to_string(count_elems-1) + "]";
						attr_elem->scope = symbolTable.current_scope;
						attr_elem->category = ARRAY_ELEMENT;
						attr_elem->type = type_attr;

						if (left_type != elem->type && (left_type != "manguangua" || elem->type != "manguita")) {
							FLAG_ERROR = TYPE_ERROR;
							string error_msg = "\"" + string($2) + "\" de tipo '" + left_type + 
								"' y le quieres meter un tipo '" + elem->type + "', marbaa' bruja.";
							yyerror(error_msg.c_str());
							attr_elem->value = nullptr;
						} else {
							if (elem->type == "mango") {
								attr_elem->value = elem->ivalue;
							} else if (elem->type == "manguita") {
								attr_elem->value = elem->fvalue;
							} else if (elem->type == "manguangua") {
								attr_elem->value = elem->dvalue;
							} else if (elem->type == "negro") {
								attr_elem->value = elem->cvalue;
							} else if (elem->type == "higuerote") {
								attr_elem->value = elem->svalue;
							} else if (elem->type == "tas_claro") {
								attr_elem->value = elem->bvalue;
								if (!attr_elem->info.empty()) attr_elem->info[0].first = (elem->bvalue ? "Sisa" : "Nolsa");
								else attr_elem->info.push_back({(elem->bvalue ? "Sisa" : "Nolsa"), nullptr});
							} else if (elem->type == "pointer"){
								/* POR IMPLEMENTAR */
								//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
								attr_elem->value = nullptr;
							} else {
								FLAG_ERROR = INTERNAL;
								string error_msg = "TIPO DESCONOCIDO: Asignando 'nullptr' a: '" + string($2) + "'.";
								yyerror(error_msg.c_str());
								attr_elem->value = nullptr;
							}
						}
						
						// Usar el índice como clave en formato string
						attribute->info.push_back({string($2) + "[" + to_string(count_elems-1) + "]", attr_elem});
			
						// Insertar elemento en tabla de símbolos
						if(!symbolTable.insert_symbol(attr_elem->symbol_name, *attr_elem)){
							FLAG_ERROR = ALREADY_DEF_VAR;
							yyerror(attr_elem->symbol_name.c_str());
						}
					}

					// Verificar cantidad de elementos
					if (count_elems < size_array) {
						FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
						string error_msg = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(count_elems) + "' de '" + to_string(size_array) + "'.";
						yyerror(error_msg.c_str());
					} else if (count_elems == size_array) {
						if (!symbolTable.insert_symbol($2, *attribute)){
							FLAG_ERROR = ALREADY_DEF_VAR;
							yyerror($2);
						}
					}
				}

			// Declaracion de tipos basicos con asignacion
			} else {
				Attributes *attribute = new Attributes();
				attribute->symbol_name = $2;
				attribute->scope = symbolTable.current_scope;
				attribute->type = type_attr;

				right_type = $6->type;

				// Verificacion de tipos.
				if (left_type != right_type && (left_type != "manguangua" || right_type != "manguita")) {
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "\"" + string($2) + "\" de tipo '" + left_type + "' y le quieres meter un tipo '" + right_type + "', marbaa' bruja.";
					yyerror(error_msg.c_str());
					attribute->value = nullptr; // Asignar valor nulo en caso de error
				} else {
					
					if ($1->kind == "POINTER_V") attribute->category = POINTER_V;
					else if ($1->kind == "POINTER_C") attribute->category = POINTER_C;
					else if ($1->kind == "VARIABLE") attribute->category = VARIABLE;
					else if ($1->kind == "CONSTANTE") attribute->category = CONSTANT;

					if (right_type == "mango") {
						attribute->value = $6->ivalue;
					} else if (right_type == "manguita") {
						attribute->value = $6->fvalue;
					} else if (right_type == "manguangua") {
						attribute->value = $6->dvalue;
					} else if (right_type == "negro"){
						attribute->value = $6->cvalue;
					} else if (right_type == "higuerote") {
						attribute->value = $6->svalue;
					} else if (right_type == "tas_claro"){
						attribute->value = $6->bvalue;
						if (!attribute->info.empty()) attribute->info[0].first = ($6->bvalue ? "Sisa" : "Nolsa");
						else attribute->info.push_back({($6->bvalue ? "Sisa" : "Nolsa"), nullptr});
					} else if (right_type == "pointer"){
						/* POR IMPLEMENTAR */
						//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
						attribute->value = nullptr;
					} else {
						FLAG_ERROR = INTERNAL;
						string error_msg = "TIPO DESCONOCIDO: Asignando 'nullptr' a: '" + string($2) + "'.";
						yyerror(error_msg.c_str());
						attribute->value = nullptr;
					}

					if (!symbolTable.insert_symbol($2, *attribute)){
						FLAG_ERROR = ALREADY_DEF_VAR;
						yyerror($2);
					}
				}
			}
		}
		
		// Actualizamos AST
		$$ = makeASTNode("Asignación", "", "", "=");
		auto declarationNode = makeASTNode($2, "Declaración", left_type, $1->kind);
		declarationNode->show_value = false;
		if ($4->category == "Array") declarationNode->children = $4->children;
		$$->children.push_back(declarationNode);
		$$->children.push_back($6);

		// Agregar instrucciones de la asignacion
		concat_TAC($$, $6);
		// Agregar TAC asociado a asignacion
		if($1->kind != "CONSTANTE") $$->tac.push_back(string($2) + " := " + $6->temp);
		
		// Agregar TAC de declaraciones
		if ($1->kind == "VARIABLE"){
			// Agregar variable a .declaration
			int scope_level = symbolTable.search_symbol($2)->scope;
			$$->tac_declaraciones.push_back({scope_level, {string($2), strToSizeType(left_type)}});
		} else if ($1->kind == "CONSTANTE"){
			// Agregar constante a .data
			$$->tac_data.emplace_back(string($2), valuesToString($6));
		}
	}
	| funcion cerrar_scope { $$ = $1; }
	| estructura cerrar_scope { $$ = $1; }
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
		$$ = makeASTNode("Array", "Array", $1->type);
		if ($3->type != "mango") {
			FLAG_ERROR = SIZE_ARRAY_INVALID;
			yyerror($3->type.c_str());
		} else {
			ASTNode* size_node = makeASTNode($3->name, "Array_Size", "mango");
			size_node->ivalue = $3->ivalue; // Asignar el valor del tamaño del array
			$$->children.push_back(size_node);
		}
	}
	| T_ID {
		$$ = makeASTNode($1, "Identificador");
		Attributes* attr = symbolTable.search_symbol($1);
		$$->type = $1;
		if (attr == nullptr) {
			FLAG_ERROR = NON_DEF_TYPE;
			yyerror($1);
			$$->type = "Desconocido"; // Asignar un valor por defecto para evitar errores posteriores
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
		ASTNode* new_node = makeASTNode($1, "Identificador");

		string id = string($1);
		string left_type = "Desconocido_l";
		string right_type = $3->type;

		Attributes* attribute = symbolTable.search_symbol($1);
		if (attribute == nullptr){
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else {
			if (attribute->category == VAR_FOR) {
				FLAG_ERROR = MODIFY_VAR_FOR;
				yyerror($1);
			}
			if (attribute->category == ERROR_HANDLER){
				FLAG_ERROR = TRY_ERROR;
				yyerror($1);
			}
			
			if (attribute->category == CONSTANT || attribute->category == POINTER_C) {
				FLAG_ERROR = MODIFY_CONST;
				yyerror($1);
			}
			
			if (!attribute->type) {
				FLAG_ERROR = INTERNAL;
				string error_msg = "ERROR INTERNO: El tipo de \"" + id + "\" no esta definido.";
				yyerror(error_msg.c_str());
			} else {
				left_type = attribute->type->symbol_name;
				new_node->type = left_type;
				$2->type = left_type; // Asignar el tipo al nodo del operador de asignación

				if (left_type != right_type && (left_type != "manguangua" || right_type != "manguita")) {
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "\"" + id + "\" de tipo '" + left_type + 
						"' y le quieres meter un tipo '" + right_type + "', marbaa' bruja.";
					yyerror(error_msg.c_str());
				} else {
					string op = $2->kind;
					if (op != "=" && holds_alternative<nullptr_t>(attribute->value) && attribute->category != PARAMETERS) {
						FLAG_ERROR = NON_VALUE;
						yyerror($1);
					} else {
						new_node->show_value = !holds_alternative<nullptr_t>(attribute->value);
						if (left_type == "mango") {
							int r_ivalue = $3->ivalue;
							if (op == "=") attribute->value = r_ivalue;
							else {
								int l_ivalue = get<int>(attribute->value);
								new_node->ivalue = l_ivalue; // Guardar el valor antes de modificarlo
								if (op == "+=") attribute->value = l_ivalue + r_ivalue;
								if (op == "-=") attribute->value = l_ivalue - r_ivalue;
								if (op == "*=") attribute->value = l_ivalue * r_ivalue;
							}
							$2->ivalue = get<int>(attribute->value);
						} else if (left_type == "manguita") {
							float r_fvalue = $3->fvalue;
							if (op == "=") attribute->value = r_fvalue;
							else {
								float l_fvalue = get<float>(attribute->value);
								new_node->fvalue = l_fvalue; // Guardar el valor antes de modificarlo
								if (op == "+=") attribute->value = l_fvalue + r_fvalue;
								if (op == "-=") attribute->value = l_fvalue - r_fvalue;
								if (op == "*=") attribute->value = l_fvalue * r_fvalue;
							}
							$2->fvalue = get<float>(attribute->value);
						} else if (left_type == "manguangua") {
							double r_dvalue = 0.0;
							if (right_type == "manguita") r_dvalue = $3->fvalue;
							else r_dvalue = $3->dvalue;

							if (op == "=") attribute->value = $3->dvalue;
							else {
								double l_dvalue = get<double>(attribute->value);
								new_node->dvalue = l_dvalue; // Guardar el valor antes de modificarlo
								if (op == "+=") attribute->value = l_dvalue + r_dvalue;
								if (op == "-=") attribute->value = l_dvalue - r_dvalue;
								if (op == "*=") attribute->value = l_dvalue * r_dvalue;
							}
							$2->dvalue = get<double>(attribute->value);
						} else if (left_type == "negro" && op == "=") {
							attribute->value = $3->cvalue;
							$2->cvalue = $3->cvalue;
						} else if (left_type == "higuerote" && op == "=") {
							attribute->value = $3->svalue;
							$2->svalue = $3->svalue;
						} else if (left_type == "tas_claro" && op == "="){
							attribute->value = $3->bvalue;
							$2->bvalue = $3->bvalue;
							if (!attribute->info.empty()) attribute->info[0].first = ($3->bvalue ? "Sisa" : "Nolsa");
							else attribute->info.push_back({($3->bvalue ? "Sisa" : "Nolsa"), nullptr});
						} else if (left_type == "pointer"){
							/* POR IMPLEMENTAR */
							//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
							attribute->value = nullptr;
						} else {
							FLAG_ERROR = INTERNAL;
							string error_msg = "TIPO DESCONOCIDO: '" + left_type + "'.";
							yyerror(error_msg.c_str());
							attribute->value = nullptr;
						}
					}
				}
			}
		}

		$$ = $2;
		// Determinar el tipo de operacion
		string op_tac = "";
		if ($2->kind == "+=") op_tac = " + ";
		else if ($2->kind == "-=") op_tac = " - ";
		else if ($2->kind == "*=") op_tac = " * ";
		else if ($2->kind == "=") op_tac = " := ";
		// Agregar instrucciones de la expresion
		concat_TAC($$, $3);
		// Generar el TAC para asignacion
		if (op_tac != " := ") {
			$$->tac.push_back(string($1) + " := " + string($1) + op_tac + $3->temp);
		} else {
			$$->tac.push_back(string($1) + " := " + $3->temp);
		}

		$$->children.push_back(new_node);
		$$->children.push_back($3);
	}    
	| T_ID T_IZQCORCHE expresion T_DERCORCHE operadores_asignacion expresion {
		ASTNode* new_node = makeASTNode($1, "Elemento_Array");
		
		string left_type = "Desconocido_l";
		string index_type = $3->type;
		int index = 0;
		string right_type = $6->type;

		Attributes* array_attr = symbolTable.search_symbol($1);
		if (array_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else if (array_attr->category != ARRAY) {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "\"" + string($1) + "\" no es un array, marbaa' bruja.";
			yyerror(error_msg.c_str());
		} else {
			if (index_type != "mango") {
				FLAG_ERROR = INT_INDEX_ARRAY;
				yyerror(index_type.c_str());
			} else {
				index = $3->ivalue;
			}

			if (array_attr->info.empty()) {
				FLAG_ERROR = INTERNAL;
				yyerror("ERROR: El array no tiene elementos.");
			} else {
				int size_array = 0;
				if (holds_alternative<nullptr_t>(array_attr->value)) {
					FLAG_ERROR = INTERNAL;
					string error_msg = "ERROR: '" + string($1) + "' no tiene un tamaño definido.";
					yyerror(error_msg.c_str());
				} else {
					size_array = get<int>(array_attr->value);
					Attributes* elem_attr = nullptr;
					if (index < 0 || index >= size_array) {
						FLAG_ERROR = SEGMENTATION_FAULT;
						yyerror(to_string(index).c_str());
						elem_attr = symbolTable.search_symbol(get<string>(array_attr->info[0].first));
					} else {
						elem_attr = symbolTable.search_symbol(get<string>(array_attr->info[index].first));
					}

					left_type = array_attr->type->symbol_name;
					new_node->name = elem_attr->symbol_name;
					new_node->type = left_type;

					if (left_type != right_type && (left_type != "manguangua" || right_type != "manguita")) {
						FLAG_ERROR = TYPE_ERROR;
						string error_msg = "\"" + string($1) + "\" de tipo '" + left_type + 
							"' y le quieres meter un tipo '" + right_type + "', marbaa' bruja.";
						yyerror(error_msg.c_str());
					} else {
						string op = $5->kind;
						if (op != "=" && holds_alternative<nullptr_t>(elem_attr->value)) {
							FLAG_ERROR = NON_VALUE;
							yyerror($1);
						} else {
							new_node->show_value = !holds_alternative<nullptr_t>(elem_attr->value);
							if (left_type == "mango") {
								int r_ivalue = $6->ivalue;
								if (op == "=") elem_attr->value = r_ivalue;
								else {
									int l_ivalue = get<int>(elem_attr->value);
									new_node->ivalue = l_ivalue; // Guardar el valor antes de modificarlo
									if (op == "+=") elem_attr->value = l_ivalue + r_ivalue;
									if (op == "-=") elem_attr->value = l_ivalue - r_ivalue;
									if (op == "*=") elem_attr->value = l_ivalue * r_ivalue;
								}
								$5->ivalue = get<int>(elem_attr->value);
							} else if (left_type == "manguita") {
								float r_fvalue = $6->fvalue;
								if (op == "=") elem_attr->value = r_fvalue;
								else {
									float l_fvalue = get<float>(elem_attr->value);
									new_node->fvalue = l_fvalue; // Guardar el valor antes de modificarlo
									if (op == "+=") elem_attr->value = l_fvalue + r_fvalue;
									if (op == "-=") elem_attr->value = l_fvalue - r_fvalue;
									if (op == "*=") elem_attr->value = l_fvalue * r_fvalue;
								}
								$5->fvalue = get<float>(elem_attr->value);
							} else if (left_type == "manguangua") {
								double r_dvalue = 0.0;
								if (right_type == "manguita") r_dvalue = $6->fvalue;
								else r_dvalue = $6->dvalue;

								if (op == "=") elem_attr->value = r_dvalue;
								else {
									double l_dvalue = get<double>(elem_attr->value);
									new_node->dvalue = l_dvalue; // Guardar el valor antes de modificarlo
									if (op == "+=") elem_attr->value = l_dvalue + r_dvalue;
									if (op == "-=") elem_attr->value = l_dvalue - r_dvalue;
									if (op == "*=") elem_attr->value = l_dvalue * r_dvalue;
								}
								$5->dvalue = get<double>(elem_attr->value);
							} else if (left_type == "negro" && op == "=") {
								elem_attr->value = $6->cvalue;
								$5->cvalue = $6->cvalue;
							} else if (left_type == "higuerote" && op == "=") {
								elem_attr->value = $6->svalue;
								$5->svalue = $6->svalue;
							} else if (left_type == "tas_claro" && op == "=") {
								elem_attr->value = $6->bvalue;
								$5->bvalue = $6->bvalue;
								if (!elem_attr->info.empty()) elem_attr->info[0].first = ($6->bvalue ? "Sisa" : "Nolsa");
								else elem_attr->info.push_back({($6->bvalue ? "Sisa" : "Nolsa"), nullptr});
							} else if (left_type == "pointer"){
								/* POR IMPLEMENTAR */
								//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
								elem_attr->value = nullptr;
							} else {
								FLAG_ERROR = INTERNAL;
								string error_msg = "TIPO DESCONOCIDO: '" + left_type + "'.";
								yyerror(error_msg.c_str());
								elem_attr->value = nullptr;
							}
						}
					}
				}
			}
		}

		$$ = $5;
		$$->children.push_back(new_node);
		$$->children.push_back($6);
	}
	| T_ID T_PUNTO T_ID operadores_asignacion expresion { // Structs/Unions
		ASTNode* new_node = makeASTNode($1, "Atributo_Estructura");
		
		Attributes* struct_attr = symbolTable.search_symbol($1);
		string type_struct = "Desconocido_s";
		string type_field = "Desconocido_f";
		string right_type = $5->type;
		Category category_struct = UNKNOWN;

		if (struct_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else if (struct_attr->type->category != STRUCT && struct_attr->type->category != UNION) {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "\"" + string($1) + "\" que ni es un 'arroz_con_mango' ni un 'coliao', marbaa' bruja.";
			yyerror(error_msg.c_str());
		} else {
			type_struct = struct_attr->type->symbol_name;
			category_struct = struct_attr->type->category;

			string field_name = string($1) + "." + string($3);
			Attributes* field_attr = symbolTable.search_symbol(field_name);

			if (field_attr == nullptr) {
				FLAG_ERROR = NON_DEF_ATTR;
				yyerror($3);
			} else {
				new_node->name = field_name;
				type_field = field_attr->type->symbol_name;
				if (type_field != right_type && (type_field != "manguangua" || right_type != "manguita")) {
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "\"" + string($1) + "\" de tipo '" + type_field + 
						"' y le quieres meter un tipo '" + right_type + "', marbaa' bruja.";
					yyerror(error_msg.c_str());
				} else {
					// Vaciar los demas campos en caso de un UNION
					if (category_struct == UNION) {
						string other_field_name = "";
						for (const auto& info : struct_attr->info) {
							other_field_name = get<string>(info.first);
							if (other_field_name != field_name) {
								Attributes* other_field = symbolTable.search_symbol(other_field_name);
								if (other_field != nullptr) other_field->value = nullptr; // Limpiar valor de otros campos
							}
						}
					}

					string op = $4->kind;
					if (op != "=" && holds_alternative<nullptr_t>(field_attr->value)) {
						FLAG_ERROR = NON_VALUE;
						yyerror(field_name.c_str());
					} else {
						new_node->show_value = !holds_alternative<nullptr_t>(field_attr->value);
						if (type_field == "mango") {
							int r_ivalue = $5->ivalue;
							if (op == "=") field_attr->value = r_ivalue;
							else {
								int l_ivalue = get<int>(field_attr->value);
								new_node->ivalue = l_ivalue; // Guardar el valor antes de modificarlo
								if (op == "+=") field_attr->value = l_ivalue + r_ivalue;
								if (op == "-=") field_attr->value = l_ivalue - r_ivalue;
								if (op == "*=") field_attr->value = l_ivalue * r_ivalue;
							}
							$4->ivalue = get<int>(field_attr->value);
						} else if (type_field == "manguita") {
							float r_fvalue = $5->fvalue;
							if (op == "=") field_attr->value = r_fvalue;
							else {
								float l_fvalue = get<float>(field_attr->value);
								new_node->fvalue = l_fvalue; // Guardar el valor antes de modificarlo
								if (op == "+=") field_attr->value = l_fvalue + r_fvalue;
								if (op == "-=") field_attr->value = l_fvalue - r_fvalue;
								if (op == "*=") field_attr->value = l_fvalue * r_fvalue;
							}
							$4->fvalue = get<float>(field_attr->value);
						} else if (type_field == "manguangua") {
							double r_dvalue = 0.0;
							if (right_type == "manguita") r_dvalue = $5->fvalue;
							else r_dvalue = $5->dvalue;
	
							if (op == "=") field_attr->value = r_dvalue;
							else {
								double l_dvalue = get<double>(field_attr->value);
								new_node->dvalue = l_dvalue; // Guardar el valor antes de modificarlo
								if (op == "+=") field_attr->value = l_dvalue + r_dvalue;
								if (op == "-=") field_attr->value = l_dvalue - r_dvalue;
								if (op == "*=") field_attr->value = l_dvalue * r_dvalue;
							}
							$4->dvalue = get<double>(field_attr->value);
						} else if (type_field == "negro" && op == "=") {
							field_attr->value = $5->cvalue;
							$4->cvalue = $5->cvalue;
						} else if (type_field == "higuerote" && op == "=") {
							field_attr->value = $5->svalue;
							$4->svalue = $5->svalue;
						} else if (type_field == "tas_claro" && op == "="){
							field_attr->value = $5->bvalue;
							$4->bvalue = $5->bvalue;
							if (!field_attr->info.empty()) field_attr->info[0].first = ($5->bvalue ? "Sisa" : "Nolsa");
							else field_attr->info.push_back({($5->bvalue ? "Sisa" : "Nolsa"), nullptr});
						} else if (type_field == "pointer"){
							/* POR IMPLEMENTAR */
							//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
							field_attr->value = nullptr;
						} else {
							FLAG_ERROR = INTERNAL;
							string error_msg = "TIPO DESCONOCIDO: '" + type_field + "'.";
							yyerror(error_msg.c_str());
							field_attr->value = nullptr;
						}
					}
				}
			}
		}
		$$ = $4;

		// Agregar instrucciones TAC para la asignación de atributos
		string op_tac = "";
		if ($4->kind == "+=") op_tac = " + ";
		else if ($4->kind == "-=") op_tac = " - ";
		else if ($4->kind == "*=") op_tac = " * ";
		else if ($4->kind == "=") op_tac = " := ";
		// Agregar instrucciones de la expresion
		concat_TAC($$, $5);
		// Generar el TAC para asignacion
		string temp_base = labelGen.newTemp(),
			   temp_attr = labelGen.newTemp(string($1) + "_" + string($3)),
			   attr = string($1) + "." + string($3);
		$$->tac.push_back(temp_base + " := " + "&" + string($1));
		
		$$->tac.push_back(temp_attr + " := " + temp_base + " + " + to_string(accumulateSizeType(struct_attr->info, attr)));
		
		if(op_tac == " := "){
			$$->tac.push_back("*" + temp_attr + op_tac + $5->temp);
		}else{
			string temp_addr = labelGen.newTemp(),
				   temp = labelGen.newTemp();
			$$->tac.push_back(temp_addr + " := *"+ temp_attr);
			$$->tac.push_back(temp + " := " + temp_addr + op_tac + $5->temp);
			$$->tac.push_back("*" + temp_attr + " := " + temp);
		}

		$$->children.push_back(new_node);
		$$->children.push_back($5);
	}
	;

operadores_asignacion:
	T_ASIGNACION    { $$ = makeASTNode("Asignación", "", "", "="); }
	| T_OPASIGSUMA  { $$ = makeASTNode("Suma Compuesta", "Operación", "", "+="); }
	| T_OPASIGRESTA { $$ = makeASTNode("Resta Compuesta", "Operación", "", "-="); }
	| T_OPASIGMULT  { $$ = makeASTNode("Multiplicación Compuesta", "Operación", "", "*="); }
	;

expresion:
	T_ID {
		ASTNode* new_node = makeASTNode($1, "Identificador");
		
		Attributes* attr = symbolTable.search_symbol($1);
		if (attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else {
			string type, kind = "";
			if (!holds_alternative<nullptr_t>(attr->value)) {
				type = attr->type->symbol_name;
				new_node->type = type;
				if (type == "mango") {
					new_node->ivalue = get<int>(attr->value);
				} else if (type == "manguita") {
					new_node->fvalue = get<float>(attr->value);
				} else if (type == "manguangua") {
					new_node->dvalue = get<double>(attr->value);
				} else if (type == "negro") {
					new_node->cvalue = get<char>(attr->value);
				} else if (type == "higuerote") {
					new_node->svalue = get<string>(attr->value);
				} else if (type == "tas_claro") {
					new_node->bvalue = get<bool>(attr->value);
					new_node->kind = new_node->bvalue ? "Sisa" : "Nolsa";
				} else if (type == "pointer") {
					// POR IMPLEMENTAR
				} else {
					FLAG_ERROR = INTERNAL;
					yyerror("ERROR INTERNO: Lexer proporciona un tipo invalido.");
				}
			}
		}
		$$ = new_node;
		$$->tac = {};
		$$->temp = string($1); // Agregar TAC para el identificador
	}
	| T_VALUE {
		string type = typeToString($1.type);
		ASTNode* new_node = makeASTNode("Literal", "Numérico", type);
		
		if (type == "mango") {
			new_node->ivalue = $1.ival;
			new_node->temp = to_string($1.ival);
		} else if (type == "manguita") {
			new_node->fvalue = $1.fval;
			new_node->temp = to_string($1.fval);
		} else if (type == "manguangua") {
			new_node->dvalue = $1.dval;
			new_node->temp = to_string($1.dval);
		} else if (type == "negro") {
			new_node->cvalue = $1.cval;
			new_node->category = "Caracter";
			new_node->temp = string(1, $1.cval);
		} else if (type == "higuerote") {
			new_node->svalue = $1.sval;
			new_node->category = "Cadena de Caracteres";
			// Crear variable temporal para la cadena que se guardara en .data
			string temp_name = labelGen.newTempStr();
			new_node->tac_data.emplace_back(temp_name, "\"" + string($1.sval) + "\"");
			new_node->temp = "&" + temp_name;
		} else {
			FLAG_ERROR = INTERNAL;
			string error_msg = "ERROR INTERNO: Lexer proporciona un tipo invalido: '" + type + "'.";
			yyerror(error_msg.c_str());
		}

		$$ = new_node;
		$$->tac = {};
	}
	| T_SISA { $$ = makeASTNode("Literal", "Bool", "tas_claro", "Sisa"); $$->bvalue = true; }
	| T_NOLSA { $$ = makeASTNode("Literal", "Bool", "tas_claro", "Nolsa"); $$->bvalue = false; }
	| T_PELABOLA { $$ = nullptr; }
	| expresion_apuntador 
	| expresion_nuevo
	| T_IZQCORCHE secuencia T_DERCORCHE { $$ = $2; } // Arreglos
	| T_ID T_IZQCORCHE expresion T_DERCORCHE { // Acceso a elementos de un array
		ASTNode* new_node = makeASTNode($1, "Elemento_Array");
		string left_type = "Desconocido_l";
		string index_type = $3->type;
		int size_array, index = 0;

		Attributes* array_attr = symbolTable.search_symbol($1);
		if (array_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else if (array_attr->category != ARRAY) {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "\"" + string($1) + "\" no es un array, marbaa' bruja.";
			yyerror(error_msg.c_str());
		} else {
			if (array_attr->info.empty()) {
				FLAG_ERROR = INTERNAL;
				yyerror("ERROR INTERNO: El array no tiene elementos.");
			} else {
				if (holds_alternative<nullptr_t>(array_attr->value)) {
					FLAG_ERROR = NON_VALUE;
					yyerror($1);
				} else {
					size_array = get<int>(array_attr->value);
					left_type = array_attr->type->symbol_name;
					
					if (index_type != "mango") {
						FLAG_ERROR = INT_INDEX_ARRAY;
						yyerror(index_type.c_str());
					} else {
						index = $3->ivalue;
					}

					Attributes* elem_attr = nullptr;
					if (index < 0 || index >= size_array) {
						FLAG_ERROR = SEGMENTATION_FAULT;
						yyerror(to_string(index).c_str());
					}
					elem_attr = symbolTable.search_symbol(get<string>(array_attr->info[index].first));

					string type_elem = "Desconocido";
					if (elem_attr == nullptr) {
						FLAG_ERROR = NON_DEF_VAR;
						yyerror($1);
					} else if (elem_attr->type->symbol_name != left_type) {
						FLAG_ERROR = INTERNAL;
						string error_msg = "ERROR: Tipos incompatibles: Array->'" + left_type + "' | Elem->'" + elem_attr->type->symbol_name + "'.";
						yyerror(error_msg.c_str());
					} else {
						new_node->name = elem_attr->symbol_name;
						// Extraer el valor
						type_elem = elem_attr->type->symbol_name;
						if (type_elem == "mango") {
							new_node->ivalue = get<int>(elem_attr->value);
						} else if (type_elem == "manguita") {
							new_node->fvalue = get<float>(elem_attr->value);
						} else if (type_elem == "manguangua") {
							new_node->dvalue = get<double>(elem_attr->value);
						} else if (type_elem == "negro") {
							new_node->cvalue = get<char>(elem_attr->value);
						} else if (type_elem == "higuerote") {
							new_node->svalue = get<string>(elem_attr->value);
						} else if (type_elem == "tas_claro") {
							new_node->bvalue = get<bool>(elem_attr->value);
							if (!elem_attr->info.empty()) elem_attr->info[0].first = (new_node->bvalue ? "Sisa" : "Nolsa");
						} else if (type_elem == "pointer") {
							/* POR IMPLEMENTAR */
						} else {
							FLAG_ERROR = INTERNAL;
							yyerror("ERROR INTERNO: Lexer proporciona un tipo invalido.");
						}		
					}
				}
			}
		}
		new_node->type = left_type;
		$$ = new_node;
	} 
	| T_IZQPAREN expresion T_DERPAREN { $$ = $2; } // Expresion parentizada.
		| T_NELSON expresion { 
		string type = $2->type;
		$$ = makeASTNode("nelson", "Operación", "Desconocido", "Booleana");
		if (type != "tas_claro") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "'" + $2->name + "' de tipo '" + type + "' y le quiere meter un `nelson`, peaso e loca.";
			yyerror(error_msg.c_str());
		} else {
			$$->type = "tas_claro"; // Asegurar que el tipo es booleano
			$$->bvalue = !$2->bvalue; // Negar el valor booleano
			$$->children.push_back($2);
		}
	}
	| T_OPRESTA expresion %prec T_OPRESTA {
		string type = $2->type;
		if (type == "mango") $2->ivalue *= -1;
		else if (type == "manguita") $2->fvalue *= -1;
		else if (type == "manguangua") $2->dvalue *= -1;
		else {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "'" + $2->name + "' de tipo '" + type + "' y le quiere meter un negativo, peaso e loca.";
			yyerror(error_msg.c_str());
		}
		$$ = $2;
		$$->temp = valuesToString($2);
		$$->tac = {};
	}
	| expresion T_FLECHA expresion { $$ = solver_operation($1, "->", $3, yylineno, yylloc.first_column); }
	| expresion T_OPSUMA expresion {
		$$ = solver_operation($1, "+", $3, yylineno, yylloc.first_column); 
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " + " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPRESTA expresion {
		$$ = solver_operation($1, "-", $3, yylineno, yylloc.first_column); 
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " - " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPMULT expresion {
		$$ = solver_operation($1, "*", $3, yylineno, yylloc.first_column); 
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " * " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPDIVDECIMAL expresion {
		$$ = solver_operation($1, "/", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " / " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPDIVENTERA expresion {
		$$ = solver_operation($1, "//", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " // " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPMOD expresion {
		$$ = solver_operation($1, "%", $3, yylineno, yylloc.first_column); 
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " % " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPEXP expresion {
		$$ = solver_operation($1, "**", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " ** " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPIGUAL expresion {
		$$ = solver_operation($1, "igualito", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " == " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPDIFERENTE expresion {
		$$ = solver_operation($1, "nie", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " != " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPMAYOR expresion { 
		$$ = solver_operation($1, "mayol", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " > " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPMAYORIGUAL expresion {
		$$ = solver_operation($1, "lidel", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " >= " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPMENOR expresion {
		$$ = solver_operation($1, "menol", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " < " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_OPMENORIGUAL expresion {
		$$ = solver_operation($1, "peluche", $3, yylineno, yylloc.first_column);
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		$$->tac.push_back(temp + " := " + $1->temp + " <= " + $3->temp);
		$$->temp = temp;
	}
	| expresion T_YUNTA expresion { $$ = solver_operation($1, "yunta", $3, yylineno, yylloc.first_column); }
	| expresion T_OSEA expresion { $$ = solver_operation($1, "o_sea", $3, yylineno, yylloc.first_column); }
	| entrada_salida
	| llamada_funcion
	| casting
	;

operaciones_unitarias:
	T_OPDECREMENTO { $$ = makeASTNode("--", "Decremento"); }
	| T_OPINCREMENTO { $$ = makeASTNode("++", "Incremento"); }
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
	guardia_siesasi alternativa { 
		$$ = makeASTNode("Condición");
		$$->children.push_back($1);

		// Vector para guardar los bloques de instrucciones de las condiciones (si_es_asi, o_asi)
		vector<pair<ASTNode*, string> >backup_instrs;
		// Extraer guardia e instruccion de si_es_asi
		ASTNode* siesasi_guard = $1->children[0]->children[0];
		ASTNode* siesasi_instr = $1->children.size() > 1 ? $1->children[1] : nullptr;
		// Agregar instrucciones de la guardia si_es_asi
		concat_TAC($$, siesasi_guard);
		// label del si_es_asi
		string label1 = labelGen.newLabel();
		string siesasi = "if " + siesasi_guard->temp + " goto " + label1;
		// Agregar condicional
		$$->tac.push_back(siesasi);
		// Guardado de las instrucciones si_es_asi
		backup_instrs.emplace_back(siesasi_instr, label1);
		// Si hay una alternativa, se agrega al nodo de la guardia.
		if ($2) {
			for (ASTNode* node : $2->children)  {
				if (node->name == "o_asi"){
					// Extraer guardia e instruccion de o_asi
					ASTNode* oasi_guard = node->children[0]->children[0];
					ASTNode* oasi_instr = node->children.size() > 1 ? node->children[1] : nullptr;
					// Agregar instrucciones de la guardia o_asi
					concat_TAC($$, oasi_guard);
					// label del o_asi
					string label2 = labelGen.newLabel();
					string oasi = "if " + oasi_guard->temp + " goto " + label2;
					// Agregar condicional
					$$->tac.push_back(oasi);
					// Guardado de las instrucciones o_asi
					backup_instrs.emplace_back(oasi_instr, label2);
				}else{
					// Agregar instrucciones nojoda
					if (node->children.size() != 0) concat_TAC($$, node->children[0]);
				}
				$$->children.push_back(node); // Agregar cada alternativa como un nodo hijo.
			}
		}
		// Agregar instrucciones de los condicionales (si_es_asi, o_asi)
		string label3 = labelGen.newLabel();
		$$->tac.push_back("goto " + label3);
		for (size_t i = 0; i < backup_instrs.size(); ++i) {
			auto pares = backup_instrs[i];
			$$->tac.push_back(pares.second + ": ");
			concat_TAC($$, pares.first);
			if (i != backup_instrs.size() - 1) {
				$$->tac.push_back("goto " + label3);
			}
		}
		// Salida del bloque if
		$$->tac.push_back(label3 + ": ");
	}
	;

guardia_siesasi:
	T_SIESASI T_IZQPAREN expresion T_DERPAREN abrir_scope bloque_instrucciones cerrar_scope{
		if ($3->type != "tas_claro") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "Condición de tipo '" + $3->type + "', se esperaba 'tas_claro'.";
			yyerror(error_msg.c_str());
		} else {
			ASTNode* siesasi_node = makeASTNode("si_es_asi");
			
			ASTNode* guardia_node = makeASTNode("Guardia");
			guardia_node->children.push_back($3);
			
			siesasi_node->children.push_back(guardia_node); 
			if($6) siesasi_node->children.push_back($6); // Incluir instrucciones de si_es_asi

			$$ = siesasi_node;
		}
	}
	;

guardia:
	T_OASI T_IZQPAREN expresion T_DERPAREN {
		if ($3->type != "tas_claro") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "Condición de tipo '" + $3->type + "', se esperaba 'tas_claro'.";
			yyerror(error_msg.c_str());
			$$ = nullptr;
		} else {
			$$ = makeASTNode("o_asi");
			ASTNode* guardia_node = makeASTNode("Guardia");
			guardia_node->children.push_back($3); // Agregar la expresión de la guardia.
			$$->children.push_back(guardia_node);
		}
	}
	| T_NOJODA { $$ = makeASTNode("nojoda"); }
	;

guardia_con_bloque:
	guardia abrir_scope bloque_instrucciones cerrar_scope {
		$$ = $1;
		if ($3) $$->children.push_back($3);
	}
	;

alternativa:
	{ $$ = nullptr; }
	| guardia_con_bloque alternativa {
		$$ = makeASTNode("Alternativa", "Alternativa");
		bool error = false;
		if ($2) {
			if ($1->name == "nojoda" && $2->children[0]->name == "o_asi") {
				FLAG_ERROR = SEMANTIC;
				string error_msg = "No se puede usar 'o_asi' después de haber usado 'nojoda'.";
				yyerror(error_msg.c_str());
				error = true;
			}
		}
		if (!error) {
			vector<ASTNode*> guardias;
			if ($1) collect_guardias($1, guardias);
			if ($2) collect_guardias($2, guardias);
			for (ASTNode* g : guardias) {
				$$->children.push_back(g);
			}
		}
	}
	;

bucle:
	indeterminado { $$ = $1; }
	| determinado { $$ = $1; }
	;

indeterminado:
	T_ECHALEBOLAS T_IZQPAREN expresion T_DERPAREN abrir_scope bloque_instrucciones cerrar_scope {
		$$ = makeASTNode("Bucle", "Indeterminado");
		if ($3->type != "tas_claro") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "Condición de tipo '" + $3->type + "', se esperaba 'tas_claro'.";
			yyerror(error_msg.c_str());
			$$ = nullptr;
		} else {
			
			ASTNode* new_node = makeASTNode("echale_bolas_si");
			ASTNode* guardia_node = makeASTNode("Guardia");
			guardia_node->children.push_back($3); // Agregar la expresión de la guardia.
			new_node->children.push_back(guardia_node);
			if ($6) new_node->children.push_back($6); // Agregar el bloque de instrucciones.
			$$->children.push_back(new_node);

			// Generacion de TAC para bucle while
			// label de repeticion
			string label0 = labelGen.newLabel();
			$$->tac.push_back(label0 + ": ");
			// Agregar instrucciones de la guardia while
			concat_TAC($$, $3);
			// Agregar condicional de la guardia
			string label1 = labelGen.newLabel();
			string echalebola = "if " + $3->temp + " goto " + label1;
			$$->tac.push_back(echalebola);
			// Agregar el label de salida del bucle
			string label2 = labelGen.newLabel();
			$$->tac.push_back("goto " + label2);
			// Instrucciones del while
			$$->tac.push_back(label1 + ": ");
			concat_TAC($$, $6);
			$$->tac.push_back("goto " + label0);
			// Salida del bucle
			$$->tac.push_back(label2 + ": ");
		}
	}
	;

var_ciclo_determinado:
	T_ID T_ENTRE expresion T_HASTA expresion {
		ASTNode* new_node = makeASTNode($1, "Var_Ciclo", "mango");
		
		string type_entre = $3->type;
		string type_hasta = $5->type;

		if (type_entre != "mango" || type_hasta != "mango") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "Se esperaban tipo 'mango' en las expresiones de 'entre' y 'hasta'.";
			yyerror(error_msg.c_str());
		} else {
			Attributes* attribute = new Attributes();
			attribute->symbol_name = $1;
			attribute->scope = symbolTable.current_scope;
			attribute->info.push_back({$3->ivalue, nullptr});
			attribute->info.push_back({$5->ivalue, nullptr});
			attribute->type = symbolTable.search_symbol("mango");
			attribute->category = VAR_FOR;
			attribute->value = $3->ivalue;

			new_node->ivalue = $3->ivalue;

			if (!symbolTable.insert_symbol($1, *attribute)){
				FLAG_ERROR = ALREADY_DEF_VAR;
				yyerror($1);
			};
		}
		
		ASTNode* node_entre = makeASTNode("entre", "Rango");
		node_entre->children.push_back($3);
		new_node->children.push_back(node_entre);

		ASTNode* node_hasta = makeASTNode("hasta", "Rango");
		node_hasta->children.push_back($5);
		new_node->children.push_back(node_hasta);

		$$ = new_node;
	}
	;

determinado:
	T_REPITEBURDA abrir_scope var_ciclo_determinado bloque_instrucciones cerrar_scope {
		ASTNode* new_node = makeASTNode("Bucle", "Determinado");
		
		/* IMPLEMENTAR CONDICIONAL PARA RANGOS */

		new_node->children.push_back($3);
		new_node->children.push_back($4);

		$$ = new_node;

		// TAC para for
		string var = $3->name, 
			   init = $3->children[0]->children[0]->temp,
			   finish = $3->children[1]->children[0]->temp;

		concat_TAC($$, $3->children[0]->children[0]);
		$$->tac.push_back(var + " := " + init);
		concat_TAC($$, $3->children[1]->children[0]);
		
		string label0 = labelGen.newLabel(),
			   label1 = labelGen.newLabel(),
			   label2 = labelGen.newLabel();
		
		$$->tac.push_back(label0 + ": ");
		$$->tac.push_back("if " + var + " < " + finish + " goto " + label1);
		$$->tac.push_back("goto " + label2);
		$$->tac.push_back(label1 + ": ");
		concat_TAC($$, $4);
		$$->tac.push_back(var + " := " + var + " + " + "1");
		$$->tac.push_back("goto " + label0);
		$$->tac.push_back(label2 + ": ");
	}
	| T_REPITEBURDA abrir_scope var_ciclo_determinado T_CONFLOW expresion bloque_instrucciones cerrar_scope {
		ASTNode* new_node = makeASTNode("Bucle", "Determinado");
		
		/* IMPLEMENTAR CONDICIONAL PARA RANGOS */

		// Incluimos el flow
		ASTNode* node_flow = makeASTNode("con_flow", "Pasos");
		node_flow->children.push_back($5);
		$3->children.push_back(node_flow);

		new_node->children.push_back($3);
		new_node->children.push_back($6);

		$$ = new_node;

		// TAC para for
		string var = $3->name, 
			   init = $3->children[0]->children[0]->temp,
			   finish = $3->children[1]->children[0]->temp;

		concat_TAC($$, $3->children[0]->children[0]);
		$$->tac.push_back(var + " := " + init);
		concat_TAC($$, $3->children[1]->children[0], $5);
		
		string label0 = labelGen.newLabel(),
			   label1 = labelGen.newLabel(),
			   label2 = labelGen.newLabel();
		
		$$->tac.push_back(label0 + ": ");
		$$->tac.push_back("if " + var + " < " + finish + " goto " + label1);
		$$->tac.push_back("goto " + label2);
		$$->tac.push_back(label1 + ": ");
		concat_TAC($$, $6);
		$$->tac.push_back(var + " := " + var + " + " + $5->temp);
		$$->tac.push_back("goto " + label0);
		$$->tac.push_back(label2 + ": ");
	}
	;

entrada_salida:
	T_RESCATA T_IZQPAREN secuencia T_DERPAREN { $$ = nullptr; }
	| T_HABLAME T_IZQPAREN expresion T_DERPAREN { $$ = nullptr; }
	;

firma_estructura:
	clase_estructura T_ID {
		string class_struct = $1->name;
		Attributes* struct_attr = new Attributes();
		struct_attr->symbol_name = $2;
		struct_attr->scope = symbolTable.current_scope;
		struct_attr->category = class_struct== "arroz_con_mango" ? STRUCT : UNION;
		struct_attr->value = nullptr;

		if (!symbolTable.insert_symbol($2, *struct_attr)) {
			FLAG_ERROR = class_struct == "arroz_con_mango" ? ALREADY_DEF_STRUCT : ALREADY_DEF_UNION;
			yyerror($2);
		}

		$$ = makeASTNode($2, "Declaración", class_struct, "Estructura");
		$$->show_value = false;
	}

clase_estructura:
	T_COLIAO { $$ = makeASTNode("coliao"); }
	| T_ARROZCONMANGO { $$ = makeASTNode("arroz_con_mango"); }
	;

atributo:
	T_ID T_DOSPUNTOS tipos { $$ = makeASTNode($1, "Atributo_Estructura", $3->type); }

secuencia_atributos:
	{ $$ = nullptr; }
	| atributo { $$ = $1; }
	| secuencia_atributos T_PUNTOCOMA atributo {
		$$ = makeASTNode("Instrucción", "", "", ";");
		$$->children.push_back($1); // Agregar la secuencia de atributos
		$$->children.push_back($3); // Agregar el atributo actual
	}
	;

estructura: 
	firma_estructura abrir_scope T_IZQLLAVE secuencia_atributos T_PUNTOCOMA T_DERLLAVE { 
		string type_struct = $1->type;
		Attributes* struct_attr = symbolTable.search_symbol($1->name);
		if (struct_attr == nullptr) {
			FLAG_ERROR = type_struct == "arroz_con_mango" ? NON_DEF_STRUCT : NON_DEF_UNION;
			yyerror($1->name.c_str());
		} else {
			// Recolectar todos los nodos de parámetro
			if ($4) {
				string field_name = "";
				set<string> categories = {"Atributo_Estructura"};
				vector<ASTNode*> attr_nodes;
				collect_nodes_by_categories($4, categories, attr_nodes);
				for (auto attr : attr_nodes) {
					field_name = struct_attr->symbol_name + "." + attr->name;
					
					Attributes* field_attr = symbolTable.search_symbol(field_name);
					bool error = false;
					if (field_attr != nullptr) {
						if (field_attr->category == STRUCT_ATTRIBUTE && field_attr->scope == symbolTable.current_scope) {
							FLAG_ERROR = ALREADY_DEF_ATTR;
							yyerror(attr->name.c_str());
							error = true;
						}
					}
					
					if (!error) {
						field_attr = new Attributes();
						field_attr->symbol_name = field_name;
						field_attr->scope = symbolTable.current_scope;
						field_attr->type = symbolTable.search_symbol(attr->type);
						if (field_attr->type == nullptr) {
							FLAG_ERROR = NON_DEF_TYPE;
							yyerror(attr->type.c_str());
						}
						field_attr->category = STRUCT_ATTRIBUTE;

						struct_attr->info.push_back({field_name, field_attr});

						symbolTable.insert_symbol(field_name, *field_attr);
					}
				}
			} else {
				FLAG_ERROR = type_struct == "arroz_con_mango" ? EMPTY_STRUCT : EMPTY_UNION;
				yyerror($1->name.c_str());
			}
			
			$$ = $1;
			if ($4) $$->children.push_back($4); // Agregar la secuencia de atributos
		}
	}
	;

firma_funcion: 
	T_ECHARCUENTO T_ID {
		Attributes* func_attr = new Attributes();
		func_attr->symbol_name = $2;
		func_attr->scope = symbolTable.current_scope; // Scope de la función
		func_attr->type = symbolTable.search_symbol("funcion$");
		func_attr->category = FUNCTION;
		func_attr->value = nullptr;

		if(!symbolTable.insert_symbol($2, *func_attr)){
			FLAG_ERROR = ALREADY_DEF_FUNC;
			yyerror($2);
		}
		
		$$ = makeASTNode($2, "Firma_Funcion");
	}
	;

parametro:
	T_AKITOY T_ID T_DOSPUNTOS tipos { $$ = nullptr; }
	| T_ID T_DOSPUNTOS tipos {
		Attributes* param_attr = new Attributes();
		param_attr->symbol_name = $1;
		param_attr->scope = symbolTable.current_scope;
		param_attr->type = symbolTable.search_symbol($3->type);
		param_attr->category = PARAMETERS;
		param_attr->value = nullptr;

		if (!symbolTable.insert_symbol($1, *param_attr)){
			FLAG_ERROR = ALREADY_DEF_PARAM;
			string error_msg = "'" + param_attr->symbol_name + "' dos veces en el mismo cuento?, te gusta la versatilidad locota.";
			yyerror(error_msg.c_str());
		}
		
		$$ = makeASTNode($1, "Parámetro", $3->type);
		$$->show_value = false;
	}

secuencia_parametros:
	{ $$ = nullptr; }
	| parametro { $$ = $1; }
	| secuencia_parametros T_COMA parametro {
		$$ = makeASTNode("Secuencia", "Declaración", "", ",");
		$$->show_value = false;
		$$->children.push_back($1);
		$$->children.push_back($3);
	}
	;

funcion:
	firma_funcion abrir_scope T_IZQPAREN secuencia_parametros T_DERPAREN T_LANZA tipos bloque_instrucciones { 
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
			$$->show_value = false;
			if ($4) $$->children.push_back($4); // Agregar la secuencia de parámetros
			if ($8) $$->children.push_back($8); // Agregar instrucciones

			string label_func = labelGen.newLabel(func_name);
			$$->tac.push_back(label_func + ": \n" + "begin_func:");
			concat_TAC($$, $8);
			$$->tac.push_back("end_func:");
		}
	}
	;

llamada_funcion:
	T_ID T_IZQPAREN secuencia T_DERPAREN {
		ASTNode* new_node = makeASTNode($1, "Llamada_Funcion", "Desconocido");
		if ($3) new_node->children.push_back($3); // Agregar la secuencia de parámetros

		Attributes* func_attr = symbolTable.search_symbol($1);
		if (func_attr == nullptr) {
			FLAG_ERROR = NON_DEF_FUNC;
			yyerror($1);
		} else if (func_attr->category != FUNCTION) {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "\"" + string($1) + "\" y no es 'cuento', marbaa' bruja.";
			yyerror(error_msg.c_str());
		} else {
			new_node->type = func_attr->type->symbol_name;
			// Recolectar todos los nodos de argumentos.
			set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array, Atributo_Estructura"};
			vector<ASTNode*> arg_nodes;
			collect_nodes_by_categories($3, categories, arg_nodes);
			
			if (arg_nodes.size() > func_attr->info.size()) {
				FLAG_ERROR = FUNC_PARAM_EXCEEDED;
				yyerror($1);
			} else if (arg_nodes.size() < func_attr->info.size()) {
				FLAG_ERROR = FUNC_PARAM_MISSING;
				yyerror($1);
			} else {
				// Verificacion de tipo en cada argumento.
				string func_name, param_name, param_type, arg_type = "";
				for (int i = 0; i < arg_nodes.size(); i++) {
					ASTNode* arg_node = arg_nodes[i];
					Attributes* param_attr = func_attr->info[i].second;

					if (param_attr == nullptr) {
						FLAG_ERROR = INTERNAL;
						yyerror("ERROR: Parámetro no encontrado");
					} else {
						func_name = func_attr->symbol_name;
						param_name = param_attr->symbol_name;
						param_type = param_attr->type->symbol_name;
						arg_type = arg_node->type;
						if (param_type != arg_type && (param_type != "manguangua" || arg_type != "manguita")) {
							FLAG_ERROR = TYPE_ERROR;
							string error_msg = "al parámetro \"" + param_name + "\" de tipo '" + param_type + 
								"' en el cuento '" + func_name + "' y le quieres meter un tipo '" + arg_type + "', marbaa' bruja.";
							yyerror(error_msg.c_str());
						}
					}
				}
			}
		}
		$$ = new_node;

		// Generación de TAC para llamada a función
		set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array, Atributo_Estructura"};
		vector<ASTNode*> arg_nodes;
		collect_nodes_by_categories($3, categories, arg_nodes);
		for (ASTNode* arg_node : arg_nodes) {
			concat_TAC($$, arg_node);
			$$->tac.push_back("param " + arg_node->temp);
		}
		if (func_attr && func_attr->type && func_attr->type->symbol_name != "un_coño") {
			// La función retorna un valor, genera un temporal
			string temp = labelGen.newTemp();
			$$->tac.push_back(temp + " := call " + string($1) + ", " + to_string(arg_nodes.size()));
			$$->temp = temp;
		} else {
			// La función no retorna valor, solo genera la llamada
			$$->tac.push_back("call " + string($1) + ", " + to_string(arg_nodes.size()));
		}
	}

var_manejo_error:
	T_COMO abrir_scope T_ID { $$ = nullptr; }

manejador:
	{ $$ = nullptr; }
	| T_FUERADELPEROL abrir_scope bloque_instrucciones cerrar_scope { $$ = nullptr; }
	| T_FUERADELPEROL var_manejo_error bloque_instrucciones cerrar_scope { $$ = nullptr; }
	;

manejo_error:
	T_T_MEANDO abrir_scope bloque_instrucciones cerrar_scope manejador { $$ = nullptr; }
	;

casting:
	T_CASTEO expresion { $$ = nullptr; }
	;

%%

void yyerror(const char *var) {
	string error_msg; // Variable para construir el mensaje de error

	if (FLAG_ERROR == SEMANTIC) {
		extern char* yytext;
		error_msg = "Qué garabato escribiste en línea " + to_string(yylineno) +
					", columna " + to_string(yylloc.first_column) +
					": '" + yytext + "'\n     " + var;
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
			case EMPTY_STRUCT:
				error_msg += "Este arroz_con_mango \"" + string(var) + "\" está más pelao' que olla de pobre. No tiene atributos locota.";
				break;

			case NON_DEF_UNION:
				error_msg += "Este coliao \"" + string(var) + "\" esta en tu cabeza nada más. Deja la droga.";
				break;
			case ALREADY_DEF_UNION:
				error_msg += "Quieres colear a \"" + string(var) + "\" dos veces, marbao' abusador.";
				break;
			case EMPTY_UNION:
				error_msg += "Este coliao \"" + string(var) + "\" vive en Europa, no hay cola donde coliarse. No tiene atributos locota.";
				break;

			case NON_DEF_TYPE:
				error_msg += "El tipo este \"" + string(var) + "\" lo tienes adentro debe ser. Nadie lo ve.";
				break;
			case ALREADY_DEF_TYPE:
				error_msg += "El tipo este \"" + string(var) + "\" ya existe. Dice que te extraña de anoche.";
				break;

			case NON_DEF_ATTR:
				error_msg += "El atributo \"" + string(var) + "\" esta en tu cabeza nada más. Deja la droga.";
				break;
			case ALREADY_DEF_ATTR:
				error_msg += "El atributo \"" + string(var) + "\" ya existe, marbao' copion.";
				break;

			case MODIFY_VAR_FOR:
				error_msg += "Esta variable \"" + string(var) + "\" es de `repite_burda`. Déjala quieta, no se cambia. Men tiende?";
				break;

			case TRY_ERROR:
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
				break;

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