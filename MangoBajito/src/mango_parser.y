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

// Inicializacion de la tabla de símbolos
SymbolTable symbolTable = SymbolTable();

// Inicializacion de Grafo de Control de Flujo
FlowGraph flow_graph = FlowGraph();
SolverFlowGraphProblem solver_problem = SolverFlowGraphProblem();

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
	{INVALID_OPERATION, {}},
	{MODIFY_CONST, {}},
	{SEGMENTATION_FAULT, {}},
	{FUNC_PARAM_EXCEEDED, {}},
	{FUNC_PARAM_MISSING, {}},
	{FUNC_RETURN_VALUE, {}},
	{FUNC_NO_RETURN, {}},
	{ALREADY_DEF_PARAM, {}},
	{EMPTY_ARRAY_CONSTANT, {}},
	{POINTER_ARRAY, {}},
	{INT_INDEX_ARRAY, {}},
	{SIZE_ARRAY_INVALID, {}},
	{INVALID_ACCESS, {}},
	{CASTING_TYPE, {}},
	{CASTING_ERROR, {}},
	{OVERFULL, {}},
	{INTERNAL, {}},
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

%token T_MEPIDE T_SE_PRENDE T_ASIGNACION T_DOSPUNTOS T_PUNTOCOMA T_COMA
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
%token <sval> T_ID T_CASTEO
%token <att_val> T_VALUE
%token T_IZQPAREN T_DERPAREN T_IZQLLAVE T_DERLLAVE T_IZQCORCHE T_DERCORCHE

// Declaracion de tipos de retorno para las producciones 
%type <ast> programa libreria main
%type <ast> asignacion operadores_asignacion operaciones_unitarias
%type <ast> instruccion secuencia_instrucciones instrucciones bloque_instrucciones
%type <ast> declaracion tipo_declaracion declaracion_aputador 
%type <ast> estructura firma_estructura clase_estructura acceso_struct atributo secuencia_atributos
%type <ast> tipos tipo_valor lista_dimensiones dimension
%type <ast> expresion expresion_apuntador expresion_nuevo 
%type <ast> secuencia
%type <ast> condicion guardia_siesasi alternativa guardia guardia_con_bloque
%type <ast> bucle indeterminado determinado var_ciclo_determinado
%type <ast> firma_funcion parametro secuencia_parametros funcion llamada_funcion
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

%right T_CASTEO

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
			if (ast_root) print_TAC(ast_root);
			if (!ast_root->tac.empty()) {
				flow_graph.generateFlowGraph(ast_root->tac);
				//flow_graph.computeINandOUT_lived_var();
				solver_problem.set_direction(BACKWARD);
				solver_problem.solver_data_flow_problem(flow_graph);
				flow_graph.print();
				generateAssemblyCode(ast_root, flow_graph.blocks);
			}
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
	libreria { $$ = $1; }
	| declaracion { $$ = $1; }
	| asignacion { $$ = $1; }
	| llamada_funcion { $$ = $1; }
	| condicion { $$ = $1; }
	| bucle { $$ = $1; }
	| manejo_error { $$ = $1; }
	| T_KIETO { $$ = makeASTNode("uy_kieto", "Control de Flujo"); $$->tac.push_back("break"); }
	| T_ROTALO { $$ = makeASTNode("rotalo", "Control de Flujo"); $$->tac.push_back("continue"); }
	| T_LANZATE expresion { 
		string type = $2->type;
		$$ = makeASTNode("lanzate", "Control de Flujo", type);
		$$->children.push_back($2);

		if (type == "mango") $$->ivalue = $2->ivalue;
		else if (type == "manguita") $$->fvalue = $2->fvalue;
		else if (type == "manguangua") $$->dvalue = $2->dvalue;
		else if (type == "negro") $$->cvalue = $2->cvalue;
		else if (type == "higuerote") $$->svalue = $2->svalue;
		else if (type == "tas_claro") $$->bvalue = $2->bvalue;
		else if (type == "pointer") {
			// Por implementar
		}
		
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
					if(var_attr->declare == CONSTANT || var_attr->declare == POINTER_C) {
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
		$$->temp = $1->temp;
		if ($2->name == "--"){
			$$->tac.push_back($1->temp + " := " + $1->temp + " - 1");
		} else {
			$$->tac.push_back($1->temp + " := " + $1->temp + " + 1");
		}
	}
	| T_BORRADOL T_ID { $$ = nullptr; }
	| T_BORRADOL T_ID T_PUNTO T_ID { $$ = nullptr; }
	| T_RESCATA T_IZQPAREN secuencia T_DERPAREN { // Output
		$$ = makeASTNode("rescata", "Output", "higuerote");
		string output = "";
		// Procesar secuencia de elementos a convertir en string(output)
		if ($3) {
			$$->children.push_back($3);
			vector<ASTNode*> secuencia_elements;
			collect_arguments($3, secuencia_elements);
			for (auto elem : secuencia_elements) {
				if (elem->type == "mango") {
					output += to_string(elem->ivalue);
				} else if (elem->type == "manguita") {
					output += to_string(elem->fvalue);
				} else if (elem->type == "manguangua") {
					output += to_string(elem->dvalue);
				} else if (elem->type == "negro") {
					output += string(1, elem->cvalue);
				} else if (elem->type == "higuerote") {
					output += elem->svalue;
				} else if (elem->type == "tas_claro") {
					output += (elem->bvalue ? "Sisa" : "Nolsa");
				} else if (elem->type == "pointer") {
					/* POR IMPLEMENTAR */
					//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
					output += "nullptr";
				} else if (elem->type == "un_coño") {
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "'" + elem->name +  "' de tipo '" + elem->type + "' en el argumento de \"rescata\", cómo muestro un coño?.";
					yyerror(error_msg.c_str());
				} else {
					FLAG_ERROR = INTERNAL;
					string error_msg = "RESCATA -> TIPO DESCONOCIDO: '" + elem->type + "'.";
					yyerror(error_msg.c_str());
				}
			}
		}
		$$->svalue = output;

		// Agregar TAC de salida
		vector<ASTNode*> arg_nodes;
		collect_arguments($3, arg_nodes);
		for (ASTNode* arg_node : arg_nodes) {
			concat_TAC($$, arg_node);
			$$->tac.push_back("param " + arg_node->temp);
		}

		$$->tac.push_back("call print, " + to_string(arg_nodes.size()));
	}
	;

libreria: 
	T_MEPIDE T_ID { $$ = makeASTNode($2, "Libreria"); }
	;

declaracion:
	tipo_declaracion T_ID T_DOSPUNTOS tipos {
		string declared_type = $4->type;
		
		Attributes* type_attr = symbolTable.search_symbol(declared_type);
		if (type_attr == nullptr){
			FLAG_ERROR = NON_DEF_TYPE;
			yyerror(declared_type.c_str());
		} else {
			// Declaracion de Arreglos
			if ($4->category == "Array") {
				int size_array, current_dim = 0;
				ASTNode* size = nullptr;

				// Crear array principal
				Attributes* array_attr = new Attributes();
				array_attr->symbol_name = $2;
				array_attr->category = ARRAY;
				array_attr->declare = stringToDeclare($1->kind);
				array_attr->scope = symbolTable.current_scope;
				array_attr->type = type_attr;
				
				// Extraer size del array principal
				ASTNode* dim = $4->children[0];
				int total_dim = dim->children.size();
				if (total_dim > 0){
					size = dim->children[current_dim];
					if (size->category == "Array_Size" && size->type == "mango") {
						if (size->ivalue <= 0){
							FLAG_ERROR = SIZE_ARRAY_INVALID;
							yyerror(to_string(size->ivalue).c_str());
						} else {
							array_attr->value = size->ivalue;
						}
					}
				}

				// Insertar en tabla de símbolos
				if (!symbolTable.insert_symbol($2, *array_attr)){
					FLAG_ERROR = ALREADY_DEF_VAR;
					yyerror($2);
				}
				
				// Creacion de elementos de un array en formato recursivo.
				string father = "";
				queue<string> fathers;
				fathers.push($2);
				
				while (!fathers.empty()){
					father = fathers.front();
					fathers.pop();
					
					// Determinar la dimension actual segun la cantidad de '[' dentro de father.
					current_dim = count(father.begin(), father.end(), '[');
					
					// Actualizacion de categoria, creacion de elementos tipo array o valor.
					Category current_cat = current_dim < total_dim - 1 ? ARRAY : ID;
					
					Attributes* array = symbolTable.search_symbol(father);
					size_array = get<int>(array->value);
					string elem_name = "";
					for (int i = 0; i < size_array; i++) {
						elem_name = father + "[" + to_string(i) + "]";

						if (symbolTable.search_symbol(elem_name)) {
							FLAG_ERROR = ALREADY_DEF_VAR;
							yyerror(elem_name.c_str());
						} else {
							Attributes *elem = new Attributes();
							elem->symbol_name = elem_name;
							elem->category = current_cat;
							
							// Arreglo multidimension
							if (current_cat == ARRAY) fathers.push(elem_name);
							
							elem->declare = stringToDeclare($1->kind);
							elem->scope = symbolTable.current_scope;
							
							elem->type = type_attr;
							
							// Valor por defecto en caso de ser categoria ID
							if (current_cat == ID){
								string type = type_attr->symbol_name;
								if (type == "mango") elem->value = 0;
								else if (type == "manguita") elem->value = 0.0f;
								else if (type == "manguangua") elem->value = 0.0;
								else if (type == "negro") elem->value = '\0';
								else if (type == "higuerote") {
									elem->value = "";
									elem->info.push_back({0, nullptr});
								} else if (type == "tas_claro") elem->value = false;
							}

							// Incluir size del array en caso de que lo sea.
							if (current_dim + 1 < total_dim && current_cat == ARRAY) {
								size = dim->children[current_dim + 1];
								if (size->category == "Array_Size" && size->type == "mango"){
									if (size->ivalue <= 0){
										FLAG_ERROR = SIZE_ARRAY_INVALID;
										yyerror(to_string(size->ivalue).c_str());
									} else {
										elem->value = size->ivalue;
									}
								}
							}

							// Guardar informacion del elemento al array actual.
							array->info.push_back({elem_name, elem});
				
							// Insertar elemento en tabla de símbolos
							symbolTable.insert_symbol(elem_name, *elem);
						}
					}
				}
			// Declaracion de Estructuras y Uniones
			} else if (type_attr->category == STRUCT || type_attr->category == UNION) { 
				queue<vector<string> > queue_structs;
				queue_structs.push({string($2), declared_type});
				bool father_struct = false;
				while(!queue_structs.empty()) {
					auto data = queue_structs.front();
					queue_structs.pop();

					string struct_name = data[0];
					string struct_type = data[1];

					type_attr = symbolTable.search_symbol(struct_type);

					int size_struct = type_attr->info.size();

					// Crear atributo de la estructura
					Attributes* struct_attr = new Attributes();
					struct_attr->symbol_name = struct_name;
					struct_attr->category = STRUCT;
					struct_attr->declare = stringToDeclare($1->kind);
					struct_attr->scope = symbolTable.current_scope;
					struct_attr->type = type_attr;

					for (int i = 0; i < size_struct; i++) {
						const auto& field = type_attr->info[i];
						string full_field = get<string>(field.first);
						size_t dot_pos = full_field.find('.');
						if (dot_pos == string::npos) continue; // No es un campo válido

						string field_type = field.second->type->symbol_name;

						string attr_name = full_field.substr(dot_pos + 1);
						string new_field_name = struct_name + "." + attr_name;
						if (symbolTable.search_symbol(new_field_name)) {
							FLAG_ERROR = ALREADY_DEF_VAR;
							yyerror(new_field_name.c_str());
						} else {
							if (field.second->type->category == STRUCT || field.second->type->category == UNION) {
								queue_structs.push({new_field_name, field_type});
								continue; // Procesar subestructura
							}

							Attributes* new_attr = new Attributes();
							new_attr->symbol_name = new_field_name;
							new_attr->category = ID;
							new_attr->declare = stringToDeclare($1->kind);
							new_attr->scope = symbolTable.current_scope;
							new_attr->type = symbolTable.search_symbol(field_type);
							
							if (type_attr->category == STRUCT){
								if (field_type == "mango") new_attr->value = 0;
								else if (field_type == "manguita") new_attr->value = 0.0f;
								else if (field_type == "manguangua") new_attr->value = 0.0;
								else if (field_type == "negro") new_attr->value = '\0';
								else if (field_type == "higuerote") new_attr->value = "";
								else if (field_type == "tas_claro") new_attr->value = false;
							}

							// Agregar a la info de la variable y a la tabla de símbolos
							struct_attr->info.push_back({new_field_name, new_attr});
							symbolTable.insert_symbol(new_field_name, *new_attr);
						}
					}
					
					// Insertar en tabla de símbolos
					if (!symbolTable.insert_symbol(struct_name, *struct_attr)) {
						FLAG_ERROR = ALREADY_DEF_VAR;
						yyerror(struct_name.c_str());
					}
					// Actualizar vector de informacion de estructura padre.
					if (father_struct) {
						size_t pos = struct_name.rfind('.');
						string father = struct_name.substr(0, pos);
						Attributes* father_attr = symbolTable.search_symbol(father);
						father_attr->info.push_back({struct_name, struct_attr});
					}
					father_struct = true;
				}
				
			// Declaracion de tipos basicos
			} else {
				Attributes* attribute = new Attributes();
				attribute->symbol_name = $2;
				attribute->category = ID;
				attribute->declare = stringToDeclare($1->kind);
				attribute->scope = symbolTable.current_scope;
				attribute->type = type_attr;
				string type = type_attr->symbol_name;
				if (type == "mango") attribute->value = 0;
				else if (type == "manguita") attribute->value = 0.0f;
				else if (type == "manguangua") attribute->value = 0.0;
				else if (type == "negro") attribute->value = '\0';
				else if (type == "higuerote") {
					attribute->value = "";
					attribute->info.push_back({0, nullptr});
				} else if (type == "tas_claro") attribute->value = false;

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

		Attributes* attr_var = symbolTable.search_symbol($2);
		if ($1->kind == "VARIABLE" && attr_var != nullptr) {
			int scope_level = attr_var->scope;
			int size_to_reserve = -1;
			// Agregar variable a .declaration
			Attributes* attr_type = symbolTable.search_symbol($4->name);
			if ($4->category == "Identificador" && attr_type != nullptr){ //Estructuras y variantes
				if (attr_type->category == STRUCT) size_to_reserve = sumOfSizeTypes(attr_type->info);
				if (attr_type->category == UNION) size_to_reserve = maxOfSizeType(attr_type->info);
			} else if($4->category == "Array"){ // arrays
				int size_array = $4->children[0]->ivalue;
				int size_type = strToSizeType($4->type);
				size_to_reserve = size_type * size_array;
			}else if($4->category == "Type"){ // tipos definidos
				size_to_reserve = strToSizeType(declared_type);
			}
			if (size_to_reserve != -1) $$->tac_declaraciones.push_back({scope_level, {string($2), size_to_reserve}});
		}
	}
	| tipo_declaracion T_ID T_DOSPUNTOS tipos T_ASIGNACION expresion {
		string left_type = $4->type;
		string right_type = $6->type;

		Attributes* type_attr = symbolTable.search_symbol(left_type);
		if (type_attr == nullptr){
			FLAG_ERROR = NON_DEF_TYPE;
			yyerror(left_type.c_str());
		} else {
			// Declaracion de Arreglo con asignacion
			if ($4->category == "Array" && $6->category == "Array") {
				int size_array, current_dim = 0;
				int lineal_total_size = 0;
				ASTNode* size = nullptr;

				// Crear array principal
				Attributes* array_attr = new Attributes();
				array_attr->symbol_name = $2;
				array_attr->category = ARRAY;
				array_attr->declare = stringToDeclare($1->kind);
				array_attr->scope = symbolTable.current_scope;
				array_attr->type = type_attr;
				
				// Extraer size del array principal
				ASTNode* dim = $4->children[0];
				int total_dim = dim->children.size();
				if (total_dim > 0){
					size = dim->children[current_dim];
					if (size->category == "Array_Size" && size->type == "mango") {
						if (size->ivalue <= 0){
							FLAG_ERROR = SIZE_ARRAY_INVALID;
							yyerror(to_string(size->ivalue).c_str());
						} else {
							array_attr->value = size->ivalue;
							lineal_total_size = size->ivalue; // Inicializar con el tamaño de la primera dimension.
						}
					}
					// Calcular la dimension lineal total del array.
					for (int i = 1; i < total_dim; i++) {
						ASTNode* dim_node = dim->children[i];
						if (dim_node->category == "Array_Size" && dim_node->type == "mango" && dim_node->ivalue > 0) {
							lineal_total_size *= dim_node->ivalue;
						}
					}
				}

				// Insertar en tabla de símbolos
				if (!symbolTable.insert_symbol($2, *array_attr)){
					FLAG_ERROR = ALREADY_DEF_VAR;
					yyerror($2);
				}
				
				// Extraer los elementos a declarar en el array.
				int count_elems = 0;
				int total_elems = 0;
				set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Elemento_String", "Atributo_Estructura"};
				vector<ASTNode*> array_elements;
				collect_nodes_by_categories($6, categories, array_elements);
				total_elems = array_elements.size(); // Totalidad lineal de los elementos a la derecha.

				// Verificar cantidad de elementos totales a declarar.
				if (lineal_total_size > total_elems && lineal_total_size > 0) {
					FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
					string error_msg = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(total_elems) + "' de '" + to_string(lineal_total_size) + "'.";
					yyerror(error_msg.c_str());
				} else if (lineal_total_size < total_elems && lineal_total_size > 0) {
					FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
					string error_msg = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(lineal_total_size) + "' cositas.";
					yyerror(error_msg.c_str());
				} else if (lineal_total_size > 0 && total_elems > 0) {
					// Creacion de elementos de un array en formato recursivo.
					string father = "";
					queue<string> fathers;
					fathers.push($2);
					
					while (!fathers.empty()){
						father = fathers.front();
						fathers.pop();
						
						// Determinar la dimension actual segun la cantidad de '[' dentro de father.
						current_dim = count(father.begin(), father.end(), '[');
						
						// Actualizacion de categoria, creacion de elementos tipo array o valor.
						Category current_cat = current_dim < total_dim - 1 ? ARRAY : ID;
						
						Attributes* array = symbolTable.search_symbol(father);
						size_array = get<int>(array->value);
						string elem_name = "";
						for (int i = 0; i < size_array; i++) {
							elem_name = father + "[" + to_string(i) + "]";

							if (symbolTable.search_symbol(elem_name)) {
								FLAG_ERROR = ALREADY_DEF_VAR;
								yyerror(elem_name.c_str());
							} else {
								Attributes *elem = new Attributes();
								elem->symbol_name = elem_name;
								elem->category = current_cat;
								
								// Arreglo multidimension
								if (current_cat == ARRAY) fathers.push(elem_name);
								
								elem->declare = stringToDeclare($1->kind);
								elem->scope = symbolTable.current_scope;
								
								elem->type = type_attr;
								
								// Valor por defecto en caso de ser categoria ID
								if (current_cat == ID){
									ASTNode* elem_node = array_elements[count_elems++];
									if (left_type != elem_node->type && (left_type != "manguangua" || elem_node->type != "manguita")) {
										FLAG_ERROR = TYPE_ERROR;
										string error_msg = "\"" + father + "\" de tipo '" + left_type + 
											"[]' y le quieres meter un '" + elem_node->type + "[]', marbaa' bruja.";
										yyerror(error_msg.c_str());
										elem->value = nullptr;
									} else {
										if (elem_node->type == "mango") elem->value = elem_node->ivalue;
										else if (elem_node->type == "manguita") elem->value = elem_node->fvalue;
										else if (elem_node->type == "manguangua") elem->value = elem_node->dvalue;
										else if (elem_node->type == "negro") elem->value = elem_node->cvalue;
										else if (elem_node->type == "higuerote") {
											elem->value = elem_node->svalue;
											elem->info.push_back({static_cast<int>(elem_node->svalue.size()), nullptr});
										} else if (elem_node->type == "tas_claro") {
											elem->value = elem_node->bvalue;
											if (!elem->info.empty()) elem->info[0].first = (elem_node->bvalue ? "Sisa" : "Nolsa");
											else elem->info.push_back({(elem_node->bvalue ? "Sisa" : "Nolsa"), nullptr});
										} else if (elem_node->type == "pointer"){
											/* POR IMPLEMENTAR */
											//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
											elem->value = nullptr;
										} else {
											FLAG_ERROR = INTERNAL;
											string error_msg = "TIPO DESCONOCIDO: Asignando 'nullptr' a: '" + father + "'.";
											yyerror(error_msg.c_str());
											elem->value = nullptr;
										}
									}
								}

								// Incluir size del array en caso de que lo sea.
								if (current_dim + 1 < total_dim && current_cat == ARRAY) {
									size = dim->children[current_dim + 1];
									if (size->category == "Array_Size" && size->type == "mango"){
										if (size->ivalue <= 0){
											FLAG_ERROR = SIZE_ARRAY_INVALID;
											yyerror(to_string(size->ivalue).c_str());
										} else {
											elem->value = size->ivalue;
										}
									}
								}

								// Guardar informacion del elemento al array actual.
								array->info.push_back({elem_name, elem});
					
								// Insertar elemento en tabla de símbolos
								symbolTable.insert_symbol(elem_name, *elem);
							}
						}
					}
				}

			} else if ($4->category != "Array" && $6->category == "Array"){
				FLAG_ERROR = TYPE_ERROR;
				string type_right_update = $6->children[0]->name != "Secuencia" ? $6->children[0]->type : $6->children[0]->children[0]->type ;
				string error_msg = "\"" + string($2) + "\" de tipo '" + left_type + 
					"' y le quieres meter un elemento de tipo '" + type_right_update + "', marbaa' bruja.";
				yyerror(error_msg.c_str());
			} else if ($4->category == "Array" && $6->category != "Array") {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "\"" + string($2) + "\" de tipo '" + left_type + 
					"[]' y le quieres meter un elemento de tipo '" + right_type + "', marbaa' bruja.";
				yyerror(error_msg.c_str());
			} else if (type_attr->category == UNION && $6->category == "Estructura") {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "\"" + string($2) + "\" de tipo '" + left_type + 
					"'(coliao) y le quieres meter un 'arroz_con_mango', marbaa' bruja.";
				yyerror(error_msg.c_str());

			// Declaracion y asignacion de estructuras
			} else if (type_attr->category == STRUCT && $6->category == "Estructura") {
				
				queue<pair<vector<string>, ASTNode*> > queue_structs;
				queue_structs.push({{string($2), left_type}, $6});
				bool father_struct = false;
				while(!queue_structs.empty()) {
					auto data = queue_structs.front();
					queue_structs.pop();

					string struct_name = data.first[0];
					string struct_type = data.first[1];
					ASTNode* struct_elements_node = data.second;

					type_attr = symbolTable.search_symbol(struct_type);

					if (type_attr->category != STRUCT || struct_elements_node->category != "Estructura"){
						FLAG_ERROR = TYPE_ERROR;
						string error_msg = "\"" + struct_name + "\" de tipo '" + struct_type + 
							"' y le quieres meter un 'arroz_con_mango', marbaa' bruja.";
						yyerror(error_msg.c_str());
					} else {
						int size_struct = type_attr->info.size();

						// Crear atributo de la estructura
						Attributes* struct_attr = new Attributes();
						struct_attr->symbol_name = struct_name;
						struct_attr->category = STRUCT;
						struct_attr->declare = stringToDeclare($1->kind);
						struct_attr->scope = symbolTable.current_scope;
						struct_attr->type = type_attr;

						set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Elemento_String", "Atributo_Estructura", "Estructura"};
						vector<ASTNode*> struct_elements;
						collect_nodes_by_categories(struct_elements_node, categories, struct_elements);
						// Remover el primer elemento del vector de elementos. Se captura el mismo nodo "Estructura".
						struct_elements.erase(struct_elements.begin());

						int count_elems = struct_elements.size();

						if (size_struct == 0 || count_elems == 0) {
							FLAG_ERROR = EMPTY_STRUCT;
							yyerror(struct_name.c_str());
						} else if (count_elems > size_struct) {
							FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
							string error_msg = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(size_struct) + "' cositas.";
							yyerror(error_msg.c_str());
						} else if (count_elems < size_struct) {
							FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
							string error_msg = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(count_elems) + "' de '" + to_string(size_struct) + "'.";
							yyerror(error_msg.c_str());
						} else {
							for (int i = 0; i < count_elems; i++) {
								const auto& field = type_attr->info[i];
								string full_field = get<string>(field.first);
								size_t dot_pos = full_field.find('.');
								if (dot_pos == string::npos) continue; // No es un campo válido

								string field_type = field.second->type->symbol_name;

								string attr_name = full_field.substr(dot_pos + 1);
								string new_field_name = struct_name + "." + attr_name;
								if (symbolTable.search_symbol(new_field_name)) {
									FLAG_ERROR = ALREADY_DEF_VAR;
									yyerror(new_field_name.c_str());
								} else {
									ASTNode* elem = struct_elements[i];

									if (elem->category == "Estructura") {
										queue_structs.push({{new_field_name, field_type}, elem});
										continue; // Procesar subestructura
									}

									Attributes* new_attr = new Attributes();
									new_attr->symbol_name = new_field_name;
									new_attr->category = ID;
									new_attr->declare = stringToDeclare($1->kind);
									new_attr->scope = symbolTable.current_scope;
									new_attr->type = symbolTable.search_symbol(field_type);
									

									if (field_type != elem->type && (field_type != "manguangua" || elem->type != "manguita")) {
										FLAG_ERROR = TYPE_ERROR;
										string error_msg = "\"" + new_field_name + "\" de tipo '" + field_type + 
											"' y le quieres meter un '" + elem->type + "', marbaa' bruja.";
										yyerror(error_msg.c_str());
										new_attr->value = nullptr;
									} else {
										if (elem->type == "mango") {
											new_attr->value = elem->ivalue;
										} else if (elem->type == "manguita") {
											new_attr->value = elem->fvalue;
										} else if (elem->type == "manguangua") {
											new_attr->value = elem->dvalue;
										} else if (elem->type == "negro") {
											new_attr->value = elem->cvalue;
										} else if (elem->type == "higuerote") {
											new_attr->value = elem->svalue;
										} else if (elem->type == "tas_claro") {
											new_attr->value = elem->bvalue;
											if (!new_attr->info.empty()) new_attr->info[0].first = (elem->bvalue ? "Sisa" : "Nolsa");
											else new_attr->info.push_back({(elem->bvalue ? "Sisa" : "Nolsa"), nullptr});
										} else if (elem->type == "pointer"){
											/* POR IMPLEMENTAR */
											//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
											new_attr->value = nullptr;
										} else {
											FLAG_ERROR = INTERNAL;
											string error_msg = "TIPO DESCONOCIDO: '" + elem->type + "'.";
											yyerror(error_msg.c_str());
											new_attr->value = nullptr;
										}
									}

									// Agregar a la info de la variable y a la tabla de símbolos
									struct_attr->info.push_back({new_field_name, new_attr});
									symbolTable.insert_symbol(new_field_name, *new_attr);
								}
							}
						}
						// Insertar en tabla de símbolos
						if (!symbolTable.insert_symbol(struct_name, *struct_attr)) {
							FLAG_ERROR = ALREADY_DEF_VAR;
							yyerror(struct_name.c_str());
						}
						// Actualizar vector de informacion de estructura padre.
						if (father_struct) {
							size_t pos = struct_name.rfind('.');
							string father = struct_name.substr(0, pos);
							Attributes* father_attr = symbolTable.search_symbol(father);
							father_attr->info.push_back({struct_name, struct_attr});
						}
						father_struct = true;
					}
				}

			// Declaracion de tipos basicos con asignacion
			} else {
				Attributes *attribute = new Attributes();
				attribute->symbol_name = $2;
				attribute->category = ID;
				attribute->declare = stringToDeclare($1->kind);
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
						attribute->info.push_back({static_cast<int>($6->svalue.size()), nullptr}); // Agregar tamaño de cadena
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
		if($1->kind != "CONSTANTE" && $4->category != "Array") $$->tac.push_back(string($2) + " := " + $6->temp);
		
		Attributes* attr_var = symbolTable.search_symbol($2);
		// Agregar TAC de declaraciones
		if ($1->kind == "VARIABLE" && attr_var != nullptr) {
			// Agregar variable a .declaration
			int scope_level = attr_var->scope;
			int size_to_reserve = -1;
			if($4->category == "Array"){
				set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Atributo_Estructura"};
				vector<ASTNode*> array_elements;
				collect_nodes_by_categories($6, categories, array_elements);
				int size_array = $4->children[0]->ivalue;
				int size_type = strToSizeType($4->type);
				size_to_reserve = size_type * size_array;

				for (int i = 0; i < size_array; i++) {
					string temp = labelGen.newTemp();
					$$->tac.push_back(temp + " := " + to_string(i)+ " * " + to_string(size_type));
					$$->tac.push_back(string($2) + "[" + temp + "] := " + array_elements[i]->temp);
				}
			}else if ($4->category == "Identificador" && attr_var != nullptr){ // Estructuras
				/* por implementar */
			} else if ($4->category == "Type" && attr_var != nullptr) {
				size_to_reserve = strToSizeType(left_type);
			}
			if (size_to_reserve != -1) $$->tac_declaraciones.push_back({scope_level, {string($2), size_to_reserve}});
		} else if ($1->kind == "CONSTANTE" && attr_var != nullptr) {
			// Agregar constante a .data
			if($6->category == "Cadena de Caracteres"){
				$$->tac_data.emplace_back(string($2), $6->temp);
			} else if ($4->category == "Array") {
				// Agregar cada elemento del array a .
				set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Atributo_Estructura"};
				vector<ASTNode*> array_elements;
				collect_nodes_by_categories($6, categories, array_elements);
				int size_array = $4->children[0]->ivalue;
				for (int i = 0; i < size_array; i++) {
					string elem_name = string($2) + "[" + to_string(i*strToSizeType($4->type)) + "]";
					$$->tac_data.emplace_back(elem_name, array_elements[i]->temp);
				}
			}else{
				$$->tac_data.emplace_back(string($2), valuesToString($6));
			}
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
	| tipo_valor lista_dimensiones {
		$$ = makeASTNode("Array", "Array", $1->type);
		ASTNode* dim = makeASTNode("Dimensiones");
		dim->children = $2->children;
		$$->children.push_back(dim);
	}
	| T_ID { $$ = makeASTNode($1, "Identificador", $1); }
	| T_UNCONO { $$ = makeASTNode("un_coño", "Tipo_Funcion", "un_coño"); }
	;

tipo_valor:
	T_MANGO { $$ = makeASTNode("mango", "Type", "mango"); }
	| T_MANGUITA { $$ = makeASTNode("manguita", "Type", "manguita"); }
	| T_MANGUANGUA { $$ = makeASTNode("manguangua", "Type", "manguangua"); }
	| T_NEGRO { $$ = makeASTNode("negro", "Type", "negro"); }
	| T_HIGUEROTE { $$ = makeASTNode("higuerote", "Type", "higuerote"); }
	| T_TASCLARO { $$ = makeASTNode("tas_claro", "Type", "tas_claro"); }
	;

lista_dimensiones:
	dimension {
		$$ = makeASTNode("Dimension");
		$$->children.push_back($1);
	}
	| lista_dimensiones dimension {
		$$ = $1;
		$$->children.push_back($2);
	}
	;

dimension:
	T_IZQCORCHE expresion T_DERCORCHE {
		$$ = makeASTNode($2->name, "Array_Size", $2->type);
		if ($2->type != "mango") {
			FLAG_ERROR = SIZE_ARRAY_INVALID;
			yyerror($2->type.c_str());
		}
		$$->ivalue = $2->ivalue;
	}
	;

asignacion:
	T_ID operadores_asignacion expresion {
		ASTNode* new_node = makeASTNode($1, "Identificador");

		string id = string($1);
		string op = $2->kind;
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
			
			if (attribute->declare == CONSTANT || attribute->declare == POINTER_C) {
				FLAG_ERROR = MODIFY_CONST;
				yyerror($1);
			}
			
			left_type = attribute->type->symbol_name;
			new_node->type = left_type;
			$2->type = left_type; // Asignar el tipo al nodo del operador de asignación

			// Asignacion de arreglos
			if (attribute->category == ARRAY && $3->category == "Array" && op == "=") {
				int size_array, current_dim = 0;
				int total_dim = 1;
				Attributes* size = attribute;

				int lineal_total_size = get<int>(size->value);
				while(true) {
					size = symbolTable.search_symbol(get<string>(size->info[0].first));
					if (size->category == ARRAY) {
						lineal_total_size *= get<int>(size->value);
						total_dim++;
					} else break;
				}

				// Extraer los elementos a asignar en el array.
				int count_elems = 0;
				int total_elems = 0;
				set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Elemento_String", "Atributo_Estructura"};
				vector<ASTNode*> array_elements;
				collect_nodes_by_categories($3, categories, array_elements);
				total_elems = array_elements.size(); // Totalidad lineal de los elementos a la derecha.

				// Verificar cantidad de elementos totales a declarar.
				if (lineal_total_size > total_elems && lineal_total_size > 0) {
					FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
					string error_msg = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(total_elems) + "' de '" + to_string(lineal_total_size) + "'.";
					yyerror(error_msg.c_str());
				} else if (lineal_total_size < total_elems && lineal_total_size > 0) {
					FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
					string error_msg = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(lineal_total_size) + "' cositas.";
					yyerror(error_msg.c_str());
				} else if (lineal_total_size > 0 && total_elems > 0) {
					// Creacion de elementos de un array en formato recursivo.
					string father = "";
					queue<string> fathers;
					fathers.push($1);
					
					while (!fathers.empty()){
						father = fathers.front();
						fathers.pop();
						
						// Determinar la dimension actual segun la cantidad de '[' dentro de father.
						current_dim = count(father.begin(), father.end(), '[');
						
						// Actualizacion de categoria, creacion de elementos tipo array o valor.
						Category current_cat = current_dim < total_dim - 1 ? ARRAY : ID;
						
						Attributes* array = symbolTable.search_symbol(father);
						size_array = get<int>(array->value);
						string elem_name = "";
						for (int i = 0; i < size_array; i++) {
							elem_name = father + "[" + to_string(i) + "]";

							Attributes* elem = symbolTable.search_symbol(elem_name);
							if (elem == nullptr) {
								FLAG_ERROR = NON_DEF_VAR;
								yyerror(elem_name.c_str());
							} else {
								// Arreglo multidimension
								if (current_cat == ARRAY) fathers.push(elem_name);
								
								// Valor por defecto en caso de ser categoria ID
								if (current_cat == ID){
									ASTNode* elem_node = array_elements[count_elems++];
									if (left_type != elem_node->type && (left_type != "manguangua" || elem_node->type != "manguita")) {
										FLAG_ERROR = TYPE_ERROR;
										string error_msg = "\"" + elem_name + "\" de tipo '" + left_type + 
											"[]' y le quieres meter un '" + elem_node->type + "[]', marbaa' bruja.";
										yyerror(error_msg.c_str());
										elem->value = nullptr;
									} else {
										if (elem_node->type == "mango") elem->value = elem_node->ivalue;
										else if (elem_node->type == "manguita") elem->value = elem_node->fvalue;
										else if (elem_node->type == "manguangua") elem->value = elem_node->dvalue;
										else if (elem_node->type == "negro") elem->value = elem_node->cvalue;
										else if (elem_node->type == "higuerote") {
											elem->value = elem_node->svalue;
											elem->info.push_back({static_cast<int>(elem_node->svalue.size()), nullptr});
										} else if (elem_node->type == "tas_claro") {
											elem->value = elem_node->bvalue;
											if (!elem->info.empty()) elem->info[0].first = (elem_node->bvalue ? "Sisa" : "Nolsa");
											else elem->info.push_back({(elem_node->bvalue ? "Sisa" : "Nolsa"), nullptr});
										} else if (elem_node->type == "pointer"){
											/* POR IMPLEMENTAR */
											//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
											elem->value = nullptr;
										} else {
											FLAG_ERROR = INTERNAL;
											string error_msg = "TIPO DESCONOCIDO: Asignando 'nullptr' a: '" + father + "'.";
											yyerror(error_msg.c_str());
											elem->value = nullptr;
										}
									}
								}
							}
						}
					}
				}
			} else if (attribute->category != ARRAY && $3->category == "Array"){
				FLAG_ERROR = TYPE_ERROR;
				string type_right_update = $3->children[0]->name != "Secuencia" ? $3->children[0]->type : $3->children[0]->children[0]->type ;
				string error_msg = "\"" + string($1) + "\" de tipo '" + left_type + 
					"' y le quieres meter un elemento de tipo '" + type_right_update + "', marbaa' bruja.";
				yyerror(error_msg.c_str());
			} else if (attribute->category == ARRAY && $3->category != "Array") {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "\"" + string($1) + "\" de tipo '" + left_type + 
					"[]' y le quieres meter un elemento de tipo '" + right_type + "', marbaa' bruja.";
				yyerror(error_msg.c_str());
			} else if (attribute->category == ARRAY && $3->category == "Array" && op != "=") {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "\"" + id + "\" de tipo '" + left_type + 
					"'[] y quieres operar con '" + op + "', solo se vale '=`, marbaa' bruja.";
				yyerror(error_msg.c_str());
			// Asignacion de estructuras
			} else if (attribute->type->category == STRUCT && $3->category == "Estructura" && op == "=") {
				queue<pair<vector<string>, ASTNode*> > queue_structs;
				queue_structs.push({{string($1), left_type}, $3});
				while(!queue_structs.empty()) {
					auto data = queue_structs.front();
					queue_structs.pop();

					string struct_name = data.first[0];
					string struct_type = data.first[1];
					ASTNode* struct_elements_node = data.second;

					Attributes* type_attr = symbolTable.search_symbol(struct_type);

					if (type_attr->category != STRUCT || struct_elements_node->category != "Estructura"){
						FLAG_ERROR = TYPE_ERROR;
						string error_msg = "\"" + struct_name + "\" de tipo '" + struct_type + 
							"' y le quieres meter un 'arroz_con_mango', marbaa' bruja.";
						yyerror(error_msg.c_str());
					} else {
						int size_struct = type_attr->info.size();

						// Buscar atributo de la estructura
						Attributes* struct_attr = symbolTable.search_symbol(struct_name);

						set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Elemento_String", "Atributo_Estructura", "Estructura"};
						vector<ASTNode*> struct_elements;
						collect_nodes_by_categories(struct_elements_node, categories, struct_elements);
						// Remover el primer elemento del vector de elementos. Se captura el mismo nodo "Estructura".
						struct_elements.erase(struct_elements.begin());

						int count_elems = struct_elements.size();

						if (size_struct == 0 || count_elems == 0) {
							FLAG_ERROR = EMPTY_STRUCT;
							yyerror(struct_name.c_str());
						} else if (count_elems > size_struct) {
							FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
							string error_msg = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(size_struct) + "' cositas.";
							yyerror(error_msg.c_str());
						} else if (count_elems < size_struct) {
							FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
							string error_msg = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(count_elems) + "' de '" + to_string(size_struct) + "'.";
							yyerror(error_msg.c_str());
						} else {
							for (int i = 0; i < count_elems; i++) {
								const auto& field = type_attr->info[i];
								string full_field = get<string>(field.first);
								size_t dot_pos = full_field.find('.');
								if (dot_pos == string::npos) continue; // No es un campo válido

								string field_type = field.second->type->symbol_name;

								string attr_name = full_field.substr(dot_pos + 1);
								string new_field_name = struct_name + "." + attr_name;

								Attributes* new_attr = symbolTable.search_symbol(new_field_name);
								
								ASTNode* elem = struct_elements[i];

								if (elem->category == "Estructura") {
									queue_structs.push({{new_field_name, field_type}, elem});
									continue; // Procesar subestructura
								}

								if (field_type != elem->type && (field_type != "manguangua" || elem->type != "manguita")) {
									FLAG_ERROR = TYPE_ERROR;
									string error_msg = "\"" + new_field_name + "\" de tipo '" + field_type + 
										"' y le quieres meter un '" + elem->type + "', marbaa' bruja.";
									yyerror(error_msg.c_str());
									new_attr->value = nullptr;
								} else {
									if (elem->type == "mango") {
										new_attr->value = elem->ivalue;
									} else if (elem->type == "manguita") {
										new_attr->value = elem->fvalue;
									} else if (elem->type == "manguangua") {
										new_attr->value = elem->dvalue;
									} else if (elem->type == "negro") {
										new_attr->value = elem->cvalue;
									} else if (elem->type == "higuerote") {
										new_attr->value = elem->svalue;
									} else if (elem->type == "tas_claro") {
										new_attr->value = elem->bvalue;
										if (!new_attr->info.empty()) new_attr->info[0].first = (elem->bvalue ? "Sisa" : "Nolsa");
										else new_attr->info.push_back({(elem->bvalue ? "Sisa" : "Nolsa"), nullptr});
									} else if (elem->type == "pointer"){
										/* POR IMPLEMENTAR */
										//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
										new_attr->value = nullptr;
									} else {
										FLAG_ERROR = INTERNAL;
										string error_msg = "TIPO DESCONOCIDO: '" + elem->type + "'.";
										yyerror(error_msg.c_str());
										new_attr->value = nullptr;
									}
								}
								
							}
						}
					}
				}
			} else if (attribute->type->category == STRUCT && $3->category == "Estructura" && op != "=") {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "\"" + id + "\" de tipo '" + attribute->type->symbol_name + 
					"' y quieres operar con '" + op + "', solo se vale '=`, marbaa' bruja.";
				yyerror(error_msg.c_str());
			
			// Asignacion normal de variables
			} else {
				if (left_type != right_type && (left_type != "manguangua" || right_type != "manguita")) {
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "\"" + id + "\" de tipo '" + left_type + 
						"' y le quieres meter un tipo '" + right_type + "', marbaa' bruja.";
					yyerror(error_msg.c_str());
				} else {
					if (op != "=" && holds_alternative<nullptr_t>(attribute->value) && attribute->category != PARAMETERS) {
						FLAG_ERROR = NON_VALUE;
						yyerror($1);
					} else if ($3->category != "Llamada_Funcion") {
						new_node->show_value = !holds_alternative<nullptr_t>(attribute->value);
						if (left_type == "mango") {
							if (new_node->show_value) new_node->ivalue = get<int>(attribute->value);
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
							if (new_node->show_value) new_node->fvalue = get<float>(attribute->value);
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
							if (new_node->show_value) new_node->dvalue = get<double>(attribute->value);
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
							if (new_node->show_value) new_node->cvalue = get<char>(attribute->value);
							attribute->value = $3->cvalue;
							$2->cvalue = $3->cvalue;
						} else if (left_type == "higuerote") {
							if (new_node->show_value) new_node->svalue = get<string>(attribute->value);
							if (op == "=") {
								attribute->value = $3->svalue;
								attribute->info[0].first = static_cast<int>($3->svalue.size()); // Actualizar el tamaño de la cadena
								$2->svalue = $3->svalue;
							} else if (op == "+=") {
								string old_value = get<string>(attribute->value);
								string new_value = old_value + $3->svalue;
								attribute->value = new_value;
								attribute->info[0].first = static_cast<int>(new_value.size());
								$2->svalue = new_value;
							} else {
								FLAG_ERROR = INVALID_OPERATION;
								string error_msg = "\"" + op + "\"" + " entre '" + left_type + "', que vaina es loca?";
								yyerror(error_msg.c_str());
							}
							
						} else if (left_type == "tas_claro" && op == "="){
							if (new_node->show_value) new_node->bvalue = get<bool>(attribute->value);
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
		string expr_to_assign = $3->temp;
		
		if ($2->kind == "+=") op_tac = " + ";
		else if ($2->kind == "-=") op_tac = " - ";
		else if ($2->kind == "*=") op_tac = " * ";
		else if ($2->kind == "=") op_tac = " := ";
		// Agregar instrucciones de la expresion
		concat_TAC($$, $3);
		// Generar el TAC para asignacion
		if (op_tac != " := ") {
			$$->tac.push_back(string($1) + " := " + string($1) + op_tac + expr_to_assign);
		} else {
			$$->tac.push_back(string($1) + " := " + expr_to_assign);
		}

		$$->children.push_back(new_node);
		$$->children.push_back($3);
	}    
	| T_ID lista_dimensiones operadores_asignacion expresion {
		ASTNode* new_node = makeASTNode($1, "Elemento_Array");
		
		string left_type = "Desconocido_l";
		string right_type = $4->type;

		string index_type = $2->children[0]->type;
		int index = 0;
		int size_array = 0;

		if (index_type != "mango") {
			FLAG_ERROR = INT_INDEX_ARRAY;
			yyerror(index_type.c_str());
		} else {
			index = $2->children[0]->ivalue;
		}
		
		Attributes* array_attr = symbolTable.search_symbol($1);
		if (array_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else if (array_attr->category != ARRAY && array_attr->type->symbol_name != "higuerote") {
			FLAG_ERROR = INVALID_ACCESS;
			yyerror($1);
		// En caso de higuerote
		} else if (array_attr->type->symbol_name == "higuerote" && array_attr->info[0].second == nullptr) {
			left_type = array_attr->type->symbol_name;
			new_node->name = string($1) + "[" + to_string(index) + "]";
			new_node->category = "Elemento_String";
			size_array = get<int>(array_attr->info[0].first);
			if (index < 0 || index >= size_array) {
				FLAG_ERROR = SEGMENTATION_FAULT;
				yyerror(to_string(index).c_str());
			} else {
				if (right_type != "negro"){
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "\"" + string($1) + "[" + to_string(index) + "]\" de tipo 'negro' y le quieres meter un tipo '" 
						+ right_type + "', marbaa' bruja.";
					yyerror(error_msg.c_str());
				} else {
					new_node->type = right_type;
					string new_string = get<string>(array_attr->value);
					if ($4->cvalue == '\0') {
						new_string.erase(index, 1); // Eliminar el carácter en la posición index
					} else {
						new_string[index] = $4->cvalue;
					}
					array_attr->value = new_string;
					array_attr->info[0].first = static_cast<int>(new_string.size());
				}
			}
		// En caso de array
		} else {
			// Validar los indices de acceso a nivel multidimensional.
			string final_access = string($1);
			Attributes* current_access = nullptr;
			for(auto index_node : $2->children) {
				current_access = symbolTable.search_symbol(final_access);
				if (current_access != nullptr) {
					index_type = index_node->type;
					index = 0;
					// Verificar tipo de indice.
					if (index_type != "mango") {
						FLAG_ERROR = INT_INDEX_ARRAY;
						yyerror(index_type.c_str());
					} else index = index_node->ivalue;
					
					// Verificar rango de indice.
					size_array = get<int>(current_access->value);
					if (index < 0 || index >= size_array) {
						FLAG_ERROR = SEGMENTATION_FAULT;
						yyerror(to_string(index).c_str());
					}

					// Actualizar acceso.
					final_access += "[" + to_string(index) + "]";
				}
			}

			// Buscar el atributo del elemento del array.
			Attributes* elem_attr = symbolTable.search_symbol(final_access);
			if (elem_attr != nullptr) {
				// Actualizacion general de AST
				left_type = elem_attr->type->symbol_name;
				new_node->name = elem_attr->symbol_name;
				new_node->type = left_type;
				if (elem_attr->category == ARRAY) new_node->category = "Array";	

				// Verificacion de tipos.
				if (left_type != right_type && (left_type != "manguangua" || right_type != "manguita")) {
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "\"" + final_access + "\" de tipo '" + left_type + 
						"' y le quieres meter un tipo '" + right_type + "', marbaa' bruja.";
					yyerror(error_msg.c_str());
				} else {
					if (elem_attr->declare == CONSTANT || elem_attr->declare == POINTER_C) {
						FLAG_ERROR = MODIFY_CONST;
						yyerror(final_access.c_str());
					} else {
						// Asignacion de valores para el elemento del array. CASO ID
						if (elem_attr->category == ID) {
							string op = $3->kind;
							if (op != "=" && holds_alternative<nullptr_t>(elem_attr->value)) {
								FLAG_ERROR = NON_VALUE;
								yyerror(final_access.c_str());
							} else if ($4->category != "Llamada_Funcion") {
								new_node->show_value = !holds_alternative<nullptr_t>(elem_attr->value);
								if (left_type == "mango") {
									int r_ivalue = $4->ivalue;
									if (op == "=") elem_attr->value = r_ivalue;
									else {
										int l_ivalue = get<int>(elem_attr->value);
										new_node->ivalue = l_ivalue; // Guardar el valor antes de modificarlo
										if (op == "+=") elem_attr->value = l_ivalue + r_ivalue;
										if (op == "-=") elem_attr->value = l_ivalue - r_ivalue;
										if (op == "*=") elem_attr->value = l_ivalue * r_ivalue;
									}
									$3->ivalue = get<int>(elem_attr->value);
								} else if (left_type == "manguita") {
									float r_fvalue = $4->fvalue;
									if (op == "=") elem_attr->value = r_fvalue;
									else {
										float l_fvalue = get<float>(elem_attr->value);
										new_node->fvalue = l_fvalue; // Guardar el valor antes de modificarlo
										if (op == "+=") elem_attr->value = l_fvalue + r_fvalue;
										if (op == "-=") elem_attr->value = l_fvalue - r_fvalue;
										if (op == "*=") elem_attr->value = l_fvalue * r_fvalue;
									}
									$3->fvalue = get<float>(elem_attr->value);
								} else if (left_type == "manguangua") {
									double r_dvalue = 0.0;
									if (right_type == "manguita") r_dvalue = $4->fvalue;
									else r_dvalue = $4->dvalue;

									if (op == "=") elem_attr->value = r_dvalue;
									else {
										double l_dvalue = get<double>(elem_attr->value);
										new_node->dvalue = l_dvalue; // Guardar el valor antes de modificarlo
										if (op == "+=") elem_attr->value = l_dvalue + r_dvalue;
										if (op == "-=") elem_attr->value = l_dvalue - r_dvalue;
										if (op == "*=") elem_attr->value = l_dvalue * r_dvalue;
									}
									$3->dvalue = get<double>(elem_attr->value);
								} else if (left_type == "negro" && op == "=") {
									elem_attr->value = $4->cvalue;
									$3->cvalue = $4->cvalue;
								} else if (left_type == "higuerote" && op == "=") {
									elem_attr->value = $4->svalue;
									elem_attr->info[0].first = static_cast<int>($4->svalue.size());
									$3->svalue = $4->svalue;
								} else if (left_type == "tas_claro" && op == "=") {
									elem_attr->value = $4->bvalue;
									$3->bvalue = $4->bvalue;
									if (!elem_attr->info.empty()) elem_attr->info[0].first = ($4->bvalue ? "Sisa" : "Nolsa");
									else elem_attr->info.push_back({($4->bvalue ? "Sisa" : "Nolsa"), nullptr});
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
						} else if (elem_attr->category == ARRAY) { // CASO ARRAY
							if ($4->category != "Array") {
								FLAG_ERROR = TYPE_ERROR;
								string error_msg = "\"" + final_access + "\" de tipo '" + left_type +
									"[]' y le quieres meter un elemento de tipo '" + right_type + "', marbaa' bruja.";
								yyerror(error_msg.c_str());
							} else {
								int size_array, current_dim = 0;
								int total_dim = 1;
								Attributes* size = elem_attr;

								int lineal_total_size = get<int>(size->value);
								while(true) {
									size = symbolTable.search_symbol(get<string>(size->info[0].first));
									if (size->category == ARRAY) {
										lineal_total_size *= get<int>(size->value);
										total_dim++;
									} else break;
								}

								// Extraer los elementos a asignar en el array.
								int count_elems = 0;
								int total_elems = 0;
								set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Elemento_String", "Atributo_Estructura"};
								vector<ASTNode*> array_elements;
								collect_nodes_by_categories($4, categories, array_elements);
								total_elems = array_elements.size(); // Totalidad lineal de los elementos a la derecha.

								// Verificar cantidad de elementos totales a declarar.
								if (lineal_total_size > total_elems && lineal_total_size > 0) {
									FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
									string error_msg = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(total_elems) + "' de '" + to_string(lineal_total_size) + "'.";
									yyerror(error_msg.c_str());
								} else if (lineal_total_size < total_elems && lineal_total_size > 0) {
									FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
									string error_msg = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(lineal_total_size) + "' cositas.";
									yyerror(error_msg.c_str());
								} else if (lineal_total_size > 0 && total_elems > 0) {
									// Creacion de elementos de un array en formato recursivo.
									string father = "";
									queue<string> fathers;
									fathers.push(final_access);
									
									while (!fathers.empty()){
										father = fathers.front();
										fathers.pop();
										
										// Determinar la dimension actual segun la cantidad de '[' dentro de father.
										current_dim = count(father.begin(), father.end(), '[');
										
										// Actualizacion de categoria, creacion de elementos tipo array o valor.
										Category current_cat = current_dim < total_dim ? ARRAY : ID;
										
										Attributes* array = symbolTable.search_symbol(father);
										size_array = get<int>(array->value);
										string elem_name = "";
										for (int i = 0; i < size_array; i++) {
											elem_name = father + "[" + to_string(i) + "]";

											Attributes* elem = symbolTable.search_symbol(elem_name);
											if (elem == nullptr) {
												FLAG_ERROR = NON_DEF_VAR;
												yyerror(elem_name.c_str());
											} else {
												// Arreglo multidimension
												if (current_cat == ARRAY) fathers.push(elem_name);
												
												// Valor por defecto en caso de ser categoria ID
												if (current_cat == ID){
													cout << "check assig: " << elem_name << endl;
													ASTNode* elem_node = array_elements[count_elems++];
													if (left_type != elem_node->type && (left_type != "manguangua" || elem_node->type != "manguita")) {
														FLAG_ERROR = TYPE_ERROR;
														string error_msg = "\"" + elem_name + "\" de tipo '" + left_type + 
															"[]' y le quieres meter un '" + elem_node->type + "[]', marbaa' bruja.";
														yyerror(error_msg.c_str());
														elem->value = nullptr;
													} else {
														if (elem_node->type == "mango") elem->value = elem_node->ivalue;
														else if (elem_node->type == "manguita") elem->value = elem_node->fvalue;
														else if (elem_node->type == "manguangua") elem->value = elem_node->dvalue;
														else if (elem_node->type == "negro") elem->value = elem_node->cvalue;
														else if (elem_node->type == "higuerote") {
															elem->value = elem_node->svalue;
															elem->info.push_back({static_cast<int>(elem_node->svalue.size()), nullptr});
														} else if (elem_node->type == "tas_claro") {
															elem->value = elem_node->bvalue;
															if (!elem->info.empty()) elem->info[0].first = (elem_node->bvalue ? "Sisa" : "Nolsa");
															else elem->info.push_back({(elem_node->bvalue ? "Sisa" : "Nolsa"), nullptr});
														} else if (elem_node->type == "pointer"){
															/* POR IMPLEMENTAR */
															//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
															elem->value = nullptr;
														} else {
															FLAG_ERROR = INTERNAL;
															string error_msg = "TIPO DESCONOCIDO: Asignando 'nullptr' a: '" + father + "'.";
															yyerror(error_msg.c_str());
															elem->value = nullptr;
														}
													}
												}
											}
										}
									}
								}
							}
						}
					} 
				}
			}
		}
		$$ = $3;
		
		//Agregar TAC de indexacion
		if(array_attr != nullptr){
			string op_tac = "";
			if ($3->kind == "+=") op_tac = " + ";
			else if ($3->kind == "-=") op_tac = " - ";
			else if ($3->kind == "*=") op_tac = " * ";
			else if ($3->kind == "=") op_tac = " := ";
			// Agregar instrucciones de la expresion
			string temp_access = "";
			for (auto& child : $2->children) {
				concat_TAC($$, child);
				temp_access = labelGen.newTemp();
				$$->tac.push_back(temp_access + " := " + child->temp + " * " + to_string(strToSizeType(left_type)));
			}
			concat_TAC($$, $4);
			
			if(op_tac == " := "){
				$$->tac.push_back(string($1) + "[" + temp_access + "]" + op_tac + $4->temp);
			}else{
				string temp_addr = labelGen.newTemp(),
					temp = labelGen.newTemp();
				$$->tac.push_back(temp_addr + " := " + string($1) + "[" + temp_access + "]");
				$$->tac.push_back(temp + " := " + temp_addr + op_tac + $3->temp);
				$$->tac.push_back(string($1) + "[" + temp_access + "]" + " := " + temp);
			}
		}
		$$->children.push_back(new_node);
		$$->children.push_back($4);
	}
	| T_ID T_PUNTO acceso_struct operadores_asignacion expresion { // Structs/Unions
		string field_name = string($1) + "." + $3->name;
		
		ASTNode* new_node = makeASTNode(field_name, "Atributo_Estructura");
		
		Attributes* struct_attr = symbolTable.search_symbol($1);
		string type_struct = "Desconocido_s";
		string type_field = "Desconocido_f";
		string right_type = $5->type;
		string op = $4->kind;
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

			Attributes* field_attr = symbolTable.search_symbol(field_name);

			if (field_attr == nullptr) {
				FLAG_ERROR = NON_DEF_ATTR;
				yyerror(field_name.c_str());
			} else {
				type_field = field_attr->type->symbol_name;
				new_node->type = type_field;
				Category field_category = field_attr->type->category;
				// Atributo de tipo struct/union
				if (field_category == STRUCT && $5->category == "Estructura" && op != "=") {
					FLAG_ERROR = TYPE_ERROR;
					string error_msg = "\"" + field_name + "\" de tipo '" + type_field + 
						"' y quieres operar con '" + op + "', solo se vale '=`, marbaa' bruja.";
					yyerror(error_msg.c_str()); 

				} else if (field_category == STRUCT && $5->category == "Estructura" && op == "=") {
					new_node->category = "Estructura";

					queue<pair<vector<string>, ASTNode*> > queue_structs;
					queue_structs.push({{field_name, type_field}, $5});
					while(!queue_structs.empty()) {
						auto data = queue_structs.front();
						queue_structs.pop();

						string struct_name = data.first[0];
						string struct_type = data.first[1];
						ASTNode* struct_elements_node = data.second;

						Attributes* type_attr = symbolTable.search_symbol(struct_type);

						if (type_attr->category != STRUCT || struct_elements_node->category != "Estructura"){
							FLAG_ERROR = TYPE_ERROR;
							string error_msg = "\"" + struct_name + "\" de tipo '" + struct_type + 
								"' y le quieres meter un 'arroz_con_mango', marbaa' bruja.";
							yyerror(error_msg.c_str());
						} else {
							int size_struct = type_attr->info.size();

							// Buscar atributo de la estructura
							Attributes* struct_attr = symbolTable.search_symbol(struct_name);

							set<string> categories = {"Identificador", "Numérico", "Caracter", "Cadena de Caracteres", "Bool", "Elemento_Array", "Elemento_String", "Atributo_Estructura", "Estructura"};
							vector<ASTNode*> struct_elements;
							collect_nodes_by_categories(struct_elements_node, categories, struct_elements);
							// Remover el primer elemento del vector de elementos. Se captura el mismo nodo "Estructura".
							struct_elements.erase(struct_elements.begin());

							int count_elems = struct_elements.size();

							if (size_struct == 0 || count_elems == 0) {
								FLAG_ERROR = EMPTY_STRUCT;
								yyerror(struct_name.c_str());
							} else if (count_elems > size_struct) {
								FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
								string error_msg = "Ay vale! Te gusta meterte más cosas verdad?. Sólo te caben '" + to_string(size_struct) + "' cositas.";
								yyerror(error_msg.c_str());
							} else if (count_elems < size_struct) {
								FLAG_ERROR = ARRAY_LITERAL_SIZE_MISMATCH;
								string error_msg = "Dale que te caben más! Te faltan cositas que meterte. Sólo llevas '" + to_string(count_elems) + "' de '" + to_string(size_struct) + "'.";
								yyerror(error_msg.c_str());
							} else {
								for (int i = 0; i < count_elems; i++) {
									const auto& field = type_attr->info[i];
									string full_field = get<string>(field.first);
									size_t dot_pos = full_field.find('.');
									if (dot_pos == string::npos) continue; // No es un campo válido

									string field_type = field.second->type->symbol_name;

									string attr_name = full_field.substr(dot_pos + 1);
									string new_field_name = struct_name + "." + attr_name;

									Attributes* new_attr = symbolTable.search_symbol(new_field_name);
									
									ASTNode* elem = struct_elements[i];

									if (elem->category == "Estructura") {
										queue_structs.push({{new_field_name, field_type}, elem});
										continue; // Procesar subestructura
									}

									if (field_type != elem->type && (field_type != "manguangua" || elem->type != "manguita")) {
										FLAG_ERROR = TYPE_ERROR;
										string error_msg = "\"" + new_field_name + "\" de tipo '" + field_type + 
											"' y le quieres meter un '" + elem->type + "', marbaa' bruja.";
										yyerror(error_msg.c_str());
										new_attr->value = nullptr;
									} else {
										if (elem->type == "mango") {
											new_attr->value = elem->ivalue;
										} else if (elem->type == "manguita") {
											new_attr->value = elem->fvalue;
										} else if (elem->type == "manguangua") {
											new_attr->value = elem->dvalue;
										} else if (elem->type == "negro") {
											new_attr->value = elem->cvalue;
										} else if (elem->type == "higuerote") {
											new_attr->value = elem->svalue;
										} else if (elem->type == "tas_claro") {
											new_attr->value = elem->bvalue;
											if (!new_attr->info.empty()) new_attr->info[0].first = (elem->bvalue ? "Sisa" : "Nolsa");
											else new_attr->info.push_back({(elem->bvalue ? "Sisa" : "Nolsa"), nullptr});
										} else if (elem->type == "pointer"){
											/* POR IMPLEMENTAR */
											//cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
											new_attr->value = nullptr;
										} else {
											FLAG_ERROR = INTERNAL;
											string error_msg = "TIPO DESCONOCIDO: '" + elem->type + "'.";
											yyerror(error_msg.c_str());
											new_attr->value = nullptr;
										}
									}
									
								}
							}
						}
					}
				} else {
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

						if (op != "=" && holds_alternative<nullptr_t>(field_attr->value)) {
							FLAG_ERROR = NON_VALUE;
							yyerror(field_name.c_str());
						} else if ($5->category != "Llamada_Funcion") {
							new_node->show_value = !holds_alternative<nullptr_t>(field_attr->value);
							if (type_field == "mango") {
								if (new_node->show_value) new_node->ivalue = get<int>(field_attr->value);
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
								if (new_node->show_value) new_node->fvalue = get<float>(field_attr->value);
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
								if (new_node->show_value) new_node->dvalue = get<double>(field_attr->value);
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
								if (new_node->show_value) new_node->cvalue = get<char>(field_attr->value);
								field_attr->value = $5->cvalue;
								$4->cvalue = $5->cvalue;
							} else if (type_field == "higuerote" && op == "=") {
								if (new_node->show_value) new_node->svalue = get<string>(field_attr->value);
								field_attr->value = $5->svalue;
								$4->svalue = $5->svalue;
							} else if (type_field == "tas_claro" && op == "="){
								if (new_node->show_value) new_node->bvalue = get<bool>(field_attr->value);
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
		}
		$$ = $4;
		if(struct_attr != nullptr){// Agregar instrucciones TAC para la asignación de atributos
			string op_tac = "";
			if ($4->kind == "+=") op_tac = " + ";
			else if ($4->kind == "-=") op_tac = " - ";
			else if ($4->kind == "*=") op_tac = " * ";
			else if ($4->kind == "=") op_tac = " := ";
			// Agregar instrucciones de la expresion
			concat_TAC($$, $5);
			// Generar el TAC para asignacion
			string temp_base = labelGen.newTemp(),
				temp_attr = labelGen.newTemp(string($1) + "_" + $3->name),
				attr = field_name;
			$$->tac.push_back(temp_base + " := " + "&" + string($1));
			
			if(struct_attr->type->category == STRUCT){
				$$->tac.push_back(temp_attr + " := " + temp_base + " + " + to_string(accumulateSizeType(struct_attr->info, attr)));
			}else{// UNION
				$$->tac.push_back(temp_attr + " := " + temp_base); 
			}
			if(op_tac == " := "){
				$$->tac.push_back("*" + temp_attr + op_tac + $5->temp);
			}else{
				string temp_addr = labelGen.newTemp(),
					temp = labelGen.newTemp();
				$$->tac.push_back(temp_addr + " := *"+ temp_attr);
				$$->tac.push_back(temp + " := " + temp_addr + op_tac + $5->temp);
				$$->tac.push_back("*" + temp_attr + " := " + temp);
			}
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
			string type = attr->type->symbol_name;
			new_node->type = type;
			// Actualizacion de categoria para lado derecho de asignacion. Generacion de arbol AST.
			if (attr->category == STRUCT || attr->category == UNION) {
				new_node->category = "Estructura";
				// No se construye el AST para Struct dado que la logica de asignacion es diferente.
			} else if (attr->category == ARRAY) {
				new_node->category = "Array";
				buildAST_by_array(new_node, attr->info, symbolTable);
			} else if (!holds_alternative<nullptr_t>(attr->value)) {
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
			if ($1.cval == '\0') {
				new_node->temp = "'\\0'";
			} else {
				new_node->temp = "'"s + $1.cval + "'";
			}
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
	| T_IZQCORCHE secuencia T_DERCORCHE { // Arreglos
		$$ = makeASTNode("Literal", "Array");
		$$->children.push_back($2);
		concat_TAC($$, $2);
	}
	| T_IZQLLAVE secuencia T_DERLLAVE { // Diccionario de atributos
		$$ = makeASTNode("Literal", "Estructura");
		$$->children.push_back($2);
	}
	| T_ID lista_dimensiones { // Acceso a elementos de un array
		ASTNode* new_node = makeASTNode($1, "Elemento_Array");
		
		string left_type = "Desconocido_l";
		string index_type = $2->children[0]->type;
		int index = 0;
		int size_array = 0;

		if (index_type != "mango") {
			FLAG_ERROR = INT_INDEX_ARRAY;
			yyerror(index_type.c_str());
		} else {
			index = $2->children[0]->ivalue;
		}

		Attributes* array_attr = symbolTable.search_symbol($1);
		if (array_attr == nullptr) {
			FLAG_ERROR = NON_DEF_VAR;
			yyerror($1);
		} else if (array_attr->category != ARRAY && array_attr->type->symbol_name != "higuerote") {
			FLAG_ERROR = INVALID_ACCESS;
			yyerror($1);
		// En caso de higuerote
		} else if (array_attr->type->symbol_name == "higuerote" && array_attr->info[0].second == nullptr) {
			left_type = array_attr->type->symbol_name;
			new_node->name = string($1) + "[" + to_string(index) + "]";
			new_node->category = "Elemento_String";
			size_array = get<int>(array_attr->info[0].first);
			if ((index < 0 || index >= size_array) && array_attr->category != PARAMETERS) {
				FLAG_ERROR = SEGMENTATION_FAULT;
				yyerror(to_string(index).c_str());
			} else {
				left_type = "negro";
				if (array_attr->category != PARAMETERS)
					new_node->cvalue = get<string>(array_attr->value)[index];
			}
		// En caso de array
		} else {
			// Validar los indices de acceso a nivel multidimensional.
			string final_access = string($1);
			Attributes* current_access = nullptr;
			for(auto index_node : $2->children) {
				current_access = symbolTable.search_symbol(final_access);
				if (current_access != nullptr) {
					index_type = index_node->type;
					index = 0;
					// Verificar tipo de indice.
					if (index_type != "mango") {
						FLAG_ERROR = INT_INDEX_ARRAY;
						yyerror(index_type.c_str());
					} else index = index_node->ivalue;
					
					// Verificar rango de indice.
					size_array = get<int>(current_access->value);
					if (index < 0 || index >= size_array) {
						FLAG_ERROR = SEGMENTATION_FAULT;
						yyerror(to_string(index).c_str());
					}

					// Actualizar acceso.
					final_access += "[" + to_string(index) + "]";
				}
			}

			// Buscar el atributo del elemento del array.
			Attributes* elem_attr = symbolTable.search_symbol(final_access);
			if (elem_attr != nullptr) {
				// Actualizacion general de AST
				left_type = elem_attr->type->symbol_name;
				new_node->name = elem_attr->symbol_name;

				if (elem_attr->category == ARRAY) {
					new_node->category = "Array";
					if (elem_attr->info.empty()) {
						FLAG_ERROR = EMPTY_STRUCT;
						yyerror(final_access.c_str());
					} else {
						buildAST_by_array(new_node, elem_attr->info, symbolTable);
					}
				} else {
					if (holds_alternative<nullptr_t>(elem_attr->value)) {
						FLAG_ERROR = NON_VALUE;
						yyerror(final_access.c_str());
					} else if (left_type == "mango") new_node->ivalue = get<int>(elem_attr->value);
					else if (left_type == "manguita") new_node->fvalue = get<float>(elem_attr->value);
					else if (left_type == "manguangua") new_node->dvalue = get<double>(elem_attr->value);
					else if (left_type == "negro") new_node->cvalue = get<char>(elem_attr->value);
					else if (left_type == "higuerote") new_node->svalue = get<string>(elem_attr->value);
					else if (left_type == "tas_claro") {
						new_node->bvalue = get<bool>(elem_attr->value);
						if (!elem_attr->info.empty()) new_node->kind = (new_node->bvalue ? "Sisa" : "Nolsa");
					} else if (left_type == "pointer") {
						/* POR IMPLEMENTAR */
					} else {
						FLAG_ERROR = INTERNAL;
						yyerror("ERROR INTERNO: Lexer proporciona un tipo invalido.");
					}
				}
			}
		}
		// Actualizar el tipo del nodo
		new_node->type = left_type;
		$$ = new_node;

		//Agregar TAC de indexacion
		if(array_attr != nullptr){
			string temp_access = labelGen.newTemp(),
				temp = labelGen.newTemp();
			$$->tac.push_back(temp_access + " := " + $2->temp + " * " + to_string(strToSizeType(left_type)));
			$$->tac.push_back(temp + " := " + string($1) + "[" + temp_access + "]");
			$$->temp = temp;
		}
	}
	| T_ID T_PUNTO acceso_struct { // Acceso a atributos de una struct/variant
		string field_name = string($1) + "." + $3->name;
		string type_field = "Desconocido_s";
		Category category_field = UNKNOWN;
		ASTNode* new_node = makeASTNode(field_name, "Atributo_Estructura");
	
		Attributes* field_attr = symbolTable.search_symbol(field_name);
		if (field_attr == nullptr) {
			FLAG_ERROR = NON_DEF_ATTR;
			yyerror(field_name.c_str());
		} else if (field_attr->type == nullptr) {
			FLAG_ERROR = INTERNAL;
			yyerror("ERROR INTERNO: Atributo sin tipo definido.");
		} else {
			type_field = field_attr->type->symbol_name;
			new_node->type = type_field;
			category_field = field_attr->type->category;
			if (category_field == STRUCT) {
				new_node->category = "Estructura";
				if (field_attr->info.empty()) {
					FLAG_ERROR = EMPTY_STRUCT;
					yyerror(field_name.c_str());
				} else {
					buildAST_by_struct(new_node, field_attr->info, symbolTable);
				}
			} else {
				if (holds_alternative<nullptr_t>(field_attr->value)) {
					FLAG_ERROR = NON_VALUE;
					yyerror(field_name.c_str());
				} else if (type_field == "mango") {
					new_node->ivalue = get<int>(field_attr->value);
				} else if (type_field == "manguita") {
					new_node->fvalue = get<float>(field_attr->value);
				} else if (type_field == "manguangua") {
					new_node->dvalue = get<double>(field_attr->value);
				} else if (type_field == "negro") {
					new_node->cvalue = get<char>(field_attr->value);
				} else if (type_field == "higuerote") {
					new_node->svalue = get<string>(field_attr->value);
				} else if (type_field == "tas_claro") {
					new_node->bvalue = get<bool>(field_attr->value);
					if (!field_attr->info.empty()) new_node->kind = (new_node->bvalue ? "Sisa" : "Nolsa");
				} else if (type_field == "pointer") {
					/* POR IMPLEMENTAR */
				} else {
					FLAG_ERROR = INTERNAL;
					yyerror("ERROR INTERNO: Lexer proporciona un tipo invalido.");
				}
			}
		}
		$$ = new_node;
	} 
	| T_IZQPAREN expresion T_DERPAREN { $$ = $2; } // Expresion parentizada.
	| T_NELSON expresion { 
		string type = $2->type;
		$$ = makeASTNode("nelson", "Operación", "tas_claro", "Booleana");
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
					if(var_attr->declare == CONSTANT || var_attr->declare == POINTER_C) {
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
		$$->temp = $1->temp;
		if ($2->name == "--"){
			$$->tac.push_back($1->temp + " := " + $1->temp + " - 1");
		} else {
			$$->tac.push_back($1->temp + " := " + $1->temp + " + 1");
		}
	}
	| expresion T_FLECHA expresion { $$ = solver_operation($1, "->", $3, yylineno, yylloc.first_column); }
	| expresion T_OPSUMA expresion {
		$$ = solver_operation($1, "+", $3, yylineno, yylloc.first_column); 
		string temp = labelGen.newTemp();
		concat_TAC($$, $1, $3);
		if ($$->type == "higuerote") {
			$$->tac.push_back("param " +  $1->temp);
			$$->tac.push_back("param " +  $3->temp);
			$$->tac.push_back(temp + " := call concat, 2");
		} else{
			$$->tac.push_back(temp + " := " + $1->temp + " + " + $3->temp);
		}
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
		concat_TAC($$, $1, $3);
		$$->temp = $1->temp + " == " + $3->temp; // Asignar el resultado de la comparación
	}
	| expresion T_OPDIFERENTE expresion {
		$$ = solver_operation($1, "nie", $3, yylineno, yylloc.first_column);
		concat_TAC($$, $1, $3);
		$$->temp = $1->temp + " != " + $3->temp; // Asignar el resultado de la comparación
	}
	| expresion T_OPMAYOR expresion { 
		$$ = solver_operation($1, "mayol", $3, yylineno, yylloc.first_column);
		concat_TAC($$, $1, $3);
		$$->temp = $1->temp + " > " + $3->temp; // Asignar el resultado de la comparación
	}
	| expresion T_OPMAYORIGUAL expresion {
		$$ = solver_operation($1, "lidel", $3, yylineno, yylloc.first_column);
		concat_TAC($$, $1, $3);
		$$->temp = $1->temp + " >= " + $3->temp; // Asignar el resultado de la comparación
	}
	| expresion T_OPMENOR expresion {
		$$ = solver_operation($1, "menol", $3, yylineno, yylloc.first_column);
		concat_TAC($$, $1, $3);
		$$->temp = $1->temp + " < " + $3->temp; // Asignar el resultado de la comparación
	}
	| expresion T_OPMENORIGUAL expresion {
		$$ = solver_operation($1, "peluche", $3, yylineno, yylloc.first_column);
		concat_TAC($$, $1, $3);
		$$->temp = $1->temp + " <= " + $3->temp; // Asignar el resultado de la comparación
	}
	| expresion T_YUNTA expresion { 
		$$ = solver_operation($1, "yunta", $3, yylineno, yylloc.first_column);
	}
	| expresion T_OSEA expresion { 
		$$ = solver_operation($1, "o_sea", $3, yylineno, yylloc.first_column);
	}
	| T_HABLAME T_IZQPAREN expresion T_DERPAREN { // Inputs
		$$ = makeASTNode("hablame", "input", "higuerote");
		if ($3->type != "higuerote") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "el tipo '" + $3->type + "' en vez de 'higuerote', hablas con higuerotes no vainas raras.";
			yyerror(error_msg.c_str());
		} else {
			$$->svalue = "0"; // Valor por defecto para el input
			$$->children.push_back($3);
			// Generar TAC para la entrada
			concat_TAC($$, $3);
			string temp = labelGen.newTemp();
			$$->tac.push_back("param "+ $3->temp);
			$$->tac.push_back(temp + " := call read, 1");
			$$->temp = temp;
		}
	}
	| llamada_funcion
	| casting
	;

acceso_struct:
	T_ID {
		$$ = makeASTNode($1, "Acceso_Estructura");
	}
	| acceso_struct T_PUNTO T_ID { 
		$$ = makeASTNode($1->name + "." + $3, "Acceso_Estructura");
	}
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
		concat_TAC($$, $1, $3);
	}

condicion:
	guardia_siesasi alternativa { 
		$$ = makeASTNode("Condición");
		$$->children.push_back($1);

		ASTNode* siesasi_instr = $1->children.size() > 1 ? $1->children[1] : nullptr;
		
		string final_label;
		if ($2) final_label = labelGen.newLabel();
		
		$1->children[0]->children[0]->trueLabel = "fall";
		$1->children[0]->children[0]->falseLabel = labelGen.newLabel();
		vector<string> out;
		generateJumpingCode($1->children[0], out, [&](){ return labelGen.newLabel(); });
		$$->tac.insert($$->tac.end(), out.begin(), out.end());
		concat_TAC($$, siesasi_instr);
		if($2) $$->tac.push_back("goto " + final_label);
		$$->tac.push_back($1->children[0]->children[0]->falseLabel + ": ");
		// Si hay una alternativa, se agrega al nodo de la guardia.
		if ($2) {
			for (ASTNode* node : $2->children)  {
				if (node->name == "o_asi"){
					ASTNode* oasi_instr = node->children.size() > 1 ? node->children[1] : nullptr;
					node->children[0]->children[0]->trueLabel = "fall";
					node->children[0]->children[0]->falseLabel = labelGen.newLabel();
					vector<string> out;
					generateJumpingCode(node->children[0], out, [&](){ return labelGen.newLabel(); });
					$$->tac.insert($$->tac.end(), out.begin(), out.end());
					concat_TAC($$, oasi_instr);
					if($2->children.size() != 1) $$->tac.push_back("goto " + final_label);
					$$->tac.push_back(node->children[0]->children[0]->falseLabel + ": ");
				}else{
					// Agregar instrucciones nojoda
					if (node->children.size() != 0) concat_TAC($$, node->children[0]);
				}
				$$->children.push_back(node); // Agregar cada alternativa como un nodo hijo.
			}

			$$->tac.push_back(final_label + ": ");
		}
	}
	;

guardia_siesasi:
	T_SIESASI T_IZQPAREN expresion T_DERPAREN abrir_scope bloque_instrucciones cerrar_scope{
		if ($3->type != "tas_claro") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "Condición de tipo '" + $3->type + "', se esperaba 'tas_claro'.";
			yyerror(error_msg.c_str());
		}

		$$ = makeASTNode("si_es_asi");
		
		// Construccion de la guardia.
		ASTNode* guardia_node = makeASTNode("Guardia");
		guardia_node->children.push_back($3);
		
		
		$$->children.push_back(guardia_node); 

		// Inclusion de instrucciones de si_es_asi
		if($6) $$->children.push_back($6);
	}
	;

guardia:
	T_OASI T_IZQPAREN expresion T_DERPAREN {
		if ($3->type != "tas_claro") {
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "Condición de tipo '" + $3->type + "', se esperaba 'tas_claro'.";
			yyerror(error_msg.c_str());
		}
		$$ = makeASTNode("o_asi");
		
		// Construccion de la guardia.
		ASTNode* guardia_node = makeASTNode("Guardia");
		guardia_node->children.push_back($3); // Agregar la expresión de la guardia.
		
		// Inclusion de guardia en el nodo si_es_asi
		$$->children.push_back(guardia_node);
		
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
			if ($1) collect_guards($1, guardias);
			if ($2) collect_guards($2, guardias);
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
			
			string label0 = labelGen.newLabel();	// Label de inicio del bucle
			$3->trueLabel = "fall";
			$3->falseLabel = labelGen.newLabel(); // Label de salida del bucle
			$$->tac.push_back(label0 + ": ");
			vector<string> out;
			generateJumpingCode(guardia_node, out, [&](){ return labelGen.newLabel(); });
			$$->tac.insert($$->tac.end(), out.begin(), out.end());
			// Si la condición es falsa, salimos del bucle
			auto find_indices = [](const vector<string>& vec, const string& search) {
				vector<size_t> indices;
				for (size_t i = 0; i < vec.size(); ++i) {
					if (vec[i].find(search) != string::npos) {
						indices.push_back(i);
					}
				}
				return indices;
			};
			// Agregar tac uy_kieto
			vector<size_t> break_indices = find_indices($6->tac, "break");
			if(break_indices.size() > 0){
				// Concatenar a los elementos encontrados
				for (size_t idx : break_indices) {
					$6->tac[idx] = "goto " + $3->falseLabel;
				}
			}
			concat_TAC($$, $6);
			$$->tac.push_back("goto " + label0);
			// Label de salida del bucle
			$$->tac.push_back($3->falseLabel + ": ");
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
			string error_msg = "a los tipos entre:'" + type_entre + "' y hasta:'"+type_hasta+"' los dos deben ser 'mangos', loca perdia'.";
			yyerror(error_msg.c_str());
		} else {
			Attributes* attribute = new Attributes();
			attribute->symbol_name = $1;
			attribute->category = VAR_FOR;
			attribute->declare = VARIABLE;
			attribute->scope = symbolTable.current_scope;
			attribute->info.push_back({$3->ivalue, nullptr});
			attribute->info.push_back({$5->ivalue, nullptr});
			attribute->type = symbolTable.search_symbol("mango");
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
		Attributes* attr_var = symbolTable.search_symbol($1);
		if (attr_var != nullptr) {
			int scope_level = attr_var->scope;
			int size_to_reserve = strToSizeType(attr_var->type->symbol_name);
			if (size_to_reserve != -1) $$->tac_declaraciones.push_back({scope_level, {string($1), size_to_reserve}});
		}
	}
	;

determinado:
	T_REPITEBURDA abrir_scope var_ciclo_determinado bloque_instrucciones cerrar_scope {
		ASTNode* new_node = makeASTNode("Bucle", "Determinado");
		
		string kind_range = "Creciente";
		int entre_val = $3->children[0]->children[0]->ivalue;
		int hasta_val = $3->children[1]->children[0]->ivalue;
		//if (entre_val > hasta_val) kind_range = "Decreciente";

		new_node->children.push_back($3);
		new_node->children.push_back($4);

		$$ = new_node;

		// TAC para for
		string var = $3->name, 
			   init = $3->children[0]->children[0]->temp,
			   finish = $3->children[1]->children[0]->temp;
		concat_TAC($$, $3);
		concat_TAC($$, $3->children[0]->children[0]);
		$$->tac.push_back(var + " := " + init);
		concat_TAC($$, $3->children[1]->children[0]);
		
		string label0 = labelGen.newLabel(),
			   label1 = labelGen.newLabel(),
			   label2 = labelGen.newLabel();
		
		$$->tac.push_back(label0 + ": ");
		if (kind_range == "Creciente")
			$$->tac.push_back("if " + var + " < " + finish + " goto " + label1);
		else $$->tac.push_back("if " + var + " > " + finish + " goto " + label1);
		$$->tac.push_back("goto " + label2);
		$$->tac.push_back(label1 + ": ");
		auto find_indices = [](const vector<string>& vec, const string& search) {
			vector<size_t> indices;
			for (size_t i = 0; i < vec.size(); ++i) {
				if (vec[i].find(search) != string::npos) {
					indices.push_back(i);
				}
			}
			return indices;
		};
		// Agregar tac rotalo
		vector<size_t> continue_indices = find_indices($4->tac, "continue");
		if(continue_indices.size() > 0){
			// Concatenar a los elementos encontrados
			for (size_t idx : continue_indices) {
				$4->tac[idx] = "goto " + label0;
			}

			// Insertar antes de cada índice (de atrás hacia adelante para no desfasar)
			string incr = "";
			if (kind_range == "Creciente")
				incr = var + " := " + var + " + " + "1";
			else incr = var + " := " + var + " - " + "1";
			for (auto it = continue_indices.rbegin(); it != continue_indices.rend(); ++it) {
				size_t idx = *it;
				$4->tac.insert($4->tac.begin() + idx, incr);
			}
		}
		// Agregar tac uy_kieto
		vector<size_t> break_indices = find_indices($4->tac, "break");
		if(break_indices.size() > 0){
			// Concatenar a los elementos encontrados
			for (size_t idx : break_indices) {
				$4->tac[idx] = "goto " + label2;
			}
		}
		concat_TAC($$, $4);
		if (kind_range == "Creciente")
			$$->tac.push_back(var + " := " + var + " + " + "1");
		else $$->tac.push_back(var + " := " + var + " - " + "1");
		$$->tac.push_back("goto " + label0);
		$$->tac.push_back(label2 + ": ");
	}
	| T_REPITEBURDA abrir_scope var_ciclo_determinado T_CONFLOW expresion bloque_instrucciones cerrar_scope {
		ASTNode* new_node = makeASTNode("Bucle", "Determinado");

		// Incluimos el flow
		ASTNode* node_flow = makeASTNode("con_flow", "Pasos");
		string kind_range = "Creciente";
		if ($5->type != "mango"){
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "el tipo con_flow:'" + $5->type + "' y debe ser 'mango', loca perdia'.";
			yyerror(error_msg.c_str());
		} else if ($5->ivalue < 0) {
			int entre_val = $3->children[0]->children[0]->ivalue;
			int hasta_val = $3->children[1]->children[0]->ivalue;

			if (entre_val < hasta_val) {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "un rango es creciente y vas a decrementar? Marbaa' bruja.";
				yyerror(error_msg.c_str());
			} else kind_range = "Decreciente";
			
		} else if ($5->ivalue > 0){
			int entre_val = $3->children[0]->children[0]->ivalue;
			int hasta_val = $3->children[1]->children[0]->ivalue;

			if (entre_val > hasta_val) {
				FLAG_ERROR = TYPE_ERROR;
				string error_msg = "un rango es decreciente y vas a incrementar? Marbaa' bruja.";
				yyerror(error_msg.c_str());
			} else kind_range = "Creciente";
		} else if ($5->ivalue == 0){
			FLAG_ERROR = TYPE_ERROR;
			string error_msg = "Definitivamente tu no tienes flow, como que 'con_flow' 0? Jajajaja!";
			yyerror(error_msg.c_str());
		}
		node_flow->children.push_back($5);
		
		$3->children.push_back(node_flow);

		new_node->children.push_back($3);
		new_node->children.push_back($6);

		$$ = new_node;

		// TAC para for
		string var = $3->name, 
			   init = $3->children[0]->children[0]->temp,
			   finish = $3->children[1]->children[0]->temp;

		concat_TAC($$, $3);
		concat_TAC($$, $3->children[0]->children[0]);
		$$->tac.push_back(var + " := " + init);
		concat_TAC($$, $3->children[1]->children[0], $5);
		
		string label0 = labelGen.newLabel(),
			   label1 = labelGen.newLabel(),
			   label2 = labelGen.newLabel();
		
		$$->tac.push_back(label0 + ": ");
		if (kind_range == "Creciente")
			$$->tac.push_back("if " + var + " < " + finish + " goto " + label1);
		else $$->tac.push_back("if " + var + " > " + finish + " goto " + label1);
		$$->tac.push_back("goto " + label2);
		$$->tac.push_back(label1 + ": ");
		auto find_indices = [](const vector<string>& vec, const string& search) {
			vector<size_t> indices;
			for (size_t i = 0; i < vec.size(); ++i) {
				if (vec[i].find(search) != string::npos) {
					indices.push_back(i);
				}
			}
			return indices;
		};
		// Agregar tac rotalo
		vector<size_t> continue_indices = find_indices($6->tac, "continue");
		if(continue_indices.size() > 0){
			// Concatenar a los elementos encontrados
			for (size_t idx : continue_indices) {
				$6->tac[idx] = "goto " + label0;
			}

			// Insertar antes de cada índice (de atrás hacia adelante para no desfasar)
			string incr = var + " := " + var + " + " + $5->temp;
			for (auto it = continue_indices.rbegin(); it != continue_indices.rend(); ++it) {
				size_t idx = *it;
				$6->tac.insert($6->tac.begin() + idx, incr);
			}
		}
		// Agregar tac uy_kieto
		vector<size_t> break_indices = find_indices($6->tac, "break");
		if(break_indices.size() > 0){
			// Concatenar a los elementos encontrados
			for (size_t idx : break_indices) {
				$6->tac[idx] = "goto " + label2;
			}
		}
		concat_TAC($$, $6);
		$$->tac.push_back(var + " := " + var + " + " + $5->temp);
		$$->tac.push_back("goto " + label0);
		$$->tac.push_back(label2 + ": ");
	}
	;

firma_estructura:
	clase_estructura T_ID {
		string class_struct = $1->name;
		Attributes* struct_attr = new Attributes();
		struct_attr->symbol_name = $2;
		struct_attr->category = class_struct== "arroz_con_mango" ? STRUCT : UNION;
		struct_attr->scope = symbolTable.current_scope;
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
					
					Attributes* field_attr = new Attributes();
					field_attr->symbol_name = field_name;
					field_attr->category = ID;
					field_attr->scope = symbolTable.current_scope;
					field_attr->type = symbolTable.search_symbol(attr->type);
					if (field_attr->type == nullptr){
						FLAG_ERROR = NON_DEF_TYPE;
						yyerror(attr->type.c_str());
					}
					struct_attr->info.push_back({field_name, field_attr});

					if (!symbolTable.insert_symbol(field_name, *field_attr)){
						FLAG_ERROR = ALREADY_DEF_ATTR;
						yyerror(field_name.c_str());
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
		Attributes* type_attr = symbolTable.search_symbol($3->type);
		
		param_attr->symbol_name = $1;
		param_attr->category = PARAMETERS;
		param_attr->declare = VARIABLE;
		param_attr->scope = symbolTable.current_scope;
		param_attr->type = type_attr;
		
		string type = type_attr->symbol_name;
		// En caso de ser una estructura.
		if (type_attr->category == STRUCT) {
			queue<vector<string> > queue_structs;
			queue_structs.push({string($1), type});
			bool father_struct = false;
			while(!queue_structs.empty()) {
				auto data = queue_structs.front();
				queue_structs.pop();

				string struct_name = data[0];
				string struct_type = data[1];

				type_attr = symbolTable.search_symbol(struct_type);

				int size_struct = type_attr->info.size();

				// Crear atributo de la estructura
				Attributes* struct_attr = new Attributes();
				struct_attr->symbol_name = struct_name;
				struct_attr->category = STRUCT;
				struct_attr->scope = symbolTable.current_scope;
				struct_attr->type = type_attr;

				for (int i = 0; i < size_struct; i++) {
					const auto& field = type_attr->info[i];
					string full_field = get<string>(field.first);
					size_t dot_pos = full_field.find('.');
					if (dot_pos == string::npos) continue; // No es un campo válido

					string field_type = field.second->type->symbol_name;

					string attr_name = full_field.substr(dot_pos + 1);
					string new_field_name = struct_name + "." + attr_name;
					if (symbolTable.search_symbol(new_field_name)) {
						FLAG_ERROR = ALREADY_DEF_VAR;
						yyerror(new_field_name.c_str());
					} else {
						if (field.second->type->category == STRUCT || field.second->type->category == UNION) {
							queue_structs.push({new_field_name, field_type});
							continue; // Procesar subestructura
						}

						Attributes* new_attr = new Attributes();
						new_attr->symbol_name = new_field_name;
						new_attr->scope = symbolTable.current_scope;
						new_attr->type = symbolTable.search_symbol(field_type);
						new_attr->category = ID;
						new_attr->value = nullptr;

						if (field_type == "mango") new_attr->value = 0;
						else if (field_type == "manguita") new_attr->value = 0.0f;
						else if (field_type == "manguangua") new_attr->value = 0.0;
						else if (field_type == "negro") new_attr->value = '\0';
						else if (field_type == "higuerote") {
							new_attr->value = "";
							new_attr->info.push_back({0, nullptr});
						} else if (field_type == "tas_claro") new_attr->value = false;

						// Agregar a la info de la variable y a la tabla de símbolos
						struct_attr->info.push_back({new_field_name, new_attr});
						symbolTable.insert_symbol(new_field_name, *new_attr);
					}
				}
				
				// Insertar en tabla de símbolos
				if (!symbolTable.insert_symbol(struct_name, *struct_attr)) {
					FLAG_ERROR = ALREADY_DEF_VAR;
					yyerror(struct_name.c_str());
				}
				// Actualizar vector de informacion de estructura padre.
				if (father_struct) {
					size_t pos = struct_name.rfind('.');
					string father = struct_name.substr(0, pos);
					Attributes* father_attr = symbolTable.search_symbol(father);
					father_attr->info.push_back({struct_name, struct_attr});
				}
				father_struct = true;
			}
		// En caso de ser tipos basicos.
		} else {
			if (type == "mango") param_attr->value = 0;
			else if (type == "manguita") param_attr->value = 0.0f;
			else if (type == "manguangua") param_attr->value = 0.0;
			else if (type == "negro") param_attr->value = '\0';
			else if (type == "higuerote") {
				param_attr->value = "";
				param_attr->info.push_back({0, nullptr});
			} else if (type == "tas_claro") param_attr->value = false;
		}
		
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

			// Verificar si la función retorna un tipo válido
			vector<ASTNode*> out;
			collect_returns($8, out);
			if (out.empty() && func_type != "un_coño") {
				FLAG_ERROR = FUNC_NO_RETURN;
				yyerror(func_name.c_str());
			} else if (!out.empty() && func_type == "un_coño") {
				FLAG_ERROR = FUNC_RETURN_VALUE;
				yyerror(func_name.c_str());
			} else {
				for (auto lanza : out) {
					if (lanza->type != func_type) {
						FLAG_ERROR = TYPE_ERROR;
						string error_msg = "el tipo de retorno '" + lanza->type + "' no coincide con el tipo de la función '" + func_name + "' que es '" + func_type + "'.";
						yyerror(error_msg.c_str());
					}
				}
			}

			// Generación de TAC para la función
			string label_func = labelGen.newLabel(func_name);
			$$->tac.push_back(label_func + ":");
			$$->tac.push_back("begin_func:");
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
			vector<ASTNode*> arg_nodes;
			collect_arguments($3, arg_nodes);
			
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
		vector<ASTNode*> arg_nodes;
		collect_arguments($3, arg_nodes);
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
	T_CASTEO expresion { 
		ASTNode* expr = $2;
		string target_type = string($1);
		ASTNode* cast_node = makeASTNode("Literal", "", target_type, "CAST(" + expr->type + ")");
		cast_node->children.push_back(expr);

		if (target_type == "mango") {
			cast_node->category = "Numérico";
			if (expr->type == "mango") {
				cast_node->ivalue = expr->ivalue;
			} else if (expr->type == "manguita") {
				cast_node->ivalue = static_cast<int>(expr->fvalue);
			} else if (expr->type == "manguangua") {
				if (expr->dvalue > INT_MAX || expr->dvalue < INT_MIN) {
					FLAG_ERROR = OVERFULL;
					string err_value = expr->category == "Identificador" ? expr->name : to_string(expr->dvalue);
					string error_msg = "'" + err_value + "' en un 'mango', no cabe piaso e' loca.";
					yyerror(error_msg.c_str());
				} else {
					cast_node->ivalue = static_cast<int>(expr->dvalue);
				}
			} else if (expr->type == "negro") {
				cast_node->ivalue = static_cast<int>(expr->cvalue);
			} else if (expr->type == "higuerote") {
				try {
					cast_node->ivalue = stoi(expr->svalue);
				} catch (...) {
					FLAG_ERROR = CASTING_ERROR;
					string err_value = expr->category == "Identificador" ? expr->name : expr->svalue;
					string error_msg = "'" + err_value + "' antes de castear a 'mango'.";
					yyerror(error_msg.c_str());
				}
			} else {
				FLAG_ERROR = CASTING_TYPE;
				yyerror(("'" + expr->type + "' a 'mango'").c_str());
			}
		}
		else if (target_type == "manguita") {
			cast_node->category = "Numérico";
			if (expr->type == "mango") {
				cast_node->fvalue = static_cast<float>(expr->ivalue);
			} else if (expr->type == "manguita") {
				cast_node->fvalue = expr->fvalue;
			} else if (expr->type == "manguangua") {
				if (expr->dvalue > FLT_MAX || expr->dvalue < -FLT_MAX) {
					FLAG_ERROR = OVERFULL;
					string err_value = expr->category == "Identificador" ? expr->name : to_string(expr->dvalue);
					string error_msg = "'" + err_value + "' en una 'manguita', no cabe piaso e' loca.";
					yyerror(error_msg.c_str());
				} else {
					cast_node->fvalue = static_cast<float>(expr->dvalue);
				}
			} else if (expr->type == "higuerote") {
				try {
					cast_node->fvalue = stof(expr->svalue);
				} catch (...) {
					FLAG_ERROR = CASTING_ERROR;
					string err_value = expr->category == "Identificador" ? expr->name : expr->svalue;
					string error_msg = "'" + err_value + "' antes de castear a 'manguita'.";
					yyerror(error_msg.c_str());
				}
			} else {
				FLAG_ERROR = CASTING_TYPE;
				yyerror(("'" + expr->type + "' a 'manguita'").c_str());
			}
		}
		else if (target_type == "manguangua") {
			cast_node->category = "Numérico";
			if (expr->type == "mango") {
				cast_node->dvalue = static_cast<double>(expr->ivalue);
			} else if (expr->type == "manguita") {
				cast_node->dvalue = static_cast<double>(expr->fvalue);
			} else if (expr->type == "manguangua") {
				cast_node->dvalue = expr->dvalue;
			} else if (expr->type == "higuerote") {
				try {
					cast_node->dvalue = stod(expr->svalue);
				} catch (...) {
					FLAG_ERROR = CASTING_ERROR;
					string err_value = expr->category == "Identificador" ? expr->name : expr->svalue;
					string error_msg = "'" + err_value + "' antes de castear a 'manguangua'.";
					yyerror(error_msg.c_str());
				}
			} else {
				FLAG_ERROR = CASTING_TYPE;
				yyerror(("'" + expr->type + "' a 'manguangua'").c_str());
			}
		}
		else if (target_type == "negro") {
			cast_node->category = "Caracter";
			if (expr->type == "mango") {
				cast_node->cvalue = static_cast<char>(expr->ivalue);
			} else if (expr->type == "higuerote") {
				if (expr->svalue.empty()) {
					cast_node->cvalue = '\0';
				} else if (expr->svalue.size() == 1) {
					cast_node->cvalue = expr->svalue[0];
				} else {
					FLAG_ERROR = OVERFULL;
					string err_value = expr->category == "Identificador" ? expr->name : expr->svalue;
					string error_msg = "'" + err_value + "' de tamaño '" + to_string(err_value.size()) + "' cm en un 'negro', esas son vainas raras!";
					yyerror(error_msg.c_str());
				}
			} else if (expr->type == "negro") {
				cast_node->cvalue = expr->cvalue;
			} else {
				FLAG_ERROR = CASTING_TYPE;
				yyerror(("'" + expr->type + "' a 'negro'").c_str());
			}
		}
		else if (target_type == "higuerote") {
			cast_node->category = "Cadena de Caracteres";
			if (expr->type == "mango") {
				cast_node->svalue = to_string(expr->ivalue);
			} else if (expr->type == "manguita") {
				cast_node->svalue = to_string(expr->fvalue);
			} else if (expr->type == "manguangua") {
				cast_node->svalue = to_string(expr->dvalue);
			} else if (expr->type == "negro") {
				if (expr->cvalue != '\0') cast_node->svalue = string(1, expr->cvalue);
				else cast_node->svalue = "";
			} else if (expr->type == "higuerote") {
				cast_node->svalue = expr->svalue;
			} else {
				FLAG_ERROR = CASTING_TYPE;
				yyerror(("'" + expr->type + "' a 'higuerote'").c_str());
			}
		}
		else {
			FLAG_ERROR = INTERNAL;
			string error_msg = "ERROR: Lexer proporciona un tipo desconocido para el casting: '" + target_type + "'";
			yyerror(error_msg.c_str());
		}

		$$ = cast_node;

		// Actualizacion codigo TAC
		string type = "";
		if (target_type == "mango") type = "int";
		else if (target_type == "manguita") type = "float";
		else if (target_type == "manguangua") type = "double";
		else if (target_type == "negro") type = "char";
		else if (target_type == "higuerote") type = "string";
		$$->temp = "(" + type + ")" + $2->temp;
		concat_TAC($$, $2);
	}
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
				error_msg += "Al tipo este \"" + string(var) + "\" lo tienes adentro debe ser. Nadie lo ve.";
				break;
			case ALREADY_DEF_TYPE:
				error_msg += "El tipo \"" + string(var) + "\" ya existe. Dice que te extraña de anoche.";
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
			case WRONG_RANGE:
				error_msg += "Te patina el coco chamo. " + string(var);
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

			case INVALID_OPERATION:
				error_msg += "Estas operando " + string(var);
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
			case FUNC_RETURN_VALUE:
				error_msg += "El cuento \"" + string(var) + "\" no debería lanzar algo, pero tas lanzando algo, locota.";
				break;
			case FUNC_NO_RETURN:
				error_msg += "El cuento \"" + string(var) + "\" debería lanzar algo, pero no lo haces, marbao'.";
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
			case INVALID_ACCESS:
				error_msg += "Esto '" + string(var) + "' no es un `array` ni un `higuerote`, marbao'. No le metas mano.";

			case CASTING_TYPE:
				error_msg += "Cristo convirtió el agua en vino pero tú no eres él pa' estar convirtiendo " + string(var) + ", sapo";
				break;
			case CASTING_ERROR:
				error_msg += "A parte de manco, ciego. Revisa bien " + string(var);
				break;
			case OVERFULL:
				error_msg += "Te pasaste de la raya, marbao'. Quieres meter " + string(var);
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