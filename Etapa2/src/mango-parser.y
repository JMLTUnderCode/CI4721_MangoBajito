%{
#include <iostream>
#include <cstdlib>
#include "mango-bajito.hpp"
#include <cstring>

using namespace std;

typedef struct YYLTYPE {
    int first_line;
    int first_column;
    //int last_line;
    //int last_column;
} YYLTYPE;

void yyerror(const char *s);
int yylex();
extern int yylineno;
extern YYLTYPE yylloc;

SymbolTable symbolTable = SymbolTable();

// Inicialización del diccionario de errores
unordered_map<errorType, vector<string>> errorDictionary = {
    {SEMANTIC_TYPE, {}},
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
    {EMPTY_ARRAY_CONSTANT, {}},
    {POINTER_ARRAY, {}},
    {INT_SIZE_ARRAY,{}},
    {INT_INDEX_ARRAY, {}},
    {DEBUGGING_TYPE, {}}
};

errorType ERROR_TYPE = SEMANTIC_TYPE; // Permite manejar un error particular de tipo errorType
bool FIRST_ERROR = false;

string current_struct_name = "";

string current_function_name = "";
int current_function_parameters = 0;
string current_function_type = "";

string current_array_name = "";
int current_array_size = 0;
const char* current_array_base_type = nullptr;

%}

%code requires {
    #include <cstring>
	struct ExpresionAttribute {
		enum Type { INT, FLOAT, DOUBLE, BOOL, STRING, POINTER, ID, CHAR, VOID} type;
		union {
			int ival;
			float fval;
			double dval;
			char* sval;
            char cval;
		};
	};       
}

%code requires {
    inline char* typeToString(ExpresionAttribute::Type type) {
        switch (type) {
            case ExpresionAttribute::INT:    return "mango";
            case ExpresionAttribute::FLOAT:  return "manguita";
            case ExpresionAttribute::DOUBLE: return "manguangua";
            case ExpresionAttribute::BOOL:   return "bool";
            case ExpresionAttribute::CHAR:   return "negro";
            case ExpresionAttribute::STRING: return "higuerote";
            case ExpresionAttribute::POINTER:return "pointer";
            case ExpresionAttribute::ID:     return "id";
			case ExpresionAttribute::VOID:   return "un_coño";
            default:                         return "unknown";
        }
    }  

    inline ExpresionAttribute::Type stringToType(const std::string& typeStr) {
        if (typeStr == "mango") {
            return ExpresionAttribute::INT;
        } else if (typeStr == "manguita") {
            return ExpresionAttribute::FLOAT;
        } else if (typeStr == "manguangua") {
            return ExpresionAttribute::DOUBLE;
        } else if (typeStr == "bool") {
            return ExpresionAttribute::BOOL;
        } else if (typeStr == "negro") {
            return ExpresionAttribute::CHAR;
        } else if (typeStr == "higuerote") {
            return ExpresionAttribute::STRING;
        } else if (typeStr == "pointer") {
            return ExpresionAttribute::POINTER;
        } else if (typeStr == "id") {
            return ExpresionAttribute::ID;
		} else if (typeStr == "un_coño") {
			return ExpresionAttribute::VOID;
        } else {
            throw std::invalid_argument("Tipo desconocido: " + typeStr);
        }
    }   
}

%union {
	ExpresionAttribute att_val; // Usa el struct definido
    int ival;
    float fval;
    double dval;
    char* sval;
    char cval;
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
%token <sval> T_IDENTIFICADOR 
%token <att_val> T_VALUE
%token T_IZQPAREN T_DERPAREN T_IZQLLAVE T_DERLLAVE T_IZQCORCHE T_DERCORCHE
%token T_CASTEO

// Declaracion de tipos de retorno para las producciones 
%type <sval> tipo_declaracion declaracion_aputador tipo_valor tipos asignacion firma_funcion
%type <att_val> expresion
%type <ival> operadores_asignacion
%type <att_val> valores_booleanos

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
%right T_SIGNO_MENOS T_NELSON
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
    abrir_scope instrucciones main cerrar_scope
    | abrir_scope main cerrar_scope
    ;

main:
    T_SE_PRENDE abrir_scope T_IZQPAREN T_DERPAREN T_IZQLLAVE instruccionesopt T_DERLLAVE T_PUNTOCOMA cerrar_scope { 
		if (FIRST_ERROR) {
			printErrors();
		} else {
			symbolTable.print_table(); 
			cout << "Programa válido: "; 
		}
	} 
    ;

instrucciones:
    instruccion T_PUNTOCOMA | instrucciones instruccion T_PUNTOCOMA
    ;

instruccionesopt:
    instrucciones |
    ;

instruccion:
    declaracion 
    | asignacion
    | condicion 
    | bucle 
    | entrada_salida 
    | funcion
    | manejo_error 
    | struct
    | variante
    | T_KIETO
    | T_ROTALO
    | T_IDENTIFICADOR T_OPDECREMENTO {
        Attributes *var = symbolTable.search_symbol($1);
        if (var == nullptr) {
            ERROR_TYPE = NON_DEF_VAR;
            yyerror($1);
        }

        if (var->type != nullptr && var->type->symbol_name == "mango") {
            if (holds_alternative<int>(var->value)) {
                int old_val = get<int>(var->value);
                var->value = old_val - 1;
            } else {
				ERROR_TYPE = NON_VALUE;
                yyerror($1);
            }
        } else {
			ERROR_TYPE = TYPE_ERROR;
            string error_msg = "\"" + string($1) + "\" de tipo '" + var->type->symbol_name + "' y debe ser de tipo 'mango', locota.";
            yyerror(error_msg.c_str());
        }
    }
    | T_IDENTIFICADOR T_OPINCREMENTO {
        Attributes *var = symbolTable.search_symbol($1);
        if (var == nullptr) {
            ERROR_TYPE = NON_DEF_VAR;
            yyerror($1);
        }

        if (var->type != nullptr && var->type->symbol_name == "mango") {
            if (holds_alternative<int>(var->value)) {
                int old_val = get<int>(var->value);
                var->value = old_val + 1;
            } else {
                ERROR_TYPE = NON_VALUE;
                yyerror($1);
            }
        } else {
            ERROR_TYPE = TYPE_ERROR;
            string error_msg = "\"" + string($1) + "\" de tipo '" + var->type->symbol_name + "' y debe ser de tipo 'mango', locota.";
            yyerror(error_msg.c_str());
        }
    }
    | T_LANZATE expresion
    | T_BORRADOL T_IDENTIFICADOR 
    | T_BORRADOL T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR 
    ;

declaracion:
    tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos {
        // Caso para arrays (detectado por variables globales)
        if (current_array_size > 0 && current_array_base_type != nullptr) {
            // Verificar que el tipo base existe
            Attributes* base_type_attr = symbolTable.search_symbol(current_array_base_type);
            if (base_type_attr == nullptr) {
                ERROR_TYPE = NON_DEF_TYPE;
                yyerror(current_array_base_type);
            }

            // Validar categoría de declaración
            if (strcmp($1, "CONSTANTE") == 0) {
                ERROR_TYPE = EMPTY_ARRAY_CONSTANT;
                yyerror($2);
            }
            if (strcmp($1, "POINTER_C") == 0 || strcmp($1, "POINTER_V") == 0) {
                ERROR_TYPE = POINTER_ARRAY;
                yyerror($2);
            }

            // Crear atributos del array
            Attributes* attributes = new Attributes();
            attributes->symbol_name = $2;
            attributes->category = ARRAY;
            attributes->scope = symbolTable.current_scope;
            attributes->type = base_type_attr;
            attributes->value = current_array_size;

            for (int i = 0; i < current_array_size; i++) {
                Attributes *elem = new Attributes();
                elem->symbol_name = std::string($2) + "[" + std::to_string(i) + "]";
                elem->scope = symbolTable.current_scope;
                elem->category = ARRAY_ELEMENT;
                elem->type = base_type_attr;
                elem->value = nullptr;

                // Usar el índice como clave en formato string
                attributes->info.push_back({std::string($2) + "[" + std::to_string(i) + "]", elem});
    
                // \Insertar elemento en tabla de símbolos
                if (!symbolTable.insert_symbol(elem->symbol_name, *elem)) {
                    ERROR_TYPE = ALREADY_DEF_VAR;
                    yyerror(elem->symbol_name.c_str());
                }
            }

            // Insertar en tabla de símbolos
            if (!symbolTable.insert_symbol($2, *attributes)) {
                ERROR_TYPE = ALREADY_DEF_VAR;
                yyerror($2);
            }

            string current_array_name = "";
            current_array_size = 0;
            current_array_base_type = nullptr;            
        }
        // Caso normal (no array)
        else {
            if (symbolTable.search_symbol($4) == nullptr) {
                ERROR_TYPE = NON_DEF_TYPE;
                yyerror($4);
            }

            Attributes *attributes = new Attributes();
            attributes->symbol_name = $2;
			attributes->info.push_back({"-", nullptr});
            attributes->scope = symbolTable.current_scope;
            attributes->type = symbolTable.search_symbol($4);

            if (strcmp($1, "POINTER_V") == 0) {
                attributes->category = POINTER_V;
            } else if (strcmp($1, "POINTER_C") == 0) {
                attributes->category = POINTER_C;
            } else if (strcmp($1, "VARIABLE") == 0) {
                attributes->category = VARIABLE;
            } else if (strcmp($1, "CONSTANTE") == 0) {
                attributes->category = CONSTANT;
            }

            if (!symbolTable.insert_symbol($2, *attributes)) {
                ERROR_TYPE = ALREADY_DEF_VAR;
                yyerror($2);
            }
        }
    }
    | tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos T_ASIGNACION expresion {
        if (symbolTable.search_symbol($4) == nullptr){
			ERROR_TYPE = NON_DEF_TYPE;
            yyerror($4);
        };

		if (current_function_type != ""){ // En caso de asignacion de funciones.
			string type_id = symbolTable.search_symbol($4)->symbol_name;
			if (current_function_type != type_id){
				ERROR_TYPE = TYPE_ERROR;
				string error_message = "\"" + string($2) + "\" de tipo '" + type_id + 
					"' y le quieres meter un cuento de tipo '" + current_function_type + "\", marbaa' bruja.";
				yyerror(error_message.c_str());
			}
			current_function_type = "";
		}

		Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"-", nullptr});
        attributes->type = symbolTable.search_symbol($4);

        if (strcmp($1, "POINTER_V") == 0){
            attributes->category = POINTER_V;
        } else if (strcmp($1, "POINTER_C") == 0){
            attributes->category = POINTER_C;
        } else if (strcmp($1, "VARIABLE") == 0){
            attributes->category = VARIABLE;
        } else if (strcmp($1, "CONSTANTE") == 0){
            attributes->category = CONSTANT;
        };

	    switch($6.type) {
	        case ExpresionAttribute::INT:
				if(string($4) != "mango") {
					ERROR_TYPE = TYPE_ERROR;
					string error_message = "\"" + string($2) + "\" de tipo '" + string($4) + "' y le quieres meter un tipo '" + string(typeToString($6.type)) + "', marbaa' bruja.";
					yyerror(error_message.c_str());
				}
	            attributes->value = $6.ival;
	            break;
	        
	        case ExpresionAttribute::FLOAT:
				if(string($4) != "manguita") {
					ERROR_TYPE = TYPE_ERROR;
					string error_message = "\"" + string($2) + "\" de tipo '" + string($4) + "' y le quieres meter un tipo '" + string(typeToString($6.type)) + "', marbaa' bruja.";
					yyerror(error_message.c_str());
				}
	            attributes->value = $6.fval;
	            break;
	        
			case ExpresionAttribute::DOUBLE:
				if(string($4) != "manguangua") {
					ERROR_TYPE = TYPE_ERROR;
					string error_message = "\"" + string($2) + "\" de tipo '" + string($4) + "' y le quieres meter un tipo '" + string(typeToString($6.type)) + "', marbaa' bruja.";
					yyerror(error_message.c_str());
				}
	            attributes->value = $6.dval;
	            break;

	        case ExpresionAttribute::BOOL:
                if(string($4) == "tas_claro") {
                    attributes->value = (bool)$6.ival;
                    if (!attributes->info.empty()) {
                        attributes->info[0].first = ($6.ival ? std::string("Sisa") : std::string("Nolsa"));
                    } else {
                        attributes->info.push_back({($6.ival ? std::string("Sisa") : std::string("Nolsa")), nullptr});
                    }
                } else { 
                    ERROR_TYPE = TYPE_ERROR;
					string error_message = "\"" + string($2) + "\" de tipo '" + string($4) + "' y le quieres meter un tipo '" + string(typeToString($6.type)) + "', marbaa' bruja.";
                    yyerror(error_message.c_str());
                    
                }
                break;
	        
	        case ExpresionAttribute::STRING:
				if(string($4) != "higuerote") {
					ERROR_TYPE = TYPE_ERROR;
					string error_message = "\"" + string($2) + "\" de tipo '" + string($4) + "' y le quieres meter un tipo '" + string(typeToString($6.type)) + "', marbaa' bruja.";
					yyerror(error_message.c_str());
				}
	            attributes->value = string($6.sval);
	            break;

            case ExpresionAttribute::CHAR:
				if(string($4) != "negro") {
					ERROR_TYPE = TYPE_ERROR;
					string error_message = "\"" + string($2) + "\" de tipo '" + string($4) + "' y le quieres meter un tipo '" + string(typeToString($6.type)) + "', marbaa' bruja.";
					yyerror(error_message.c_str());
				}
                attributes->value = $6.cval;
                break;

	        case ExpresionAttribute::POINTER:
	            attributes->value = nullptr;
	            break;
	        
	        default:
	            attributes->value = nullptr;
	    }

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($2);
            //exit(1);
        };
    }
	| declaracion_funcion
    ;

declaracion_aputador:
    { $$ = strdup(""); }
    | T_AHITA   { $$ = strdup("POINTER"); }
    ;

tipo_declaracion:
    declaracion_aputador T_CULITO { $$ =  strcmp($1, "POINTER") == 0 ? strdup("POINTER_V") : strdup("VARIABLE"); }
    | declaracion_aputador T_JEVA { $$ =  strcmp($1, "POINTER") == 0 ? strdup("POINTER_C") : strdup("CONSTANTE"); }
    ;

tipos:
    tipo_valor {
		if (current_function_name != "") current_function_type = string($1);
		$$ = $1;
	}
    | tipos T_IZQCORCHE expresion T_DERCORCHE {
        // Verificar que la expresión sea un valor entero válido
        if ($3.type != ExpresionAttribute::INT) {
            ERROR_TYPE = INT_SIZE_ARRAY;
            yyerror(typeToString($3.type));
        }

	    // Obtener tipo base y tamaño
	    char* base_type = $1;
	    int array_size = $3.ival;

	    // Registrar tamaño en variable global temporal
	    current_array_size = array_size; // Variable global para tamaño
	    current_array_base_type = base_type; // Variable global para tipo base

	    $$ = base_type; // Retornar tipo base para validación
    }
	| T_IDENTIFICADOR {
		Attributes* attribute = symbolTable.search_symbol(string($1));
		if (attribute == nullptr){
			ERROR_TYPE = NON_DEF_VAR;
			yyerror($1);
			$$ = $1;
		} else {
			$$ = strdup(attribute->symbol_name.c_str());
		}
	}
    ;

tipo_valor:
    T_MANGO { $$ = strdup("mango"); }
    | T_MANGUITA { $$ = strdup("manguita"); }
    | T_MANGUANGUA { $$ = strdup("manguangua"); }
    | T_NEGRO { $$ = strdup("negro"); }
    | T_HIGUEROTE { $$ = strdup("higuerote"); }
    | T_TASCLARO { $$ = strdup("tas_claro"); }
    ;

operadores_asignacion:
    T_ASIGNACION    { $$ = 0; } // 0 for =
    | T_OPASIGSUMA  { $$ = 1; } // 1 for +=
    | T_OPASIGRESTA { $$ = 2; } // 2 for -=
    | T_OPASIGMULT  { $$ = 3; } // 3 for *=
    ;

asignacion:
    T_IDENTIFICADOR operadores_asignacion expresion {
        Attributes *lhs_attr = symbolTable.search_symbol(string($1));
        if (lhs_attr == nullptr){
            ERROR_TYPE = NON_DEF_VAR;
            yyerror($1);
        }
        
		const string lhs_name = string($1);
        int op_type = $2;
        const ExpresionAttribute& rhs_expr = $3;

        // Specific checks from your original rule
        if (!lhs_attr->info.empty()) { // Check if info has elements before accessing
            string info_var_check = get<string>(lhs_attr->info[0].first);
            if (info_var_check == "CICLO FOR"){
                ERROR_TYPE = VAR_FOR;
                yyerror(lhs_name.c_str());
            }
            if (info_var_check == "MANEJO ERROR"){
                ERROR_TYPE = VAR_TRY;
                yyerror(lhs_name.c_str());
            }
        }

        if (lhs_attr->category == CONSTANT && op_type == 0 && !holds_alternative<nullptr_t>(lhs_attr->value)) {
            ERROR_TYPE = MODIFY_CONST;
            yyerror(lhs_name.c_str());
            
        }
         if (lhs_attr->category == CONSTANT && op_type != 0) {
            ERROR_TYPE = MODIFY_CONST; 
            yyerror(lhs_name.c_str());
        }
        if (!lhs_attr->type) {
			ERROR_TYPE = DEBUGGING_TYPE;
			string error_message = "Error interno: El tipo de \"" + lhs_name + "\" no esta definido.";
            yyerror(error_message.c_str());
        }
        string lhs_declared_type_name = lhs_attr->type->symbol_name;

		if (current_function_name != ""){ // En caso de asignacion de funciones.
			if (current_function_type != lhs_declared_type_name){
				ERROR_TYPE = TYPE_ERROR;
				string error_message = "\"" + string($1) + "\" de tipo '" + lhs_declared_type_name + 
					"' y le quieres meter un cuento de tipo '" + current_function_type + "\", marbaa' bruja.";
				yyerror(error_message.c_str());
			}
			current_function_name = "";
			current_function_parameters = 0;
			current_function_type = "";
		}

        if (op_type != 0) {
            if (holds_alternative<nullptr_t>(lhs_attr->value)) {
                ERROR_TYPE = NON_DEF_VAR;
                string op_str = (op_type == 1 ? "+=" : (op_type == 2 ? "-=" : (op_type == 3 ? "*=" : "OP_COMPUESTO")));
                yyerror(("Variable/Elemento '" + lhs_name + "' no inicializada antes de usarla en operación '" + op_str + "'.").c_str());
            }
        }

        switch (op_type) {
            case 0: // Simple Assignment (=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = rhs_expr.ival; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a mango '" + lhs_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = rhs_expr.fval; }
                    else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = static_cast<float>(rhs_expr.ival); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a manguita '" + lhs_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                    if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = rhs_expr.dval; }
                    else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = static_cast<double>(rhs_expr.fval); }
                    else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = static_cast<double>(rhs_expr.ival); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a manguangua '" + lhs_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "tas_claro") {
                    if (rhs_expr.type == ExpresionAttribute::BOOL) { lhs_attr->value = (bool)rhs_expr.ival; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a tas_claro '" + lhs_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "higuerote") {
                    if (rhs_expr.type == ExpresionAttribute::STRING) { lhs_attr->value = string(rhs_expr.sval); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a higuerote '" + lhs_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "negro") {
                    if (rhs_expr.type == ExpresionAttribute::CHAR) { lhs_attr->value = rhs_expr.cval; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a negro '" + lhs_name + "'").c_str()); }
                } else if (rhs_expr.type == ExpresionAttribute::ID) {
                    Attributes *rhs_id_attr = symbolTable.search_symbol(rhs_expr.sval);
                    if (rhs_id_attr) {
                        if (rhs_id_attr->category == VARIABLE || rhs_id_attr->category == CONSTANT || rhs_id_attr->category == ARRAY_ELEMENT || rhs_id_attr->category == POINTER_V || rhs_id_attr->category == POINTER_C) {
                            if (holds_alternative<nullptr_t>(rhs_id_attr->value) && rhs_id_attr->type && rhs_id_attr->type->symbol_name != "pointer") {
                                 ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + string(rhs_id_attr->symbol_name.c_str()) + "' usada en asignación antes de ser inicializada.").c_str()); 
                            }
                            if (lhs_declared_type_name == rhs_id_attr->type->symbol_name) {
                                lhs_attr->value = rhs_id_attr->value;
                            } else if (lhs_declared_type_name == "manguita" && rhs_id_attr->type->symbol_name == "mango" && holds_alternative<int>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<float>(get<int>(rhs_id_attr->value));
                            } else if (lhs_declared_type_name == "manguangua" && rhs_id_attr->type->symbol_name == "mango" && holds_alternative<int>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<double>(get<int>(rhs_id_attr->value));
                            } else if (lhs_declared_type_name == "manguangua" && rhs_id_attr->type->symbol_name == "manguita" && holds_alternative<float>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<double>(get<float>(rhs_id_attr->value));
                            } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Error de tipo: no se puede asignar " + string(rhs_id_attr->type->symbol_name.c_str()) + " a " + lhs_declared_type_name + " '" + lhs_name + "'").c_str()); }
                        } else { ERROR_TYPE = TYPE_ERROR; yyerror(("El lado derecho de la asignación ('" + string(rhs_expr.sval) + "') no es una variable o constante evaluable.").c_str()); }
                    } else { ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + string(rhs_expr.sval) + "' no definida para asignación.").c_str()); }
                } else { // Assigning struct/union or other complex types
                    // This part needs specific logic for your complex types.
                    // For now, if types match by name, allow assignment.
                    // This is a shallow copy.
                    // You might need to look up rhs_expr if it's an ID representing a struct.
                    // The current execute_assignment_logic doesn't fully cover this.
                    // For now, we assume primitive types or ID assignment is handled above.
                    // If lhs_attr is a struct/union and rhs_expr is also a struct/union of the same type:
                    // if ( (lhs_attr->category == STRUCT || lhs_attr->category == UNION) &&
                    //      (rhs_expr.type_name == lhs_declared_type_name) /* and rhs_expr holds a compatible struct/union value */ ) {
                    //      lhs_attr->value = rhs_expr.complex_value; // Needs ExpresionAttribute to hold complex values
                    // } else
                    ERROR_TYPE = TYPE_ERROR; yyerror(("Tipo de asignación no soportado para variable '" + lhs_declared_type_name + "' desde expresión '" + string(typeToString(rhs_expr.type)) + "'").c_str()); 
                }
                break;
            case 1: // Compound Assignment (+=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) + rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a mango '" + lhs_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) + rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) + static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a manguita '" + lhs_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Variable manguita '" + lhs_name + "' no contiene un valor flotante para '+='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) + rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) + static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) + static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a manguangua '" + lhs_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Variable manguangua '" + lhs_name + "' no contiene un valor double para '+='.").c_str()); }
                } else if (lhs_declared_type_name == "higuerote") {
                    if (rhs_expr.type == ExpresionAttribute::STRING && holds_alternative<string>(lhs_attr->value)) {
                        lhs_attr->value = get<string>(lhs_attr->value) + string(rhs_expr.sval);
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede concatenar " + string(typeToString(rhs_expr.type)) + " a higuerote '" + lhs_name + "'").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' no soportada para el tipo '" + lhs_declared_type_name + "' de la variable '" + lhs_name + "'").c_str()); }
                break;
            case 2: // Compound Assignment (-=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) - rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de mango '" + lhs_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) - rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) - static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de manguita '" + lhs_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Variable manguita '" + lhs_name + "' no contiene un valor flotante para '-='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) - rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) - static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) - static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de manguangua '" + lhs_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Variable manguangua '" + lhs_name + "' no contiene un valor double para '-='.").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' no soportada para el tipo '" + lhs_declared_type_name + "' de la variable '" + lhs_name + "'").c_str()); }
                break;
            case 3: // Compound Assignment (*=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) * rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar mango '" + lhs_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) * rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) * static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar manguita '" + lhs_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Variable manguita '" + lhs_name + "' no contiene un valor flotante para '*='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) * rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) * static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) * static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar manguangua '" + lhs_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Variable manguangua '" + lhs_name + "' no contiene un valor double para '*='.").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' no soportada para el tipo '" + lhs_declared_type_name + "' de la variable '" + lhs_name + "'").c_str()); }
                break;
            default:
                yyerror("Operador de asignación desconocido internamente.");
                
        }
        // --- End Inlined execute_assignment_logic ---
    }
    | T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR operadores_asignacion expresion {
        // struct_var.member op expr
        Attributes* struct_var_attr = symbolTable.search_symbol(string($1));
        const std::string struct_name_str = string($1);
        const std::string member_name_str = string($3);
        int op_type = $4;
        const ExpresionAttribute& rhs_expr = $5;
        Attributes* lhs_attr = nullptr; // This will be the member's attributes

        if (struct_var_attr == nullptr) {
            ERROR_TYPE = NON_DEF_VAR;
            yyerror(struct_name_str.c_str());
            
        }
        if (struct_var_attr->category != STRUCT && struct_var_attr->category != UNION) {
            ERROR_TYPE = TYPE_ERROR;
            yyerror(("La variable '" + struct_name_str + "' no es una estructura o variante.").c_str());
            
        }

        // Find the member attribute
        bool member_found = false;
        for (const auto& pair_info : struct_var_attr->info) {
            if (auto str_ptr = std::get_if<std::string>(&pair_info.first)) {
                if (*str_ptr == member_name_str) {
                lhs_attr = pair_info.second;
                member_found = true;
                break;
            }
        }
    }

        if (!member_found || lhs_attr == nullptr) {
            ERROR_TYPE = NON_DEF_VAR; // O usa NON_DEF_ATTR si lo agregas a tu enum y diccionario
            yyerror(("La estructura/variante '" + struct_name_str + "' no tiene un miembro llamado '" + member_name_str + "'.").c_str());
            
        }
        
        const std::string lhs_full_name = struct_name_str + "." + member_name_str;

        // --- Inlined execute_assignment_logic for struct member ---
        if (!lhs_attr->type) {
            yyerror(("Error interno: El tipo del miembro '" + lhs_full_name + "' es nulo.").c_str());
            
        }
        string lhs_declared_type_name = lhs_attr->type->symbol_name;

        if (op_type != 0) { // Compound assignments
            if (holds_alternative<nullptr_t>(lhs_attr->value)) {
                ERROR_TYPE = NON_DEF_VAR;
                string op_str = (op_type == 1 ? "+=" : (op_type == 2 ? "-=" : (op_type == 3 ? "*=" : "OP_COMPUESTO")));
                yyerror(("Miembro '" + lhs_full_name + "' no inicializado antes de usarlo en operación '" + op_str + "'.").c_str());
                
            }
        }
        // (Repeat the switch(op_type) block from above, using lhs_attr, lhs_full_name, op_type, rhs_expr)
        // For brevity, I'm indicating to repeat it. In actual code, you'd copy-paste and adapt.
        // --- Start copy of switch(op_type) for struct member ---
        switch (op_type) {
            case 0: // Simple Assignment (=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = rhs_expr.ival; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a mango '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = rhs_expr.fval; }
                    else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = static_cast<float>(rhs_expr.ival); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a manguita '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                    if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = rhs_expr.dval; }
                    else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = static_cast<double>(rhs_expr.fval); }
                    else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = static_cast<double>(rhs_expr.ival); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a manguangua '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "tas_claro") {
                    if (rhs_expr.type == ExpresionAttribute::BOOL) { lhs_attr->value = (bool)rhs_expr.ival; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a tas_claro '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "higuerote") {
                    if (rhs_expr.type == ExpresionAttribute::STRING) { lhs_attr->value = string(rhs_expr.sval); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a higuerote '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "negro") {
                    if (rhs_expr.type == ExpresionAttribute::CHAR) { lhs_attr->value = rhs_expr.cval; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a negro '" + lhs_full_name + "'").c_str()); }
                } else if (rhs_expr.type == ExpresionAttribute::ID) {
                    Attributes *rhs_id_attr = symbolTable.search_symbol(rhs_expr.sval);
                    if (rhs_id_attr) {
                        if (rhs_id_attr->category == VARIABLE || rhs_id_attr->category == CONSTANT || rhs_id_attr->category == ARRAY_ELEMENT || rhs_id_attr->category == POINTER_V || rhs_id_attr->category == POINTER_C) {
                            if (holds_alternative<nullptr_t>(rhs_id_attr->value) && rhs_id_attr->type && rhs_id_attr->type->symbol_name != "pointer") {
                                 ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + string(rhs_id_attr->symbol_name.c_str()) + "' usada en asignación antes de ser inicializada.").c_str()); 
                            }
                            if (lhs_declared_type_name == rhs_id_attr->type->symbol_name) {
                                lhs_attr->value = rhs_id_attr->value;
                            } else if (lhs_declared_type_name == "manguita" && rhs_id_attr->type->symbol_name == "mango" && holds_alternative<int>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<float>(get<int>(rhs_id_attr->value));
                            } else if (lhs_declared_type_name == "manguangua" && rhs_id_attr->type->symbol_name == "mango" && holds_alternative<int>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<double>(get<int>(rhs_id_attr->value));
                            } else if (lhs_declared_type_name == "manguangua" && rhs_id_attr->type->symbol_name == "manguita" && holds_alternative<float>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<double>(get<float>(rhs_id_attr->value));
                            } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Error de tipo: no se puede asignar " + string(rhs_id_attr->type->symbol_name.c_str()) + " a " + lhs_declared_type_name + " '" + lhs_full_name + "'").c_str()); }
                        } else { ERROR_TYPE = TYPE_ERROR; yyerror(("El lado derecho de la asignación ('" + string(rhs_expr.sval) + "') no es una variable o constante evaluable.").c_str()); }
                    } else { ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + string(rhs_expr.sval) + "' no definida para asignación.").c_str()); }
                } else {
                    ERROR_TYPE = TYPE_ERROR; yyerror(("Tipo de asignación no soportado para miembro '" + lhs_declared_type_name + "' desde expresión '" + string(typeToString(rhs_expr.type)) + "'").c_str()); 
                }
                break;
            case 1: // Compound Assignment (+=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) + rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a mango '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) + rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) + static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a manguita '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Miembro manguita '" + lhs_full_name + "' no contiene un valor flotante para '+='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) + rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) + static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) + static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a manguangua '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Miembro manguangua '" + lhs_full_name + "' no contiene un valor double para '+='.").c_str()); }
                } else if (lhs_declared_type_name == "higuerote") {
                    if (rhs_expr.type == ExpresionAttribute::STRING && holds_alternative<string>(lhs_attr->value)) {
                        lhs_attr->value = get<string>(lhs_attr->value) + string(rhs_expr.sval);
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede concatenar " + string(typeToString(rhs_expr.type)) + " a higuerote '" + lhs_full_name + "'").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' no soportada para el tipo '" + lhs_declared_type_name + "' del miembro '" + lhs_full_name + "'").c_str()); }
                break;
            case 2: // Compound Assignment (-=)
                 if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) - rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de mango '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) - rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) - static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de manguita '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Miembro manguita '" + lhs_full_name + "' no contiene un valor flotante para '-='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) - rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) - static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) - static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de manguangua '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Miembro manguangua '" + lhs_full_name + "' no contiene un valor double para '-='.").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' no soportada para el tipo '" + lhs_declared_type_name + "' del miembro '" + lhs_full_name + "'").c_str()); }
                break;
            case 3: // Compound Assignment (*=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) * rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar mango '" + lhs_full_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) * rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) * static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar manguita '" + lhs_full_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Miembro manguita '" + lhs_full_name + "' no contiene un valor flotante para '*='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) * rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) * static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) * static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar manguangua '" + lhs_full_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Miembro manguangua '" + lhs_full_name + "' no contiene un valor double para '*='.").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' no soportada para el tipo '" + lhs_declared_type_name + "' del miembro '" + lhs_full_name + "'").c_str()); }
                break;
            default:
                yyerror("Operador de asignación desconocido internamente.");
                
        }
        // --- End copy of switch(op_type) for struct member ---
        // --- End Inlined execute_assignment_logic for struct member ---
    }
    | T_IDENTIFICADOR T_IZQCORCHE expresion T_DERCORCHE operadores_asignacion expresion {
        // array_var[index_expr] op rhs_expr
        Attributes* array_attr = symbolTable.search_symbol(string($1));
        const ExpresionAttribute& index_expr = $3;
        int op_type = $5;
        const ExpresionAttribute& rhs_expr = $6;
        Attributes* lhs_attr = nullptr; // This will be the array element's attributes

        if (!array_attr || array_attr->category != ARRAY) {
            ERROR_TYPE = NON_DEF_VAR;
            yyerror(string($1).c_str());
            
        }
        if (index_expr.type != ExpresionAttribute::INT) {
            ERROR_TYPE = INT_INDEX_ARRAY;
            yyerror(typeToString(index_expr.type)); // Pass the problematic type string
            
        }
        
        int index_val = index_expr.ival;
        if (!holds_alternative<int>(array_attr->value)) {
             ERROR_TYPE = SEMANTIC_TYPE; // Or a more specific error
             yyerror(("La variable array '" + string($1) + "' no tiene un tamaño entero almacenado.").c_str());
             
        }
        int array_size_val = get<int>(array_attr->value);

        if (index_val < 0 || index_val >= array_size_val) {
            string error_str = to_string(index_val);
            ERROR_TYPE = SEGMENTATION_FAULT;
            yyerror(error_str.c_str());
            
        }

        std::string element_name_str = std::string($1) + "[" + std::to_string(index_val) + "]";
        lhs_attr = symbolTable.search_symbol(element_name_str.c_str());

        if (!lhs_attr) {
            // This case implies array elements are not pre-inserted or there's an issue.
            // Your original code searches for them, so we assume they should exist.
            ERROR_TYPE = NON_DEF_VAR; // Or a more specific "ARRAY_ELEMENT_NOT_FOUND"
            yyerror(("Elemento de array '" + element_name_str + "' no encontrado en la tabla de símbolos.").c_str());
            
        }
        
        const std::string lhs_full_name = element_name_str;

        // --- Inlined execute_assignment_logic for array element ---
        if (!lhs_attr->type) {
            yyerror(("Error interno: El tipo del elemento de array '" + lhs_full_name + "' es nulo.").c_str());
            
        }
        string lhs_declared_type_name = lhs_attr->type->symbol_name;

        if (op_type != 0) { // Compound assignments
            if (holds_alternative<nullptr_t>(lhs_attr->value)) {
                ERROR_TYPE = NON_DEF_VAR;
                string op_str = (op_type == 1 ? "+=" : (op_type == 2 ? "-=" : (op_type == 3 ? "*=" : "OP_COMPUESTO")));
                yyerror(("Elemento de array '" + lhs_full_name + "' no inicializado antes de usarlo en operación '" + op_str + "'.").c_str());
                
            }
        }
        // (Repeat the switch(op_type) block from above, using lhs_attr, lhs_full_name, op_type, rhs_expr)
        // For brevity, I'm indicating to repeat it. In actual code, you'd copy-paste and adapt.
        // --- Start copy of switch(op_type) for array element ---
        switch (op_type) {
            case 0: // Simple Assignment (=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = rhs_expr.ival; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a mango '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = rhs_expr.fval; }
                    else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = static_cast<float>(rhs_expr.ival); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a manguita '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                    if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = rhs_expr.dval; }
                    else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = static_cast<double>(rhs_expr.fval); }
                    else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = static_cast<double>(rhs_expr.ival); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a manguangua '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "tas_claro") {
                    if (rhs_expr.type == ExpresionAttribute::BOOL) { lhs_attr->value = (bool)rhs_expr.ival; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a tas_claro '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "higuerote") {
                    if (rhs_expr.type == ExpresionAttribute::STRING) { lhs_attr->value = string(rhs_expr.sval); }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a higuerote '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "negro") {
                    if (rhs_expr.type == ExpresionAttribute::CHAR) { lhs_attr->value = rhs_expr.cval; }
                    else { ERROR_TYPE = TYPE_ERROR; yyerror(("Asignación inválida: no se puede asignar " + string(typeToString(rhs_expr.type)) + " a negro '" + lhs_full_name + "'").c_str()); }
                } else if (rhs_expr.type == ExpresionAttribute::ID) {
                    Attributes *rhs_id_attr = symbolTable.search_symbol(rhs_expr.sval);
                    if (rhs_id_attr) {
                        if (rhs_id_attr->category == VARIABLE || rhs_id_attr->category == CONSTANT || rhs_id_attr->category == ARRAY_ELEMENT || rhs_id_attr->category == POINTER_V || rhs_id_attr->category == POINTER_C) {
                            if (holds_alternative<nullptr_t>(rhs_id_attr->value) && rhs_id_attr->type && rhs_id_attr->type->symbol_name != "pointer") {
                                 ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + string(rhs_id_attr->symbol_name.c_str()) + "' usada en asignación antes de ser inicializada.").c_str()); 
                            }
                            if (lhs_declared_type_name == rhs_id_attr->type->symbol_name) {
                                lhs_attr->value = rhs_id_attr->value;
                            } else if (lhs_declared_type_name == "manguita" && rhs_id_attr->type->symbol_name == "mango" && holds_alternative<int>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<float>(get<int>(rhs_id_attr->value));
                            } else if (lhs_declared_type_name == "manguangua" && rhs_id_attr->type->symbol_name == "mango" && holds_alternative<int>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<double>(get<int>(rhs_id_attr->value));
                            } else if (lhs_declared_type_name == "manguangua" && rhs_id_attr->type->symbol_name == "manguita" && holds_alternative<float>(rhs_id_attr->value)) {
                                lhs_attr->value = static_cast<double>(get<float>(rhs_id_attr->value));
                            } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Error de tipo: no se puede asignar " + string(rhs_id_attr->type->symbol_name.c_str()) + " a " + lhs_declared_type_name + " '" + lhs_full_name + "'").c_str()); }
                        } else { ERROR_TYPE = TYPE_ERROR; yyerror(("El lado derecho de la asignación ('" + string(rhs_expr.sval) + "') no es una variable o constante evaluable.").c_str()); }
                    } else { ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + string(rhs_expr.sval) + "' no definida para asignación.").c_str()); }
                } else {
                    ERROR_TYPE = TYPE_ERROR; yyerror(("Tipo de asignación no soportado para elemento de array '" + lhs_declared_type_name + "' desde expresión '" + string(typeToString(rhs_expr.type)) + "'").c_str()); 
                }
                break;
            case 1: // Compound Assignment (+=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) + rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a mango '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) + rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) + static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a manguita '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Elemento de array manguita '" + lhs_full_name + "' no contiene un valor flotante para '+='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) + rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) + static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) + static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede sumar " + string(typeToString(rhs_expr.type)) + " a manguangua '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Elemento de array manguangua '" + lhs_full_name + "' no contiene un valor double para '+='.").c_str()); }
                } else if (lhs_declared_type_name == "higuerote") {
                    if (rhs_expr.type == ExpresionAttribute::STRING && holds_alternative<string>(lhs_attr->value)) {
                        lhs_attr->value = get<string>(lhs_attr->value) + string(rhs_expr.sval);
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' inválida: no se puede concatenar " + string(typeToString(rhs_expr.type)) + " a higuerote '" + lhs_full_name + "'").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '+=' no soportada para el tipo '" + lhs_declared_type_name + "' del elemento de array '" + lhs_full_name + "'").c_str()); }
                break;
            case 2: // Compound Assignment (-=)
                 if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) - rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de mango '" + lhs_full_name + "'").c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) - rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) - static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de manguita '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Elemento de array manguita '" + lhs_full_name + "' no contiene un valor flotante para '-='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) - rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) - static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) - static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' inválida: no se puede restar " + string(typeToString(rhs_expr.type)) + " de manguangua '" + lhs_full_name + "'").c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Elemento de array manguangua '" + lhs_full_name + "' no contiene un valor double para '-='.").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '-=' no soportada para el tipo '" + lhs_declared_type_name + "' del elemento de array '" + lhs_full_name + "'").c_str()); }
                break;
            case 3: // Compound Assignment (*=)
                if (lhs_declared_type_name == "mango") {
                    if (rhs_expr.type == ExpresionAttribute::INT && holds_alternative<int>(lhs_attr->value)) {
                        lhs_attr->value = get<int>(lhs_attr->value) * rhs_expr.ival;
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar mango '" + lhs_full_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                } else if (lhs_declared_type_name == "manguita") {
                    if (holds_alternative<float>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<float>(lhs_attr->value) * rhs_expr.fval; }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<float>(lhs_attr->value) * static_cast<float>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar manguita '" + lhs_full_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Elemento de array manguita '" + lhs_full_name + "' no contiene un valor flotante para '*='.").c_str()); }
                } else if (lhs_declared_type_name == "manguangua") {
                     if (holds_alternative<double>(lhs_attr->value)) {
                        if (rhs_expr.type == ExpresionAttribute::DOUBLE) { lhs_attr->value = get<double>(lhs_attr->value) * rhs_expr.dval; }
                        else if (rhs_expr.type == ExpresionAttribute::FLOAT) { lhs_attr->value = get<double>(lhs_attr->value) * static_cast<double>(rhs_expr.fval); }
                        else if (rhs_expr.type == ExpresionAttribute::INT) { lhs_attr->value = get<double>(lhs_attr->value) * static_cast<double>(rhs_expr.ival); }
                        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' inválida: no se puede multiplicar manguangua '" + lhs_full_name + "' por " + string(typeToString(rhs_expr.type))).c_str()); }
                    } else { ERROR_TYPE = TYPE_ERROR; yyerror(("Elemento de array manguangua '" + lhs_full_name + "' no contiene un valor double para '*='.").c_str()); }
                }
                else { ERROR_TYPE = TYPE_ERROR; yyerror(("Operación '*=' no soportada para el tipo '" + lhs_declared_type_name + "' del elemento de array '" + lhs_full_name + "'").c_str()); }
                break;
            default:
                yyerror("Operador de asignación desconocido internamente.");
                
        }
        // --- End copy of switch(op_type) for array element ---
        // --- End Inlined execute_assignment_logic for array element ---
        
        // The line `symbolTable.insert_symbol(lhs_attr->symbol_name, *lhs_attr);` might be redundant
        // if lhs_attr is a pointer to the actual attribute in the symbol table, as its value is modified directly.
        // However, if search_symbol returns a copy, or if you need to trigger some update mechanism, it might be needed.
        // For now, assuming direct modification of the pointed-to attribute is sufficient.
    }
    ;

valores_booleanos:
    T_SISA {
        $$.type = ExpresionAttribute::BOOL;
        $$.ival = 1;
    }
    | T_NOLSA {
        $$.type = ExpresionAttribute::BOOL;
        $$.ival = 0;
    }
    ;

expresion_apuntador:
    T_AKITOY T_IDENTIFICADOR
    | T_AKITOY T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR
    ;

expresion_nuevo:
    T_CEROKM tipos
    | expresion_nuevo T_IZQPAREN expresion T_DERPAREN
    ;

expresion:
    T_IDENTIFICADOR {
		$$.sval = $1; $$.type = ExpresionAttribute::ID;

		if (current_function_name != "") {
			Attributes* func_attr = symbolTable.search_symbol(current_function_name);
			if (current_function_parameters < func_attr->info.size()) { // Si hay parámetros.
				Attributes* param_attr = func_attr->info[current_function_parameters].second;
				Attributes* var_attr = symbolTable.search_symbol($1);
				if (param_attr->type->symbol_name != var_attr->type->symbol_name) {
					ERROR_TYPE = TYPE_ERROR;
					yyerror(param_attr->type->symbol_name.c_str());
					//exit(1);
				}
				current_function_parameters++;

			} else { // Excede la cantidad de parametros.
				ERROR_TYPE = FUNC_PARAM_EXCEEDED;
				yyerror(current_function_name.c_str());
				//exit(1);
			}
		}
	}
    | T_VALUE {
       if (current_array_name != "") {
            Attributes *array_attr = symbolTable.search_symbol(current_array_name.c_str());
            if (array_attr == nullptr) {
                yyerror("Array no definido");
                //exit(1);
            }

            if (array_attr->category != ARRAY) {  // Asumiendo que ARRAY es una nueva categoría
                yyerror("El identificador no es un array");
                //exit(1);
            }

            if (array_attr->category == VARIABLE) {
        		switch ($1.type) {
		            case ExpresionAttribute::INT: {
		                Attributes *elem = new Attributes();
		                elem->value = $1.ival;
		                // Se inserta en info como par {cadena, puntero a Attributes}
		                array_attr->info.push_back({string(""), elem});
		                break;
		            }
		            case ExpresionAttribute::FLOAT: {
		                Attributes *elem = new Attributes();
		                elem->value = $1.fval;
		                array_attr->info.push_back({string(""), elem});
		                break;
            		}
			        case ExpresionAttribute::DOUBLE: {
			            Attributes *elem = new Attributes();
			            elem->value = $1.dval;
			            array_attr->info.push_back({string(""), elem});
			            break;
			        }
			        case ExpresionAttribute::BOOL: {
			            Attributes *elem = new Attributes();
			            elem->value = (bool)$1.ival;
			            array_attr->info.push_back({string(""), elem});
			            break;
			        }
			        case ExpresionAttribute::STRING: {
			            Attributes *elem = new Attributes();
			            elem->value = string($1.sval);
			            array_attr->info.push_back({string(""), elem});
			            break;
			        }
			        case ExpresionAttribute::CHAR: {
			            Attributes *elem = new Attributes();
			            elem->value = $1.cval; // Asume que $1.sval es un string y toma el primer carácter
			            array_attr->info.push_back({string(""), elem});
			            break;
			        }
			        case ExpresionAttribute::POINTER: {
			            Attributes *elem = new Attributes();
			            elem->value = nullptr; // Manejar punteros según sea necesario
			            array_attr->info.push_back({string(""), elem});
			            break;
			        }
			        default:
			            yyerror("Tipo no soportado para agregar al array");
			            //exit(1);
				}
            } else {
                yyerror("El identificador no es un array");
                //exit(1);
            }
		}

		if (current_function_name != "") {
			Attributes* func_attr = symbolTable.search_symbol(current_function_name);
			if (current_function_parameters < func_attr->info.size()) { // Si hay parámetros.
				Attributes* param_attr = func_attr->info[current_function_parameters].second;
				if (param_attr->type->symbol_name != typeToString($1.type)) {
					ERROR_TYPE = TYPE_ERROR;
					yyerror(param_attr->type->symbol_name.c_str());
					//exit(1);
				}
				current_function_parameters++;

			} else { // Excede la cantidad de parametros.
				ERROR_TYPE = FUNC_PARAM_EXCEEDED;
				string error_message = "Error en la función '" + current_function_name + "': Excede la cantidad de parámetros.";
				yyerror(error_message.c_str());
				//exit(1);
			}
		}
		
        switch($1.type) {
            case ExpresionAttribute::INT:
                $$.ival = $1.ival;
                break;
            case ExpresionAttribute::FLOAT:
                $$.fval = $1.fval;
                break;
            case ExpresionAttribute::DOUBLE:
                $$.dval = $1.dval;
                break;
            case ExpresionAttribute::BOOL:
                $$.ival = (bool)$1.ival; // Asumiendo que se almacena en ival
                break;
            case ExpresionAttribute::STRING:
                $$.sval = $1.sval; // Convierte a std::string
                break;
            case ExpresionAttribute::CHAR:
                $$.ival = $1.cval; // Asume que $1.sval es un string y toma el primer carácter
                break;
            case ExpresionAttribute::POINTER:
                $$.ival = 0; // Manejar punteros según sea necesario
                break;
            default:
                yyerror("Tipo no soportado");
                //exit(1);
        }
    }
    | T_PELABOLA
    | T_IZQPAREN expresion T_DERPAREN { $$ = $2; }
    | valores_booleanos { $$ = $1; }
    | expresion_apuntador 
    | expresion_nuevo
    | arreglo
    | T_NELSON expresion {
        ExpresionAttribute _op_not = $2;
        bool val_not;

        // Evaluate the operand
        if (_op_not.type == ExpresionAttribute::BOOL) {
            val_not = (bool)_op_not.ival;
        } else if (_op_not.type == ExpresionAttribute::ID) {
            Attributes* var_attr = symbolTable.search_symbol(_op_not.sval);
            if (!var_attr) { 
                ERROR_TYPE = NON_DEF_VAR; 
                yyerror(_op_not.sval); 
                 
            }
            if (!var_attr->type || var_attr->type->symbol_name != "tas_claro") {
                ERROR_TYPE = TYPE_ERROR; 
                std::string err_msg = "Operación 'Nelson (!)' requiere operando booleano (tas_claro), pero '" + std::string(_op_not.sval) + "' es de tipo '" + (var_attr->type ? var_attr->type->symbol_name : "desconocido") + "'.";
                yyerror(err_msg.c_str()); 
                
            }
            if (std::holds_alternative<bool>(var_attr->value)) {
                val_not = std::get<bool>(var_attr->value);
            } else if (std::holds_alternative<std::nullptr_t>(var_attr->value)) {
                ERROR_TYPE = NON_DEF_VAR;
                std::string err_msg = "Variable 'tas_claro' '" + std::string(_op_not.sval) + "' no inicializada y usada en operación 'Nelson (!)'.";
                yyerror(err_msg.c_str());
                
            } 
            else {
                ERROR_TYPE = TYPE_ERROR; 
                std::string err_msg = "Variable 'tas_claro' '" + std::string(_op_not.sval) + "' no contiene un valor booleano válido para 'Nelson (!)'.";
                yyerror(err_msg.c_str()); 
                
            }
        } else {
            ERROR_TYPE = TYPE_ERROR; 
            std::string err_msg = "Operación 'Nelson (!)' requiere operando booleano, pero se recibió tipo '" + std::string(typeToString(_op_not.type)) + "'.";
            yyerror(err_msg.c_str()); 
            
        }

        $$.type = ExpresionAttribute::BOOL;
        $$.ival = !val_not ? 1 : 0;
    }
    | T_OPRESTA expresion %prec T_OPRESTA {
        if ($2.type == ExpresionAttribute::INT) {
            $$.type = ExpresionAttribute::INT;
            $$.ival = -$2.ival;
        } else if ($2.type == ExpresionAttribute::FLOAT) {
            $$.type = ExpresionAttribute::FLOAT;
            $$.fval = -$2.fval;
        } else if ($2.type == ExpresionAttribute::DOUBLE) {
            $$.type = ExpresionAttribute::DOUBLE;
            $$.fval = -$2.dval;
        }
        else {
            yyerror("Operación de signo negativo no soportada para este tipo");
            //exit(1);
        }
    }
    | expresion T_FLECHA expresion
    | expresion T_OPSUMA expresion {
        if($1.type == ExpresionAttribute::INT && $3.type == ExpresionAttribute::INT){
            $$.type = ExpresionAttribute::INT;
            $$.ival = $1.ival + $3.ival;
        }

        if($1.type == ExpresionAttribute::FLOAT && $3.type == ExpresionAttribute::INT){
            $$.type = ExpresionAttribute::FLOAT;
            $$.fval = (float)($1.fval + $3.ival);
        }

        if($1.type == ExpresionAttribute::INT && $3.type == ExpresionAttribute::FLOAT){
            $$.type = ExpresionAttribute::FLOAT;
            $$.fval = (float)($1.ival + $3.fval);
        }

        if($1.type == ExpresionAttribute::ID && $3.type == ExpresionAttribute::ID){
            Attributes *var1 = symbolTable.search_symbol($1.sval);
            Attributes *var2 = symbolTable.search_symbol($3.sval);

            $$.type = ExpresionAttribute::INT;
            $$.ival = get<int>(var1->value) + get<int>(var2->value);
        }       
    }
    | expresion T_OPRESTA expresion
    | expresion T_OPMULT expresion
    | expresion T_OPDIVDECIMAL expresion
    | expresion T_OPDIVENTERA expresion
    | expresion T_OPMOD expresion
    | expresion T_OPEXP expresion
    | expresion T_OPIGUAL expresion {
        ExpresionAttribute _left_op_eq = $1;
        ExpresionAttribute _right_op_eq = $3;
        
        double num_l_eq = 0, num_r_eq = 0;
        char char_l_eq = 0, char_r_eq = 0;
        std::string str_l_eq, str_r_eq;
        bool bool_l_eq = false, bool_r_eq = false;
        ExpresionAttribute::Type type_l_eq, type_r_eq;

        // Resolve Left Operand
        if (_left_op_eq.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_left_op_eq.sval);
            if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_eq.sval);  }
            if (!attr->type) { yyerror("Error interno: Atributo ID sin tipo.");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { 
                ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + std::string(_left_op_eq.sval) + "' no inicializada.").c_str());  
            }
            type_l_eq = stringToType(attr->type->symbol_name);
            if (type_l_eq == ExpresionAttribute::INT) num_l_eq = std::get<int>(attr->value);
            else if (type_l_eq == ExpresionAttribute::FLOAT) num_l_eq = std::get<float>(attr->value);
            else if (type_l_eq == ExpresionAttribute::DOUBLE) num_l_eq = std::get<double>(attr->value);
            else if (type_l_eq == ExpresionAttribute::CHAR) char_l_eq = std::get<char>(attr->value);
            else if (type_l_eq == ExpresionAttribute::STRING) str_l_eq = std::get<std::string>(attr->value);
            else if (type_l_eq == ExpresionAttribute::BOOL && attr->type->symbol_name == "tas_claro") bool_l_eq = std::get<bool>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipo '" + attr->type->symbol_name + "' no soportado para '=='.").c_str());  }
        } else {
            type_l_eq = _left_op_eq.type;
            if (type_l_eq == ExpresionAttribute::INT) num_l_eq = _left_op_eq.ival;
            else if (type_l_eq == ExpresionAttribute::FLOAT) num_l_eq = _left_op_eq.fval;
            else if (type_l_eq == ExpresionAttribute::DOUBLE) num_l_eq = _left_op_eq.dval;
            else if (type_l_eq == ExpresionAttribute::CHAR) char_l_eq = _left_op_eq.cval;
            else if (type_l_eq == ExpresionAttribute::STRING) str_l_eq = std::string(_left_op_eq.sval);
            else if (type_l_eq == ExpresionAttribute::BOOL) bool_l_eq = (bool)_left_op_eq.ival;
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipo '" + std::string(typeToString(type_l_eq)) + "' no soportado para '=='.").c_str());  }
        }

        // Resolve Right Operand
        if (_right_op_eq.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_right_op_eq.sval);
            if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_eq.sval);  }
            if (!attr->type) { yyerror("Error interno: Atributo ID sin tipo.");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { 
                ERROR_TYPE = NON_DEF_VAR; yyerror(("Variable '" + std::string(_right_op_eq.sval) + "' no inicializada.").c_str());  
            }
            type_r_eq = stringToType(attr->type->symbol_name);
            if (type_r_eq == ExpresionAttribute::INT) num_r_eq = std::get<int>(attr->value);
            else if (type_r_eq == ExpresionAttribute::FLOAT) num_r_eq = std::get<float>(attr->value);
            else if (type_r_eq == ExpresionAttribute::DOUBLE) num_r_eq = std::get<double>(attr->value);
            else if (type_r_eq == ExpresionAttribute::CHAR) char_r_eq = std::get<char>(attr->value);
            else if (type_r_eq == ExpresionAttribute::STRING) str_r_eq = std::get<std::string>(attr->value);
            else if (type_r_eq == ExpresionAttribute::BOOL && attr->type->symbol_name == "tas_claro") bool_r_eq = std::get<bool>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipo '" + attr->type->symbol_name + "' no soportado para '=='.").c_str());  }
        } else {
            type_r_eq = _right_op_eq.type;
            if (type_r_eq == ExpresionAttribute::INT) num_r_eq = _right_op_eq.ival;
            else if (type_r_eq == ExpresionAttribute::FLOAT) num_r_eq = _right_op_eq.fval;
            else if (type_r_eq == ExpresionAttribute::DOUBLE) num_r_eq = _right_op_eq.dval;
            else if (type_r_eq == ExpresionAttribute::CHAR) char_r_eq = _right_op_eq.cval;
            else if (type_r_eq == ExpresionAttribute::STRING) str_r_eq = std::string(_right_op_eq.sval);
            else if (type_r_eq == ExpresionAttribute::BOOL) bool_r_eq = (bool)_right_op_eq.ival;
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipo '" + std::string(typeToString(type_r_eq)) + "' no soportado para '=='.").c_str());  }
        }
        
        bool _res_eq = false;
        if ((type_l_eq == ExpresionAttribute::INT || type_l_eq == ExpresionAttribute::FLOAT || type_l_eq == ExpresionAttribute::DOUBLE) &&
            (type_r_eq == ExpresionAttribute::INT || type_r_eq == ExpresionAttribute::FLOAT || type_r_eq == ExpresionAttribute::DOUBLE)) {
            _res_eq = (num_l_eq == num_r_eq);
        } else if (type_l_eq == ExpresionAttribute::CHAR && type_r_eq == ExpresionAttribute::CHAR) {
            _res_eq = (char_l_eq == char_r_eq);
        } else if (type_l_eq == ExpresionAttribute::STRING && type_r_eq == ExpresionAttribute::STRING) {
            _res_eq = (str_l_eq == str_r_eq);
        } else if (type_l_eq == ExpresionAttribute::BOOL && type_r_eq == ExpresionAttribute::BOOL) {
            _res_eq = (bool_l_eq == bool_r_eq);
        } else {
            ERROR_TYPE = TYPE_ERROR; 
            yyerror(("Tipos incompatibles para '==': " + std::string(typeToString(type_l_eq)) + " y " + std::string(typeToString(type_r_eq))).c_str()); 
            
        }
        $$.type = ExpresionAttribute::BOOL; $$.ival = _res_eq ? 1 : 0;
    }
    | expresion T_OPDIFERENTE expresion {
        ExpresionAttribute _left_op_ne = $1;
        ExpresionAttribute _right_op_ne = $3;
        double num_l_ne = 0, num_r_ne = 0; char char_l_ne = 0, char_r_ne = 0; std::string str_l_ne, str_r_ne; bool bool_l_ne = false, bool_r_ne = false;
        ExpresionAttribute::Type type_l_ne, type_r_ne;

        if (_left_op_ne.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_left_op_ne.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_ne.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  } 
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_left_op_ne.sval) + "' no init.").c_str());  }
            type_l_ne = stringToType(attr->type->symbol_name);
            if (type_l_ne == ExpresionAttribute::INT) num_l_ne = std::get<int>(attr->value); else if (type_l_ne == ExpresionAttribute::FLOAT) num_l_ne = std::get<float>(attr->value); else if (type_l_ne == ExpresionAttribute::DOUBLE) num_l_ne = std::get<double>(attr->value);
            else if (type_l_ne == ExpresionAttribute::CHAR) char_l_ne = std::get<char>(attr->value); else if (type_l_ne == ExpresionAttribute::STRING) str_l_ne = std::get<std::string>(attr->value);
            else if (type_l_ne == ExpresionAttribute::BOOL && attr->type->symbol_name == "tas_claro") bool_l_ne = std::get<bool>(attr->value); else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '!='.").c_str());  }
        } else {
            type_l_ne = _left_op_ne.type;
            if (type_l_ne == ExpresionAttribute::INT) num_l_ne = _left_op_ne.ival; else if (type_l_ne == ExpresionAttribute::FLOAT) num_l_ne = _left_op_ne.fval; else if (type_l_ne == ExpresionAttribute::DOUBLE) num_l_ne = _left_op_ne.dval;
            else if (type_l_ne == ExpresionAttribute::CHAR) char_l_ne = _left_op_ne.cval; else if (type_l_ne == ExpresionAttribute::STRING) str_l_ne = std::string(_left_op_ne.sval);
            else if (type_l_ne == ExpresionAttribute::BOOL) bool_l_ne = (bool)_left_op_ne.ival; else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_l_ne)) + "' no sop. para '!='.").c_str());  }
        }
        if (_right_op_ne.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_right_op_ne.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_ne.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_right_op_ne.sval) + "' no init.").c_str());  }
            type_r_ne = stringToType(attr->type->symbol_name);
            if (type_r_ne == ExpresionAttribute::INT) num_r_ne = std::get<int>(attr->value); else if (type_r_ne == ExpresionAttribute::FLOAT) num_r_ne = std::get<float>(attr->value); else if (type_r_ne == ExpresionAttribute::DOUBLE) num_r_ne = std::get<double>(attr->value);
            else if (type_r_ne == ExpresionAttribute::CHAR) char_r_ne = std::get<char>(attr->value); else if (type_r_ne == ExpresionAttribute::STRING) str_r_ne = std::get<std::string>(attr->value);
            else if (type_r_ne == ExpresionAttribute::BOOL && attr->type->symbol_name == "tas_claro") bool_r_ne = std::get<bool>(attr->value); else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '!='.").c_str());  }
        } else {
            type_r_ne = _right_op_ne.type;
            if (type_r_ne == ExpresionAttribute::INT) num_r_ne = _right_op_ne.ival; else if (type_r_ne == ExpresionAttribute::FLOAT) num_r_ne = _right_op_ne.fval; else if (type_r_ne == ExpresionAttribute::DOUBLE) num_r_ne = _right_op_ne.dval;
            else if (type_r_ne == ExpresionAttribute::CHAR) char_r_ne = _right_op_ne.cval; else if (type_r_ne == ExpresionAttribute::STRING) str_r_ne = std::string(_right_op_ne.sval);
            else if (type_r_ne == ExpresionAttribute::BOOL) bool_r_ne = (bool)_right_op_ne.ival; else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_r_ne)) + "' no sop. para '!='.").c_str());  }
        }
        bool _res_ne = false;
        if ((type_l_ne == ExpresionAttribute::INT || type_l_ne == ExpresionAttribute::FLOAT || type_l_ne == ExpresionAttribute::DOUBLE) &&
            (type_r_ne == ExpresionAttribute::INT || type_r_ne == ExpresionAttribute::FLOAT || type_r_ne == ExpresionAttribute::DOUBLE)) { _res_ne = (num_l_ne != num_r_ne); }
        else if (type_l_ne == ExpresionAttribute::CHAR && type_r_ne == ExpresionAttribute::CHAR) { _res_ne = (char_l_ne != char_r_ne); }
        else if (type_l_ne == ExpresionAttribute::STRING && type_r_ne == ExpresionAttribute::STRING) { _res_ne = (str_l_ne != str_r_ne); }
        else if (type_l_ne == ExpresionAttribute::BOOL && type_r_ne == ExpresionAttribute::BOOL) { _res_ne = (bool_l_ne != bool_r_ne); }
        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipos incompatibles para '!=': " + std::string(typeToString(type_l_ne)) + " y " + std::string(typeToString(type_r_ne))).c_str());  }
        $$.type = ExpresionAttribute::BOOL; $$.ival = _res_ne ? 1 : 0;
    }
    | expresion T_OPMAYOR expresion {
        ExpresionAttribute _left_op_gt = $1; ExpresionAttribute _right_op_gt = $3; double num_l_gt = 0, num_r_gt = 0; char char_l_gt = 0, char_r_gt = 0; std::string str_l_gt, str_r_gt;
        ExpresionAttribute::Type type_l_gt, type_r_gt;
        if (_left_op_gt.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_left_op_gt.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_gt.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_left_op_gt.sval) + "' no init.").c_str());  }
            type_l_gt = stringToType(attr->type->symbol_name);
            if (type_l_gt == ExpresionAttribute::INT) num_l_gt = std::get<int>(attr->value); else if (type_l_gt == ExpresionAttribute::FLOAT) num_l_gt = std::get<float>(attr->value); else if (type_l_gt == ExpresionAttribute::DOUBLE) num_l_gt = std::get<double>(attr->value);
            else if (type_l_gt == ExpresionAttribute::CHAR) char_l_gt = std::get<char>(attr->value); else if (type_l_gt == ExpresionAttribute::STRING) str_l_gt = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '>'.").c_str());  }
        } else {
            type_l_gt = _left_op_gt.type;
            if (type_l_gt == ExpresionAttribute::INT) num_l_gt = _left_op_gt.ival; else if (type_l_gt == ExpresionAttribute::FLOAT) num_l_gt = _left_op_gt.fval; else if (type_l_gt == ExpresionAttribute::DOUBLE) num_l_gt = _left_op_gt.dval;
            else if (type_l_gt == ExpresionAttribute::CHAR) char_l_gt = _left_op_gt.cval; else if (type_l_gt == ExpresionAttribute::STRING) str_l_gt = std::string(_left_op_gt.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_l_gt)) + "' no sop. para '>'.").c_str());  }
        }
        if (_right_op_gt.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_right_op_gt.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_gt.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_right_op_gt.sval) + "' no init.").c_str());  }
            type_r_gt = stringToType(attr->type->symbol_name);
            if (type_r_gt == ExpresionAttribute::INT) num_r_gt = std::get<int>(attr->value); else if (type_r_gt == ExpresionAttribute::FLOAT) num_r_gt = std::get<float>(attr->value); else if (type_r_gt == ExpresionAttribute::DOUBLE) num_r_gt = std::get<double>(attr->value);
            else if (type_r_gt == ExpresionAttribute::CHAR) char_r_gt = std::get<char>(attr->value); else if (type_r_gt == ExpresionAttribute::STRING) str_r_gt = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '>'.").c_str());  }
        } else {
            type_r_gt = _right_op_gt.type;
            if (type_r_gt == ExpresionAttribute::INT) num_r_gt = _right_op_gt.ival; else if (type_r_gt == ExpresionAttribute::FLOAT) num_r_gt = _right_op_gt.fval; else if (type_r_gt == ExpresionAttribute::DOUBLE) num_r_gt = _right_op_gt.dval;
            else if (type_r_gt == ExpresionAttribute::CHAR) char_r_gt = _right_op_gt.cval; else if (type_r_gt == ExpresionAttribute::STRING) str_r_gt = std::string(_right_op_gt.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_r_gt)) + "' no sop. para '>'.").c_str());  }
        }
        bool _res_gt = false;
        if ((type_l_gt == ExpresionAttribute::INT || type_l_gt == ExpresionAttribute::FLOAT || type_l_gt == ExpresionAttribute::DOUBLE) &&
            (type_r_gt == ExpresionAttribute::INT || type_r_gt == ExpresionAttribute::FLOAT || type_r_gt == ExpresionAttribute::DOUBLE)) { _res_gt = (num_l_gt > num_r_gt); }
        else if (type_l_gt == ExpresionAttribute::CHAR && type_r_gt == ExpresionAttribute::CHAR) { _res_gt = (char_l_gt > char_r_gt); }
        else if (type_l_gt == ExpresionAttribute::STRING && type_r_gt == ExpresionAttribute::STRING) { _res_gt = (str_l_gt > str_r_gt); }
        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipos incompatibles para '>': " + std::string(typeToString(type_l_gt)) + " y " + std::string(typeToString(type_r_gt))).c_str());  }
        $$.type = ExpresionAttribute::BOOL; $$.ival = _res_gt ? 1 : 0;
    }
    | expresion T_OPMAYORIGUAL expresion {
        ExpresionAttribute _left_op_ge = $1; ExpresionAttribute _right_op_ge = $3; double num_l_ge = 0, num_r_ge = 0; char char_l_ge = 0, char_r_ge = 0; std::string str_l_ge, str_r_ge;
        ExpresionAttribute::Type type_l_ge, type_r_ge;
        if (_left_op_ge.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_left_op_ge.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_ge.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_left_op_ge.sval) + "' no init.").c_str());  }
            type_l_ge = stringToType(attr->type->symbol_name);
            if (type_l_ge == ExpresionAttribute::INT) num_l_ge = std::get<int>(attr->value); else if (type_l_ge == ExpresionAttribute::FLOAT) num_l_ge = std::get<float>(attr->value); else if (type_l_ge == ExpresionAttribute::DOUBLE) num_l_ge = std::get<double>(attr->value);
            else if (type_l_ge == ExpresionAttribute::CHAR) char_l_ge = std::get<char>(attr->value); else if (type_l_ge == ExpresionAttribute::STRING) str_l_ge = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '>='.").c_str());  }
        } else {
            type_l_ge = _left_op_ge.type;
            if (type_l_ge == ExpresionAttribute::INT) num_l_ge = _left_op_ge.ival; else if (type_l_ge == ExpresionAttribute::FLOAT) num_l_ge = _left_op_ge.fval; else if (type_l_ge == ExpresionAttribute::DOUBLE) num_l_ge = _left_op_ge.dval;
            else if (type_l_ge == ExpresionAttribute::CHAR) char_l_ge = _left_op_ge.cval; else if (type_l_ge == ExpresionAttribute::STRING) str_l_ge = std::string(_left_op_ge.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_l_ge)) + "' no sop. para '>='.").c_str());  }
        }
        if (_right_op_ge.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_right_op_ge.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_ge.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_right_op_ge.sval) + "' no init.").c_str());  }
            type_r_ge = stringToType(attr->type->symbol_name);
            if (type_r_ge == ExpresionAttribute::INT) num_r_ge = std::get<int>(attr->value); else if (type_r_ge == ExpresionAttribute::FLOAT) num_r_ge = std::get<float>(attr->value); else if (type_r_ge == ExpresionAttribute::DOUBLE) num_r_ge = std::get<double>(attr->value);
            else if (type_r_ge == ExpresionAttribute::CHAR) char_r_ge = std::get<char>(attr->value); else if (type_r_ge == ExpresionAttribute::STRING) str_r_ge = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '>='.").c_str());  }
        } else {
            type_r_ge = _right_op_ge.type;
            if (type_r_ge == ExpresionAttribute::INT) num_r_ge = _right_op_ge.ival; else if (type_r_ge == ExpresionAttribute::FLOAT) num_r_ge = _right_op_ge.fval; else if (type_r_ge == ExpresionAttribute::DOUBLE) num_r_ge = _right_op_ge.dval;
            else if (type_r_ge == ExpresionAttribute::CHAR) char_r_ge = _right_op_ge.cval; else if (type_r_ge == ExpresionAttribute::STRING) str_r_ge = std::string(_right_op_ge.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_r_ge)) + "' no sop. para '>='.").c_str());  }
        }
        bool _res_ge = false;
        if ((type_l_ge == ExpresionAttribute::INT || type_l_ge == ExpresionAttribute::FLOAT || type_l_ge == ExpresionAttribute::DOUBLE) &&
            (type_r_ge == ExpresionAttribute::INT || type_r_ge == ExpresionAttribute::FLOAT || type_r_ge == ExpresionAttribute::DOUBLE)) { _res_ge = (num_l_ge >= num_r_ge); }
        else if (type_l_ge == ExpresionAttribute::CHAR && type_r_ge == ExpresionAttribute::CHAR) { _res_ge = (char_l_ge >= char_r_ge); }
        else if (type_l_ge == ExpresionAttribute::STRING && type_r_ge == ExpresionAttribute::STRING) { _res_ge = (str_l_ge >= str_r_ge); }
        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipos incompatibles para '>=': " + std::string(typeToString(type_l_ge)) + " y " + std::string(typeToString(type_r_ge))).c_str());  }
        $$.type = ExpresionAttribute::BOOL; $$.ival = _res_ge ? 1 : 0;
    }
    | expresion T_OPMENOR expresion {
        ExpresionAttribute _left_op_lt = $1; ExpresionAttribute _right_op_lt = $3; double num_l_lt = 0, num_r_lt = 0; char char_l_lt = 0, char_r_lt = 0; std::string str_l_lt, str_r_lt;
        ExpresionAttribute::Type type_l_lt, type_r_lt;
        if (_left_op_lt.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_left_op_lt.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_lt.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_left_op_lt.sval) + "' no init.").c_str());  }
            type_l_lt = stringToType(attr->type->symbol_name);
            if (type_l_lt == ExpresionAttribute::INT) num_l_lt = std::get<int>(attr->value); else if (type_l_lt == ExpresionAttribute::FLOAT) num_l_lt = std::get<float>(attr->value); else if (type_l_lt == ExpresionAttribute::DOUBLE) num_l_lt = std::get<double>(attr->value);
            else if (type_l_lt == ExpresionAttribute::CHAR) char_l_lt = std::get<char>(attr->value); else if (type_l_lt == ExpresionAttribute::STRING) str_l_lt = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '<'.").c_str());  }
        } else {
            type_l_lt = _left_op_lt.type;
            if (type_l_lt == ExpresionAttribute::INT) num_l_lt = _left_op_lt.ival; else if (type_l_lt == ExpresionAttribute::FLOAT) num_l_lt = _left_op_lt.fval; else if (type_l_lt == ExpresionAttribute::DOUBLE) num_l_lt = _left_op_lt.dval;
            else if (type_l_lt == ExpresionAttribute::CHAR) char_l_lt = _left_op_lt.cval; else if (type_l_lt == ExpresionAttribute::STRING) str_l_lt = std::string(_left_op_lt.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_l_lt)) + "' no sop. para '<'.").c_str());  }
        }
        if (_right_op_lt.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_right_op_lt.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_lt.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_right_op_lt.sval) + "' no init.").c_str());  }
            type_r_lt = stringToType(attr->type->symbol_name);
            if (type_r_lt == ExpresionAttribute::INT) num_r_lt = std::get<int>(attr->value); else if (type_r_lt == ExpresionAttribute::FLOAT) num_r_lt = std::get<float>(attr->value); else if (type_r_lt == ExpresionAttribute::DOUBLE) num_r_lt = std::get<double>(attr->value);
            else if (type_r_lt == ExpresionAttribute::CHAR) char_r_lt = std::get<char>(attr->value); else if (type_r_lt == ExpresionAttribute::STRING) str_r_lt = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '<'.").c_str());  }
        } else {
            type_r_lt = _right_op_lt.type;
            if (type_r_lt == ExpresionAttribute::INT) num_r_lt = _right_op_lt.ival; else if (type_r_lt == ExpresionAttribute::FLOAT) num_r_lt = _right_op_lt.fval; else if (type_r_lt == ExpresionAttribute::DOUBLE) num_r_lt = _right_op_lt.dval;
            else if (type_r_lt == ExpresionAttribute::CHAR) char_r_lt = _right_op_lt.cval; else if (type_r_lt == ExpresionAttribute::STRING) str_r_lt = std::string(_right_op_lt.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_r_lt)) + "' no sop. para '<'.").c_str());  }
        }
        bool _res_lt = false;
        if ((type_l_lt == ExpresionAttribute::INT || type_l_lt == ExpresionAttribute::FLOAT || type_l_lt == ExpresionAttribute::DOUBLE) &&
            (type_r_lt == ExpresionAttribute::INT || type_r_lt == ExpresionAttribute::FLOAT || type_r_lt == ExpresionAttribute::DOUBLE)) { _res_lt = (num_l_lt < num_r_lt); }
        else if (type_l_lt == ExpresionAttribute::CHAR && type_r_lt == ExpresionAttribute::CHAR) { _res_lt = (char_l_lt < char_r_lt); }
        else if (type_l_lt == ExpresionAttribute::STRING && type_r_lt == ExpresionAttribute::STRING) { _res_lt = (str_l_lt < str_r_lt); }
        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipos incompatibles para '<': " + std::string(typeToString(type_l_lt)) + " y " + std::string(typeToString(type_r_lt))).c_str());  }
        $$.type = ExpresionAttribute::BOOL; $$.ival = _res_lt ? 1 : 0;
    }
    | expresion T_OPMENORIGUAL expresion {
        ExpresionAttribute _left_op_le = $1; ExpresionAttribute _right_op_le = $3; double num_l_le = 0, num_r_le = 0; char char_l_le = 0, char_r_le = 0; std::string str_l_le, str_r_le;
        ExpresionAttribute::Type type_l_le, type_r_le;
        if (_left_op_le.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_left_op_le.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_le.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_left_op_le.sval) + "' no init.").c_str());  }
            type_l_le = stringToType(attr->type->symbol_name);
            if (type_l_le == ExpresionAttribute::INT) num_l_le = std::get<int>(attr->value); else if (type_l_le == ExpresionAttribute::FLOAT) num_l_le = std::get<float>(attr->value); else if (type_l_le == ExpresionAttribute::DOUBLE) num_l_le = std::get<double>(attr->value);
            else if (type_l_le == ExpresionAttribute::CHAR) char_l_le = std::get<char>(attr->value); else if (type_l_le == ExpresionAttribute::STRING) str_l_le = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '<='.").c_str());  }
        } else {
            type_l_le = _left_op_le.type;
            if (type_l_le == ExpresionAttribute::INT) num_l_le = _left_op_le.ival; else if (type_l_le == ExpresionAttribute::FLOAT) num_l_le = _left_op_le.fval; else if (type_l_le == ExpresionAttribute::DOUBLE) num_l_le = _left_op_le.dval;
            else if (type_l_le == ExpresionAttribute::CHAR) char_l_le = _left_op_le.cval; else if (type_l_le == ExpresionAttribute::STRING) str_l_le = std::string(_left_op_le.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_l_le)) + "' no sop. para '<='.").c_str());  }
        }
        if (_right_op_le.type == ExpresionAttribute::ID) {
            Attributes* attr = symbolTable.search_symbol(_right_op_le.sval); if (!attr) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_le.sval);  } if (!attr->type) { yyerror("E: Attr ID sin tipo");  }
            if (std::holds_alternative<std::nullptr_t>(attr->value) && attr->type->symbol_name != "pointer") { ERROR_TYPE = NON_DEF_VAR; yyerror(("V '" + std::string(_right_op_le.sval) + "' no init.").c_str());  }
            type_r_le = stringToType(attr->type->symbol_name);
            if (type_r_le == ExpresionAttribute::INT) num_r_le = std::get<int>(attr->value); else if (type_r_le == ExpresionAttribute::FLOAT) num_r_le = std::get<float>(attr->value); else if (type_r_le == ExpresionAttribute::DOUBLE) num_r_le = std::get<double>(attr->value);
            else if (type_r_le == ExpresionAttribute::CHAR) char_r_le = std::get<char>(attr->value); else if (type_r_le == ExpresionAttribute::STRING) str_r_le = std::get<std::string>(attr->value);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + attr->type->symbol_name + "' no sop. para '<='.").c_str());  }
        } else {
            type_r_le = _right_op_le.type;
            if (type_r_le == ExpresionAttribute::INT) num_r_le = _right_op_le.ival; else if (type_r_le == ExpresionAttribute::FLOAT) num_r_le = _right_op_le.fval; else if (type_r_le == ExpresionAttribute::DOUBLE) num_r_le = _right_op_le.dval;
            else if (type_r_le == ExpresionAttribute::CHAR) char_r_le = _right_op_le.cval; else if (type_r_le == ExpresionAttribute::STRING) str_r_le = std::string(_right_op_le.sval);
            else { ERROR_TYPE = TYPE_ERROR; yyerror(("T '" + std::string(typeToString(type_r_le)) + "' no sop. para '<='.").c_str());  }
        }
        bool _res_le = false;
        if ((type_l_le == ExpresionAttribute::INT || type_l_le == ExpresionAttribute::FLOAT || type_l_le == ExpresionAttribute::DOUBLE) &&
            (type_r_le == ExpresionAttribute::INT || type_r_le == ExpresionAttribute::FLOAT || type_r_le == ExpresionAttribute::DOUBLE)) { _res_le = (num_l_le <= num_r_le); }
        else if (type_l_le == ExpresionAttribute::CHAR && type_r_le == ExpresionAttribute::CHAR) { _res_le = (char_l_le <= char_r_le); }
        else if (type_l_le == ExpresionAttribute::STRING && type_r_le == ExpresionAttribute::STRING) { _res_le = (str_l_le <= str_r_le); }
        else { ERROR_TYPE = TYPE_ERROR; yyerror(("Tipos incompatibles para '<=': " + std::string(typeToString(type_l_le)) + " y " + std::string(typeToString(type_r_le))).c_str());  }
        $$.type = ExpresionAttribute::BOOL; $$.ival = _res_le ? 1 : 0;
    }
    | expresion T_OSEA expresion { // Logical OR (||)
        bool b1_or, b2_or;
        ExpresionAttribute _left_op_or = $1;
        ExpresionAttribute _right_op_or = $3;

        // Evaluate $1
        if (_left_op_or.type == ExpresionAttribute::BOOL) {
            b1_or = (bool)_left_op_or.ival;
        } else if (_left_op_or.type == ExpresionAttribute::ID) {
            Attributes* var_attr1 = symbolTable.search_symbol(_left_op_or.sval);
            if (!var_attr1) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_or.sval);  }
            if (!var_attr1->type || var_attr1->type->symbol_name != "tas_claro") {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Operación 'OSea (||)' requiere operando booleano (tas_claro), pero '" + string(_left_op_or.sval) + "' es de tipo '" + (var_attr1->type ? var_attr1->type->symbol_name : "desconocido") + "'.";
                yyerror(err_msg.c_str()); 
            }
            if (holds_alternative<bool>(var_attr1->value)) {
                b1_or = get<bool>(var_attr1->value);
            } else {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Variable 'tas_claro' '" + string(_left_op_or.sval) + "' no contiene un valor booleano válido para 'OSea (||)'.";
                yyerror(err_msg.c_str()); 
            }
        } else {
            ERROR_TYPE = TYPE_ERROR; 
            string err_msg = "Operación 'OSea (||)' requiere operando booleano, pero se recibió tipo '" + string(typeToString(_left_op_or.type)) + "'.";
            yyerror(err_msg.c_str()); 
        }

        // Evaluate $3
        if (_right_op_or.type == ExpresionAttribute::BOOL) {
            b2_or = (bool)_right_op_or.ival;
        } else if (_right_op_or.type == ExpresionAttribute::ID) {
            Attributes* var_attr2 = symbolTable.search_symbol(_right_op_or.sval);
            if (!var_attr2) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_or.sval);  }
            if (!var_attr2->type || var_attr2->type->symbol_name != "tas_claro") {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Operación 'OSea (||)' requiere operando booleano (tas_claro), pero '" + string(_right_op_or.sval) + "' es de tipo '" + (var_attr2->type ? var_attr2->type->symbol_name : "desconocido") + "'.";
                yyerror(err_msg.c_str()); 
            }
            if (holds_alternative<bool>(var_attr2->value)) {
                b2_or = get<bool>(var_attr2->value);
            } else {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Variable 'tas_claro' '" + string(_right_op_or.sval) + "' no contiene un valor booleano válido para 'OSea (||)'.";
                yyerror(err_msg.c_str()); 
            }
        } else {
            ERROR_TYPE = TYPE_ERROR; 
            string err_msg = "Operación 'OSea (||)' requiere operando booleano, pero se recibió tipo '" + string(typeToString(_right_op_or.type)) + "'.";
            yyerror(err_msg.c_str()); 
        }

        $$.type = ExpresionAttribute::BOOL;
        $$.ival = (b1_or || b2_or) ? 1 : 0;
    }
    | expresion T_YUNTA expresion { // Logical AND (&&)
        bool b1_and, b2_and;
        ExpresionAttribute _left_op_and = $1;
        ExpresionAttribute _right_op_and = $3;

        // Evaluate $1
        if (_left_op_and.type == ExpresionAttribute::BOOL) {
            b1_and = (bool)_left_op_and.ival;
        } else if (_left_op_and.type == ExpresionAttribute::ID) {
            Attributes* var_attr1 = symbolTable.search_symbol(_left_op_and.sval);
            if (!var_attr1) { ERROR_TYPE = NON_DEF_VAR; yyerror(_left_op_and.sval);  }
            if (!var_attr1->type || var_attr1->type->symbol_name != "tas_claro") {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Operación 'Yunta (&&)' requiere operando booleano (tas_claro), pero '" + string(_left_op_and.sval) + "' es de tipo '" + (var_attr1->type ? var_attr1->type->symbol_name : "desconocido") + "'.";
                yyerror(err_msg.c_str()); 
            }
            if (holds_alternative<bool>(var_attr1->value)) {
                b1_and = get<bool>(var_attr1->value);
            } else {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Variable 'tas_claro' '" + string(_left_op_and.sval) + "' no contiene un valor booleano válido para 'Yunta (&&)'.";
                yyerror(err_msg.c_str()); 
            }
        } else {
            ERROR_TYPE = TYPE_ERROR; 
            string err_msg = "Operación 'Yunta (&&)' requiere operando booleano, pero se recibió tipo '" + string(typeToString(_left_op_and.type)) + "'.";
            yyerror(err_msg.c_str()); 
        }

        // Evaluate $3
        if (_right_op_and.type == ExpresionAttribute::BOOL) {
            b2_and = (bool)_right_op_and.ival;
        } else if (_right_op_and.type == ExpresionAttribute::ID) {
            Attributes* var_attr2 = symbolTable.search_symbol(_right_op_and.sval);
            if (!var_attr2) { ERROR_TYPE = NON_DEF_VAR; yyerror(_right_op_and.sval);  }
            if (!var_attr2->type || var_attr2->type->symbol_name != "tas_claro") {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Operación 'Yunta (&&)' requiere operando booleano (tas_claro), pero '" + string(_right_op_and.sval) + "' es de tipo '" + (var_attr2->type ? var_attr2->type->symbol_name : "desconocido") + "'.";
                yyerror(err_msg.c_str()); 
            }
            if (holds_alternative<bool>(var_attr2->value)) {
                b2_and = get<bool>(var_attr2->value);
            } else {
                ERROR_TYPE = TYPE_ERROR; 
                string err_msg = "Variable 'tas_claro' '" + string(_right_op_and.sval) + "' no contiene un valor booleano válido para 'Yunta (&&)'.";
                yyerror(err_msg.c_str()); 
            }
        } else {
            ERROR_TYPE = TYPE_ERROR; 
            string err_msg = "Operación 'Yunta (&&)' requiere operando booleano, pero se recibió tipo '" + string(typeToString(_right_op_and.type)) + "'.";
            yyerror(err_msg.c_str()); 
        }

        $$.type = ExpresionAttribute::BOOL;
        $$.ival = (b1_and && b2_and) ? 1 : 0;
    }
    | entrada_salida
	| variante
    | funcion {
		Attributes* func_attr = symbolTable.search_symbol(current_function_name);
        if (func_attr == nullptr) {
            yyerror("Funcion no definida");
            //exit(1);
        }
		if (func_attr->category != FUNCTION) {
            yyerror("El identificador no es una funcion");
            //exit(1);
        }

		current_function_type = get<string>(func_attr->info[func_attr->info.size()-1].first);
		$$.type = stringToType(current_function_type);
		
		// POR IMPLEMENTAR: Retornar el valor asociado a la funcion.
		// $$.ival = func_attr->value;
	}
    | casting
    | T_IDENTIFICADOR T_IZQCORCHE expresion T_DERCORCHE {
        Attributes* array_attr = symbolTable.search_symbol($1);
        
        if (!array_attr || array_attr->category != ARRAY) {
            ERROR_TYPE = NON_DEF_VAR;
            yyerror($1);
            //exit(1);
        }
        
        if ($3.type != ExpresionAttribute::INT) {
            ERROR_TYPE = SEMANTIC_TYPE;
            yyerror("Índice de array debe ser entero");
            //exit(1);
        }
        
        int index = $3.ival;
        int array_size = get<int>(array_attr->value);
        
        if (index < 0 || index >= array_size) {
            string error = to_string(index);
            ERROR_TYPE = SEGMENTATION_FAULT;
            yyerror(error.c_str());
            //exit(1);
        }

        std::string element_name = std::string($1) + "[" + std::to_string(index) + "]";
        Attributes* array_element_attributes = symbolTable.search_symbol(element_name.c_str());

        // Retornar el valor almacenado en el elemento del array
        if (array_element_attributes->type->symbol_name == "mango") { // INT
            $$.type = ExpresionAttribute::INT;
            $$.ival = get<int>(array_element_attributes->value);
        } else if (array_element_attributes->type->symbol_name == "manguita") { // FLOAT
            $$.type = ExpresionAttribute::FLOAT;
            $$.fval = get<float>(array_element_attributes->value);
        } else if (array_element_attributes->type->symbol_name == "manguangua") { // DOUBLE
            $$.type = ExpresionAttribute::DOUBLE;
            $$.dval = get<double>(array_element_attributes->value);
        } else if (array_element_attributes->type->symbol_name == "negro") { // CHAR
            $$.type = ExpresionAttribute::CHAR;
            $$.ival = get<char>(array_element_attributes->value);
        } else if (array_element_attributes->type->symbol_name == "higuerote") { // STRING
            $$.type = ExpresionAttribute::STRING;
            $$.sval = strdup(get<string>(array_element_attributes->value).c_str());
        } else if (array_element_attributes->type->symbol_name == "tas_claro") { // BOOL
            $$.type = ExpresionAttribute::BOOL;
            $$.ival = get<bool>(array_element_attributes->value);
        } else {
            ERROR_TYPE = SEMANTIC_TYPE;
            yyerror("Tipo no soportado para retorno de array");
            //exit(1);
        }    
    }  
;

condicion:
    T_SIESASI T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE instruccionesopt T_DERLLAVE cerrar_scope alternativa
    ;

alternativa:
    | T_OASI T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE instruccionesopt T_DERLLAVE cerrar_scope alternativa
    | T_NOJODA abrir_scope T_IZQLLAVE instruccionesopt T_DERLLAVE cerrar_scope
    ;

bucle:
    indeterminado 
    | determinado
    ;

indeterminado:
    T_ECHALEBOLAS T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    ;
var_ciclo_determinado:
    T_IDENTIFICADOR T_ENTRE expresion T_HASTA expresion {
        if (symbolTable.search_symbol($1) != nullptr){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($1);
            //exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $1;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"CICLO FOR", nullptr});
        attributes->type = symbolTable.search_symbol("mango");
        attributes->category = VARIABLE;

        switch($3.type) {
            case ExpresionAttribute::INT:
                attributes->value = $3.ival;
                break;
            case ExpresionAttribute::FLOAT:
                attributes->value = $3.fval;
                break;
            case ExpresionAttribute::DOUBLE:
                attributes->value = $3.dval;
                break;
            case ExpresionAttribute::BOOL:
                attributes->value = (bool)$3.ival; // Asumiendo que se almacena en ival
                break;
            case ExpresionAttribute::STRING:
                attributes->value = string($3.sval); // Convierte a std::string
                break;
            case ExpresionAttribute::CHAR:
                attributes->value = $3.cval; // Asume que $3.sval es un string y toma el primer carácter
                break;
            case ExpresionAttribute::POINTER:
                attributes->value = nullptr; // Manejar punteros según sea necesario
                break;
            default:
                attributes->value = nullptr;
                yyerror("Tipo no soportado");
                //exit(1);
        }

        if (!symbolTable.insert_symbol($1, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($1);
            //exit(1);
        };
    }
    ;
determinado:
    T_REPITEBURDA abrir_scope var_ciclo_determinado T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    | T_REPITEBURDA abrir_scope var_ciclo_determinado T_CONFLOW T_VALUE T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    ;

entrada_salida:
    T_RESCATA T_IZQPAREN secuencia T_DERPAREN
    | T_HABLAME T_IZQPAREN expresion T_DERPAREN
    ;

secuencia:
    | secuencia T_COMA expresion 
    | expresion 
    ;

secuencia_declaraciones:
    | secuencia_declaraciones T_PUNTOCOMA T_IDENTIFICADOR T_DOSPUNTOS tipos{
		if (current_struct_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay estructura actual");
            //exit(1);
        }
        
		Attributes* struct_attr = symbolTable.search_symbol(current_struct_name);
        if (struct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_STRUCT;
            yyerror(current_struct_name.c_str());
            //exit(1);
        }
        
        Attributes *attr = new Attributes();
        attr->symbol_name = $3;
        attr->scope = symbolTable.current_scope;
        attr->category = STRUCT_ATTRIBUTE;
        attr->type = symbolTable.search_symbol($5);
        attr->value = nullptr;
        
        if (!symbolTable.insert_symbol($3, *attr)) {
			ERROR_TYPE = ALREADY_DEF_ATTR;
            yyerror($3);
            //exit(1);
        }
        
        struct_attr->info.push_back({string($3), attr});
    }
    | T_IDENTIFICADOR T_DOSPUNTOS tipos {
        if (current_struct_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay estructura actual");
            //exit(1);
        }

        Attributes* struct_attr = symbolTable.search_symbol(current_struct_name);
        if (struct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_STRUCT;
            yyerror(current_struct_name.c_str());
            //exit(1);
        }
        
        Attributes *attr = new Attributes();
        attr->symbol_name = $1;
        attr->scope = symbolTable.current_scope;
        attr->category = STRUCT_ATTRIBUTE;
        attr->type = symbolTable.search_symbol($3);
        attr->value = nullptr;

        if (!symbolTable.insert_symbol($1, *attr)) {
			ERROR_TYPE = ALREADY_DEF_ATTR;
            yyerror($1);
            //exit(1);
        }
		
        struct_attr->info.push_back({string($1), attr});
    }
    ;

variante: 
    T_COLIAO T_IDENTIFICADOR {
		Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->category = UNION;
        attributes->info.push_back({"UNION", nullptr});
        attributes->value = nullptr;

		current_struct_name = string($2);

		if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_UNION;
            yyerror($2);
            //exit(1);
        };
        
	} abrir_scope T_IZQLLAVE secuencia_declaraciones T_PUNTOCOMA T_DERLLAVE {
		current_struct_name = "";
	} cerrar_scope
    ;

struct: 
    T_ARROZCONMANGO T_IDENTIFICADOR {
        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->category = STRUCT;
        attributes->info.push_back({"ESTRUCTURA", nullptr});
        attributes->value = nullptr;
        
        current_struct_name = string($2);
        
        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_STRUCT;
            yyerror($2);
            //exit(1);
        };
        
    } abrir_scope T_IZQLLAVE secuencia_declaraciones T_PUNTOCOMA T_DERLLAVE {
        current_struct_name = "";
    } cerrar_scope
    ;

firma_funcion: 
    T_ECHARCUENTO T_IDENTIFICADOR {

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->type = symbolTable.search_symbol("funcion$");
        attributes->category = FUNCTION;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_FUNC;
            yyerror($2);
            //exit(1);
        };

        current_function_name = string($2);
    }
    ;

tipo_funcion:
    tipos 
    | T_UNCONO { 
		if (current_function_name != "") current_function_type = "un_coño"; 
	}
    ;

secuencia_parametros:
    | secuencia_parametros T_COMA parametro 
	| parametro
    ;

parametro:
    T_AKITOY T_IDENTIFICADOR T_DOSPUNTOS tipos{
		if (current_function_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay funcion actual");
            //exit(1);
        }
        
		Attributes* funct_attr = symbolTable.search_symbol(current_function_name);
        if (funct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_FUNC;
            yyerror(current_function_name.c_str());
            //exit(1);
        }

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"PARAMETRO", nullptr});
        attributes->type = symbolTable.search_symbol($4);
        attributes->category = POINTER_V;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($2);
            //exit(1);
        };

		funct_attr->info.push_back({string($2), attributes});
    }
    | T_IDENTIFICADOR T_DOSPUNTOS tipos {
		if (current_function_name == "") {
			ERROR_TYPE = DEBUGGING_TYPE;
            yyerror("No hay funcion actual");
            //exit(1);
        }
        
		Attributes* funct_attr = symbolTable.search_symbol(current_function_name);
        if (funct_attr == nullptr) {
			ERROR_TYPE = NON_DEF_FUNC;
            yyerror(current_function_name.c_str());
            //exit(1);
        }
		
        Attributes *attributes = new Attributes();
        attributes->symbol_name = $1;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"PARAMETRO", nullptr});
        attributes->type = symbolTable.search_symbol($3);
        attributes->category = VARIABLE;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($1, *attributes)){
			ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($1);
            //exit(1);
        };

		funct_attr->info.push_back({string($1), attributes});
    }
    ;

declaracion_funcion:
    firma_funcion abrir_scope T_IZQPAREN secuencia_parametros T_DERPAREN T_LANZA tipo_funcion {
		Attributes* funct_attr = symbolTable.search_symbol(current_function_name);
		funct_attr->info.push_back({current_function_type, symbolTable.search_symbol(current_function_type)});
		current_function_name = "";
		current_function_type = "";
	} T_IZQLLAVE instruccionesopt T_DERLLAVE cerrar_scope
    ;

funcion:
	T_IDENTIFICADOR {
		Attributes* func_attr = symbolTable.search_symbol(string($1));
        if (func_attr == nullptr) {
            yyerror("Funcion no definida");
            //exit(1);
        }
		if (func_attr->category != FUNCTION) {
            yyerror("El identificador no es una funcion");
            //exit(1);
        }
		current_function_name = func_attr->symbol_name;
		current_function_parameters = 0;
		current_function_type = get<string>(func_attr->info[func_attr->info.size()-1].first);

	} T_IZQPAREN secuencia T_DERPAREN {
		Attributes* func_attr = symbolTable.search_symbol(strdup($1));
		if ( current_function_parameters < func_attr->info.size() - 1) {
			ERROR_TYPE = FUNC_PARAM_EXCEEDED;
			string error_message = "Falta de parametros en la llamada a la funcion '" + string($1) + "'";
			yyerror(error_message.c_str());
			//exit(1);
		}
	}

arreglo:
    T_IZQCORCHE secuencia T_DERCORCHE {
		current_array_name = "";
        current_array_size = 0;
        const char* current_array_base_type = nullptr;
	}
    ;

var_manejo_error:
    T_COMO abrir_scope T_IDENTIFICADOR {
        if (symbolTable.search_symbol($3) != nullptr){
            ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($3);
            //exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $3;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"MANEJO ERROR", nullptr});
        attributes->type = symbolTable.search_symbol("error$");
        attributes->category = VARIABLE;

        if (!symbolTable.insert_symbol($3, *attributes)){
            ERROR_TYPE = ALREADY_DEF_VAR;
            yyerror($3);
            //exit(1);
        };
    }
    ;

manejador:
    | T_FUERADELPEROL abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    | T_FUERADELPEROL var_manejo_error T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    ;

manejo_error:
    T_T_MEANDO abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope manejador
    ;

casting:
	T_CASTEO expresion
	;

%%

void yyerror(const char *var) {
    FIRST_ERROR = true;

    string error_msg; // Variable para construir el mensaje de error

    if (ERROR_TYPE == SEMANTIC_TYPE) {
        extern char* yytext;
        error_msg = "Qué garabato escribiste en línea " + to_string(yylineno) +
                    ", columna " + to_string(yylloc.first_column) +
                    ": '" + yytext + "'\n" + var;
        addError(ERROR_TYPE, error_msg);
    } else {
        error_msg = "Sendo peo en la linea " + to_string(yylineno) +
                    ", columna " + to_string(yylloc.first_column) + ": ";
        switch (ERROR_TYPE) {

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
				error_msg = "Ese mango \"" + string(var) + "\" anda sin pepa. Ay vale!.";
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

            case EMPTY_ARRAY_CONSTANT:
                error_msg += "El array \"" + string(var) + "\" es una jeva. No se cambia loco, respeta.";
                break;

            case POINTER_ARRAY:
                error_msg += "El array \"" + string(var) + "\" es un apuntador. Cuidao te dá.";
                break;

            case INT_SIZE_ARRAY:
                error_msg += "El array \"" + string(var) + "\" solo recibe mangos.";
                break;

            case INT_INDEX_ARRAY:
                error_msg += "Al array no se le entra con \"" + string(var) + "\" solo con mangos piaso e' mongolico."; 
                break;

            case DEBUGGING_TYPE:
                error_msg += string(var);
                break;

            default:
                cout << "Este beta es: " << ERROR_TYPE;
                error_msg += "Error desconocido.";
                break;
        }
        addError(ERROR_TYPE, error_msg); // Agrega el mensaje al diccionario de errores
    }
}