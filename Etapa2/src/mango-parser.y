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
int ERROR_TYPE = 0; // Permite manejar un error particular. Aumentar en 1 para ser personalizado.
string current_struct_name = "";
%}

%code requires {
	struct ExpresionAttribute {
		enum Type { INT, FLOAT, DOUBLE, BOOL, STRING, POINTER } type;
		union {
			int ival;
			float fval;
			double dval;
			char* sval;
		};
	};
}

%union {
	ExpresionAttribute att_val; // Usa el struct definido
    int ival;
    float fval;
    double dval;
    char* sval;
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
%type <sval> tipo_declaracion declaracion_aputador tipo_valor tipos asignacion firma_funcion parametro secuencia_parametros
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
		symbolTable.print_table(); 
		cout << "Programa válido: "; 
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
        if (symbolTable.search_symbol($4) == nullptr){
			ERROR_TYPE++;
            yyerror("Tipo no definido en el lenguaje");
            exit(1);
        };

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

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE++;
            yyerror("Variable ya declarada en este alcance");
            exit(1);
        };
    }

    | tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos T_ASIGNACION expresion {
        if (symbolTable.search_symbol($4) == nullptr){
			ERROR_TYPE++;
            yyerror("Tipo no definido en el lenguaje");
            exit(1);
        };

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
	            //cout << "ASIGNANDO ENTERO: valor = " << $6.ival << endl;
	            attributes->value = $6.ival;
	            break;
	        
	        case ExpresionAttribute::FLOAT:
	            //cout << "ASIGNANDO FLOAT: valor = " << $6.fval << endl;
	            attributes->value = $6.fval;
	            break;
	        
			case ExpresionAttribute::DOUBLE:
	            //cout << "ASIGNANDO DOUBLE: valor = " << $6.dval << endl;
	            attributes->value = $6.dval;
	            break;

	        case ExpresionAttribute::BOOL:
	            //cout << "ASIGNANDO BOOL: valor = " << (strcmp($6.sval, "Sisa") == 0 ? "true" : "false") << endl;
	            attributes->value = strcmp($6.sval, "Sisa") == 0 ? true : false;
	            break;
	        
	        case ExpresionAttribute::STRING:
	            //cout << "ASIGNANDO STRING: valor = \"" << $6.sval << "\"" << endl;
	            attributes->value = string($6.sval);
	            break;
	        
	        case ExpresionAttribute::POINTER:
	            //cout << "ASIGNANDO PUNTERO: valor = nullptr" << endl;
	            attributes->value = nullptr;
	            break;
	        
	        default:
	            cout << "TIPO DESCONOCIDO: Asignando nullptr" << endl;
	            attributes->value = nullptr;
	    }

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE++;
            yyerror("Variable ya declarada en este alcance");
            exit(1);
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
    tipo_valor 
    | tipos T_IZQCORCHE expresion T_DERCORCHE { $$ = strdup("array$"); }
    ;

tipo_valor:
    T_MANGO { $$ = strdup("mango"); }
    | T_MANGUITA { $$ = strdup("manguita"); }
    | T_MANGUANGUA { $$ = strdup("manguangua"); }
    | T_NEGRO { $$ = strdup("negro"); }
    | T_HIGUEROTE { $$ = strdup("higuerote"); }
    | T_TASCLARO { $$ = strdup("tas_claro"); }
    ;

operadores_asginacion:
    T_ASIGNACION
    | T_OPASIGSUMA
    | T_OPASIGRESTA
    | T_OPASIGMULT
    ;

asignacion:
    T_IDENTIFICADOR operadores_asginacion expresion { 
		Attributes *attr_var = symbolTable.search_symbol($1);
        if (attr_var == nullptr){
			ERROR_TYPE++;
            yyerror("Variable no definida");
            exit(1);
        };
                
        string info_var = get<string>(attr_var->info[0].first);
        if (strcmp(info_var.c_str(), "CICLO FOR") == 0){
			ERROR_TYPE++;
            yyerror("No se puede modificar una variable en un ciclo determinado");
            exit(1);
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
	        case ExpresionAttribute::POINTER:
	            // Manejar punteros según sea necesario
	            attr_var->value = nullptr; // O el valor adecuado
	            break;
	        default:
	            attr_var->value = nullptr;
	    }
    }
    | T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR operadores_asginacion expresion
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
    T_IDENTIFICADOR 
    | T_VALUE 
    | T_PELABOLA
    | valores_booleanos 
    | expresion_apuntador 
    | expresion_nuevo
    | arreglo
    | T_NELSON expresion
    | T_OPRESTA expresion %prec T_SIGNO_MENOS
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
    | expresion T_OPDECREMENTO
    | expresion T_OPINCREMENTO
    | entrada_salida
    | funcion
    | casting
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
    T_IDENTIFICADOR T_ENTRE T_VALUE T_HASTA T_VALUE {
        if (symbolTable.search_symbol($1) != nullptr){
			ERROR_TYPE++;
            yyerror("Variable ya declarada anteriormente");
            exit(1);
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
        case ExpresionAttribute::BOOL:
            attributes->value = (bool)$3.ival; // Asumiendo que se almacena en ival
            break;
        case ExpresionAttribute::STRING:
            attributes->value = string($3.sval); // Convierte a std::string
            break;
        case ExpresionAttribute::POINTER:
            // Manejar punteros según sea necesario
            attributes->value = nullptr; // O el valor adecuado
            break;
        default:
            attributes->value = nullptr;
    }

        if (!symbolTable.insert_symbol($1, *attributes)){
			ERROR_TYPE++;
            yyerror("Variable ya declarada en este alcance");
            exit(1);
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
			ERROR_TYPE++;
            yyerror("No hay estructura actual");
            exit(1);
        }
        
		Attributes* struct_attr = symbolTable.search_symbol(current_struct_name);
        if (struct_attr == nullptr) {
			ERROR_TYPE++;
            yyerror("No se encontró la estructura");
            exit(1);
        }
        
        Attributes *attr = new Attributes();
        attr->symbol_name = $3;
        attr->scope = symbolTable.current_scope;
        attr->category = STRUCT_ATTRIBUTE;
        attr->type = symbolTable.search_symbol($5);
        attr->value = nullptr;
        
        if (!symbolTable.insert_symbol($3, *attr)) {
			ERROR_TYPE++;
            yyerror("Atributo ya declarado en esta estructura");
            exit(1);
        }
        
        struct_attr->info.push_back({string($3), attr});
        //cout << "  Agregando atributo: \"" << $3 << "\" a estructura: " << current_struct_name << endl;
    }
    | T_IDENTIFICADOR T_DOSPUNTOS tipos {
        if (current_struct_name == "") {
			ERROR_TYPE++;
            yyerror("No hay estructura actual");
            exit(1);
        }

        Attributes* struct_attr = symbolTable.search_symbol(current_struct_name);
        if (struct_attr == nullptr) {
			ERROR_TYPE++;
            yyerror("No se encontró la estructura");
            exit(1);
        }
        
        Attributes *attr = new Attributes();
        attr->symbol_name = $1;
        attr->scope = symbolTable.current_scope;
        attr->category = STRUCT_ATTRIBUTE;
        attr->type = symbolTable.search_symbol($3);
        attr->value = nullptr;

        if (!symbolTable.insert_symbol($1, *attr)) {
			ERROR_TYPE++;
            yyerror("Atributo ya declarado en esta estructura");
            exit(1);
        }
		
        struct_attr->info.push_back({string($1), attr});
        //cout << "  Agregando atributo: \"" << $1 << "\" a estructura: " << current_struct_name << endl;
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
			ERROR_TYPE++;
            yyerror("Variante ya declarada en este alcance");
            exit(1);
        };
        
        //cout << "Definiendo variante: " << $2 << endl;

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
			ERROR_TYPE++;
            yyerror("Estructura ya declarada en este alcance");
            exit(1);
        };
        
        //cout << "Definiendo estructura: " << $2 << endl;
    } abrir_scope T_IZQLLAVE secuencia_declaraciones T_PUNTOCOMA T_DERLLAVE {
        current_struct_name = "";
    } cerrar_scope
    ;

firma_funcion: 
    T_ECHARCUENTO T_IDENTIFICADOR {
        if (symbolTable.search_symbol($2) != nullptr){
			ERROR_TYPE++;
            yyerror("Función ya declarada anteriormente");
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"FUNCION", nullptr});
        attributes->type = symbolTable.search_symbol("funcion$");
        attributes->category = FUNCTION;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE++;
            yyerror("Función ya declarada en este alcance");
            exit(1);
        };

        $$ = $2;
    }
    ;

tipo_funcion:
    tipos 
    | T_UNCONO
    ;

secuencia_parametros:
    | secuencia_parametros T_COMA parametro
    | parametro
    ;

parametro:
    T_AKITOY T_IDENTIFICADOR T_DOSPUNTOS tipos{
        if (symbolTable.search_symbol($2) != nullptr){
			ERROR_TYPE++;
            yyerror("Variable ya declarada anteriormente");
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"PARAMETRO", nullptr});
        attributes->type = symbolTable.search_symbol($4);
        attributes->category = POINTER_V;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
			ERROR_TYPE++;
            yyerror("Variable ya declarada en este alcance");
            exit(1);
        };

        $$ = $2;
    }
    | T_IDENTIFICADOR T_DOSPUNTOS tipos {
        if (symbolTable.search_symbol($1) != nullptr){
			ERROR_TYPE++;
            yyerror("Variable ya declarada anteriormente");
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $1;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"PARAMETRO", nullptr});
        attributes->type = symbolTable.search_symbol($3);
        attributes->category = VARIABLE;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($1, *attributes)){
			ERROR_TYPE++;
            yyerror("Variable ya declarada en este alcance");
            exit(1);
        };

        $$ = $1;
    }
    ;

declaracion_funcion:
    firma_funcion abrir_scope T_IZQPAREN secuencia_parametros T_DERPAREN T_LANZA tipo_funcion T_IZQLLAVE instruccionesopt T_DERLLAVE cerrar_scope
    ;

funcion:
	T_IDENTIFICADOR T_IZQPAREN secuencia T_DERPAREN

arreglo:
    T_IZQCORCHE secuencia T_DERCORCHE
    ;

var_manejo_error:
    T_COMO abrir_scope T_IDENTIFICADOR {
        if (symbolTable.search_symbol($3) != nullptr){
            yyerror("Variable ya declarada anteriormente");
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $3;
        attributes->scope = symbolTable.current_scope;
        attributes->info.push_back({"MANEJO ERROR", nullptr});
        attributes->type = symbolTable.search_symbol("error$");
        attributes->category = VARIABLE;

        if (!symbolTable.insert_symbol($3, *attributes)){
            yyerror("Variable ya declarada en este alcance");
            exit(1);
        };
    }
    ;

manejador:
    | T_FUERADELPEROL abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    | T_FUERADELPEROL T_COMO abrir_scope T_IDENTIFICADOR T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    ;

manejo_error:
    T_T_MEANDO abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope manejador
    ;

casting:
	T_CASTEO expresion
	;

%%

void yyerror(const char *mns) {
    static bool first_error = true;
    
    // Solo mostrar el primer error
    if (ERROR_TYPE == 0) {
		extern char* yytext;
        cerr << "\nError sintáctico en línea " << yylineno << ", columna " << yylloc.first_column << ": '" << yytext << "'\n\n";
    } else {
		cerr << "\nError en línea " << yylineno << ", columna " << yylloc.first_column << ": " << mns << "\n\n";
	}
}