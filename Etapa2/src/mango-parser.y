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
    {NON_DEF_VAR, {}},
    {ALREADY_DEF_VAR, {}},
    {VAR_FOR, {}},
    {VAR_TRY, {}},
    {NON_DEF_FUNC, {}},
    {ALREADY_DEF_FUNC, {}},
    {NON_DEF_STRUCT, {}},
    {ALREADY_DEF_STRUCT, {}},
    {NON_DEF_UNION, {}},
    {ALREADY_DEF_UNION, {}},
    {NON_DEF_TYPE, {}},
    {ALREADY_DEF_ATTR, {}},
    {DEBUGGING_TYPE, {}},
    {SEMANTIC_TYPE, {}},
    {TYPE_ERROR, {}},
    {SEGMENTATION_FAULT, {}},
    {PARAMETERS_ERROR, {}},
    {EMPTY_ARRAY_CONSTANT, {}},
    {POINTER_ARRAY, {}},
    {INT_SIZE_ARRAY,{}}
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
		enum Type { INT, FLOAT, DOUBLE, BOOL, STRING, POINTER, ID, CHAR} type;
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
    | T_IDENTIFICADOR T_OPDECREMENTO
    | T_IDENTIFICADOR T_OPINCREMENTO
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
                //exit(1);
            }

            // Validar categoría de declaración
            if (strcmp($1, "CONSTANTE") == 0) {
                ERROR_TYPE = EMPTY_ARRAY_CONSTANT;
                yyerror($2);
                //exit(1);
            }
            if (strcmp($1, "POINTER_C") == 0 || strcmp($1, "POINTER_V") == 0) {
                ERROR_TYPE = POINTER_ARRAY;
                yyerror($2);
                //exit(1);
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
    
                // Opcional: Insertar elemento en tabla de símbolos
                if (!symbolTable.insert_symbol(elem->symbol_name, *elem)) {
                    ERROR_TYPE = ALREADY_DEF_VAR;
                    yyerror(elem->symbol_name.c_str());
                    //exit(1);
                }
            }

            // Insertar en tabla de símbolos
            if (!symbolTable.insert_symbol($2, *attributes)) {
                ERROR_TYPE = ALREADY_DEF_VAR;
                yyerror($2);
                //exit(1);
            }

            string current_array_name = "";
            int current_array_size = 0;
            const char* current_array_base_type = nullptr;            
        }
        // Caso normal (no array)
        else {
            if (symbolTable.search_symbol($4) == nullptr) {
                ERROR_TYPE = NON_DEF_TYPE;
                yyerror($4);
                //exit(1);
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
                //exit(1);
            }
        }
    }
    | tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos T_ASIGNACION expresion {
        if (symbolTable.search_symbol($4) == nullptr){
			ERROR_TYPE = NON_DEF_TYPE;
            yyerror($4);
            //exit(1);
        };

		if (current_function_type != ""){ // En caso de asignacion de funciones.
			string type_id = symbolTable.search_symbol($4)->symbol_name;
			if (current_function_type != type_id){
				ERROR_TYPE = TYPE_ERROR;
				string error_message = type_id + "\". Recibido: \"" + current_function_type;
				yyerror(error_message.c_str());
				//exit(1);
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
	            attributes->value = $6.ival;
	            break;
	        
	        case ExpresionAttribute::FLOAT:
	            attributes->value = $6.fval;
	            break;
	        
			case ExpresionAttribute::DOUBLE:
	            attributes->value = $6.dval;
	            break;

	        case ExpresionAttribute::BOOL:
	            attributes->value = strcmp($6.sval, "Sisa") == 0 ? true : false;
	            break;
	        
	        case ExpresionAttribute::STRING:
	            attributes->value = string($6.sval);
	            break;

            case ExpresionAttribute::CHAR:
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
	}
    | tipos T_IZQCORCHE expresion T_DERCORCHE {
        // Verificar que la expresión sea un valor entero válido
        if ($3.type != ExpresionAttribute::INT) {
            ERROR_TYPE = INT_SIZE_ARRAY;
            yyerror(typeToString($3.type));
            //exit(1);
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
			//exit(1);
		}

		$$ = strdup(attribute->symbol_name.c_str());
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
    T_ASIGNACION
    | T_OPASIGSUMA
    | T_OPASIGRESTA
    | T_OPASIGMULT
    ;

asignacion:
    T_IDENTIFICADOR operadores_asignacion expresion {
		Attributes *attr_var = symbolTable.search_symbol(string($1));
        if (attr_var == nullptr){
			ERROR_TYPE = NON_DEF_VAR;
            yyerror($1);
            //exit(1);
        };
        
        string info_var = get<string>(attr_var->info[0].first);
        if (strcmp(info_var.c_str(), "CICLO FOR") == 0){
			ERROR_TYPE = VAR_FOR;
            yyerror("No se puede modificar una variable de un ciclo determinado");
            //exit(1);
        }

        if (strcmp(info_var.c_str(), "MANEJO ERROR") == 0){
			ERROR_TYPE = VAR_TRY;
            yyerror("No se puede modificar una variable de un meando/fuera_del_perol");
            //exit(1);
        }

		if (attr_var->category == ARRAY){ // En caso de asignacion de arreglos.
			current_array_name = string($1); 
		}

		if (current_function_type != ""){ // En caso de asignacion de funciones.
			if (current_function_type != attr_var->type->symbol_name){
				ERROR_TYPE = TYPE_ERROR;
				string error_message = attr_var->type->symbol_name + "\". Recibido: \"" + current_function_type;
				yyerror(error_message.c_str());
				//exit(1);
			}
			current_function_type = "";
		}

	    switch($3.type) {
	        case ExpresionAttribute::INT:
	            attr_var->value = $3.ival;
	            break;
	        case ExpresionAttribute::FLOAT:
	            attr_var->value = $3.fval;
	            break;
	        case ExpresionAttribute::BOOL:
	            attr_var->value = (bool)$3.ival; // Asumiendo que se almacena en ival
	            break;
	        case ExpresionAttribute::STRING:
                attr_var->value = string($3.sval); // Convierte a std::string
	            break;
            case ExpresionAttribute::CHAR: {
                attr_var->value = $3.cval;
                break;
            }
	        case ExpresionAttribute::POINTER:
	            // Manejar punteros según sea necesario
	            attr_var->value = nullptr; // O el valor adecuado
	            break;
			case ExpresionAttribute::ID:
				// Para el caso de funciones, provicionalmente se maneja asi.
				attr_var->value = nullptr;
				break;
	        default:
                Attributes *attr = symbolTable.search_symbol($3.sval);
                if(attr != nullptr){
                    if(attr->category == VARIABLE || attr->category == CONSTANT){
                        attr_var->value = attr->value;
                    } 
                } else {
                    attr_var->value = nullptr;
                }
                break;
	        }
        }
    | T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR operadores_asignacion expresion
    | T_IDENTIFICADOR T_IZQCORCHE expresion T_DERCORCHE operadores_asignacion expresion {
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
        
        if (array_attr->type->symbol_name != typeToString($6.type)) {
            string error = array_attr->type->symbol_name;
            ERROR_TYPE = TYPE_ERROR;
            yyerror(error.c_str());
            //exit(1);
        }
  
        // Asignar valor
        switch ($6.type) {
            case ExpresionAttribute::INT:
                array_element_attributes->value = $6.ival;
                break;
            case ExpresionAttribute::FLOAT:
                array_element_attributes->value = $6.fval;
                break;
            case ExpresionAttribute::DOUBLE:
                array_element_attributes->value = $6.dval;
                break;
            case ExpresionAttribute::BOOL:
                array_element_attributes->value = (bool)$6.ival; // Asumiendo que el valor booleano está en ival
                break;
            case ExpresionAttribute::STRING:
                if ($6.sval) {
                    array_element_attributes->value = std::string($6.sval);
                } else {
                    array_element_attributes->value = std::string("");
                }
                break;
            case ExpresionAttribute::CHAR:
                array_element_attributes->value =  $6.cval;
                break;
            case ExpresionAttribute::POINTER:
                array_element_attributes->value = nullptr; // Manejar punteros según sea necesario
                break;
            default:
                ERROR_TYPE = SEMANTIC_TYPE;
                yyerror("Tipo no soportado para array");
                //exit(1);
        }

        // Actualizar en tabla de símbolos
        symbolTable.insert_symbol(array_element_attributes->symbol_name, *array_element_attributes);
    }
    ;

valores_booleanos:
    T_SISA
    | T_NOLSA
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
				ERROR_TYPE = PARAMETERS_ERROR;
				string error_message = "Error en la función '" + current_function_name + "': Excede la cantidad de parámetros.";
				yyerror(error_message.c_str());
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
				ERROR_TYPE = PARAMETERS_ERROR;
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
    | T_IZQPAREN expresion T_DERPAREN
    | valores_booleanos 
    | expresion_apuntador 
    | expresion_nuevo
    | arreglo
    | T_NELSON expresion
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
    | expresion T_OPIGUAL expresion
    | expresion T_OPDIFERENTE expresion
    | expresion T_OPMAYOR expresion
    | expresion T_OPMAYORIGUAL expresion
    | expresion T_OPMENOR expresion
    | expresion T_OPMENORIGUAL expresion
    | expresion T_OSEA expresion
    | expresion T_YUNTA expresion
    | expresion T_OPDECREMENTO
    | expresion T_OPINCREMENTO
    | entrada_salida
	| variante
    | funcion {
		// POR IMPLEMENTAR: La funcion debe retornar un valor asociado segun sea el caso.
		$$.type = ExpresionAttribute::ID;
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
    T_SIESASI T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope alternativa
    ;

alternativa:
    | T_OASI T_IZQPAREN expresion T_DERPAREN abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope alternativa
    | T_NOJODA abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
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
			ERROR_TYPE = PARAMETERS_ERROR;
			string error_message = "Falta de parametros en la llamada a la funcion '" + string($1) + "'";
			yyerror(error_message.c_str());
			//exit(1);
		}
		current_function_name = "";
		current_function_parameters = 0;
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

    std::string error_msg; // Variable para construir el mensaje de error

    if (ERROR_TYPE == SEMANTIC_TYPE) {
        extern char* yytext;
        error_msg = "Error sintáctico en línea " + std::to_string(yylineno) +
                    ", columna " + std::to_string(yylloc.first_column) +
                    ": '" + yytext + "'\n" + var;
        addError(ERROR_TYPE, error_msg);
    } else {
        error_msg = "Error en línea " + std::to_string(yylineno) +
                    ", columna " + std::to_string(yylloc.first_column) + ": ";
        switch (ERROR_TYPE) {
            case NON_DEF_VAR:
                error_msg += "Variable \"" + std::string(var) + "\" no definida.";
                break;
            case ALREADY_DEF_VAR:
                error_msg += "Variable \"" + std::string(var) + "\" ya fue definida.";
                break;
            case NON_DEF_FUNC:
                error_msg += "Función \"" + std::string(var) + "\" no definida.";
                break;
            case ALREADY_DEF_FUNC:
                error_msg += "Función \"" + std::string(var) + "\" ya fue definida.";
                break;
            case NON_DEF_STRUCT:
                error_msg += "Estructura \"" + std::string(var) + "\" no definida.";
                break;
            case ALREADY_DEF_STRUCT:
                error_msg += "Estructura \"" + std::string(var) + "\" ya fue definida.";
                break;
            case NON_DEF_UNION:
                error_msg += "Variante \"" + std::string(var) + "\" no definida.";
                break;
            case ALREADY_DEF_UNION:
                error_msg += "Variante \"" + std::string(var) + "\" ya fue definida.";
                break;
            case ALREADY_DEF_ATTR:
                error_msg += "Atributo \"" + std::string(var) + "\" ya fue definido.";
                break;
            case NON_DEF_TYPE:
                error_msg += "Tipo \"" + std::string(var) + "\" no definido.";
                break;
            case VAR_FOR:
                error_msg += "Variable \"" + std::string(var) + "\" es de ciclo `repite_burda`. No se admite cambiar su valor.";
                break;
            case VAR_TRY:
                error_msg += "Variable \"" + std::string(var) + "\" es de estructura `fuera_del_perol`. No se admite cambiar su valor.";
                break;
            case TYPE_ERROR:
                error_msg += "Tipo incompatible. Esperado: \"" + std::string(var) + "\".";
                break;
            case SEGMENTATION_FAULT:
                error_msg += "Índice \"" + std::string(var) + "\" fuera de rango.";
                break;
            case PARAMETERS_ERROR:
                error_msg += std::string(var);
                break;
            case EMPTY_ARRAY_CONSTANT:
                error_msg += "Array \"" + std::string(var) + "\" declarado constante.";
                break;
            case POINTER_ARRAY:
                error_msg += "Array \"" + std::string(var) + "\" declarado apuntador.";
                break;
            case INT_SIZE_ARRAY:
                error_msg += "Tamano de array no puede ser definido como: \"" + std::string(var) + "\" .Solo admite enteros";
                break;            
            case DEBUGGING_TYPE:
                error_msg += std::string(var);
                break;
            default:
                cout << "AAAAAAA" << ERROR_TYPE;
                error_msg += "Error desconocido.";
                break;
        }
        addError(ERROR_TYPE, error_msg); // Agrega el mensaje al diccionario de errores
    }
}