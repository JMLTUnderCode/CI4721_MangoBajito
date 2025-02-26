%{
#include <iostream>
#include <cstdlib>
#include "mango-bajito.hpp"
#include <cstring>

using namespace std;

void yyerror(const char *s);
int yylex();
extern int yylineno;

SymbolTable symbolTable = SymbolTable();
%}

%code requires {
  struct ExpresionAttribute {
    enum Type { INT, FLOAT, BOOL, STRING, POINTER } type;
    union {
    int ival;
    float fval;
    double dval;
    char cval;
    char* sval;
    };
  };
}

%union {
  ExpresionAttribute att_val; // Usa el struct definido
}  

%union {
    int ival;
    float fval;
    double dval;
    char cval;
    char* sval;
}

%token <ival> T_MANGO       // Token para int
%token <fval> T_MANGUITA    // Token para float
%token <dval> T_MANGUANGUA    // Token para double
%token <cval> T_NEGRO  // Token para caracter
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


// Declaracion de tipos de retorno para las producciones 
%type <sval> tipo_declaracion declaracion_aputador tipo_valor tipos asignacion 
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
%start programa
%%

abrir_scope:
    {symbolTable.open_scope();}
    ;

cerrar_scope:
    {symbolTable.close_scope();}
    ;

programa:
    abrir_scope instrucciones main cerrar_scope
    | abrir_scope main cerrar_scope
    ;

main:
    T_SE_PRENDE abrir_scope T_IZQPAREN T_DERPAREN T_IZQLLAVE instruccionesopt T_DERLLAVE T_PUNTOCOMA cerrar_scope { cout << "Programa válido." << endl; symbolTable.print_table(); } 
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
    | declaracion T_ASIGNACION expresion
    | T_BORRADOL T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR 
    ;

declaracion:
    tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos {
        Attributes *attributes = new Attributes();

        if (symbolTable.search_symbol($4) == nullptr){
            yyerror("Tipo no definido en el lenguaje");
            exit(1);
        };

        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
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
            yyerror("Variable ya declarada en este alcance");
            exit(1);
        };

        //cout << symbolTable.search_symbol($2)->symbol_name << "->" << get<string>(symbolTable.search_symbol($2)->info[0].first)  << endl;
    }
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
        cout << "Scope: " << symbolTable.current_scope << endl;
		cout << "Symbol: " << $1 << endl;
		Attributes *attr_var = symbolTable.search_symbol($1);
        if (attr_var == nullptr){
            yyerror("Variable no definida");
            exit(1);
        };
        
        cout << attr_var->symbol_name << " " << attr_var->info.size() << endl;
        
        /* string info_var = get<string>(attr_var->info[0].first);
        if (strcmp(info_var.c_str(), "CICLO FOR") == 0){
            yyerror("No se puede modificar una variable en un ciclo determinado");
            exit(1);
        }
 */
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
            yyerror("Variable ya declarada anteriormente");
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $1;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"CICLO FOR", nullptr});
        attributes->type = symbolTable.search_symbol("mango");
        attributes->category = VARIABLE;
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

        if (!symbolTable.insert_symbol($1, *attributes)){
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
    | T_HABLAME T_IZQPAREN secuencia T_DERPAREN
    ;

secuencia:
    | secuencia T_COMA expresion 
    | expresion 
    ;

secuencia_declaraciones:
    | secuencia_declaraciones T_PUNTOCOMA T_IDENTIFICADOR T_DOSPUNTOS tipos 
    | T_IDENTIFICADOR T_DOSPUNTOS tipos 
    ;

variante: 
    T_COLIAO T_IDENTIFICADOR abrir_scope T_IZQLLAVE secuencia_declaraciones T_DERLLAVE cerrar_scope
    ;

struct: 
    T_ARROZCONMANGO T_IDENTIFICADOR abrir_scope T_IZQLLAVE secuencia_declaraciones T_DERLLAVE cerrar_scope
    ;

firma_funcion: 
    T_ECHARCUENTO T_IDENTIFICADOR {
        if (symbolTable.search_symbol($2) != nullptr){
            yyerror("Función ya declarada anteriormente");
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"FUNCION", nullptr});
        attributes->category = FUNCTION;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
            yyerror("Función ya declarada en este alcance");
            exit(1);
        };
    }
    ;

tipo_funcion:
    tipos 
    | T_UNCONO
    ;

secuencia_parametros:
    | secuencia_parametros T_COMA secuencia_parametros
    | T_AKITOY T_IDENTIFICADOR T_DOSPUNTOS tipos{
        if (symbolTable.search_symbol($2) != nullptr){
            yyerror("Variable ya declarada anteriormente");
            exit(1);
        };

        Attributes *attributes = new Attributes();
        attributes->symbol_name = $2;
        attributes->scope = symbolTable.current_scope;
        //attributes->info.clear();
        attributes->info.push_back({"PARAMETRO", nullptr});
        attributes->type = symbolTable.search_symbol($4);
        attributes->category = POINTER_V;
        attributes->value = nullptr;

        if (!symbolTable.insert_symbol($2, *attributes)){
            yyerror("Variable ya declarada en este alcance");
            exit(1);
        };
    }
    | T_IDENTIFICADOR T_DOSPUNTOS tipos {
        if (symbolTable.search_symbol($1) != nullptr){
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
            yyerror("Variable ya declarada en este alcance");
            exit(1);
        };
    }
    ;

funcion:
    firma_funcion abrir_scope T_IZQPAREN secuencia_parametros T_DERPAREN T_LANZA tipo_funcion T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    ;

arreglo:
    T_IZQCORCHE secuencia T_DERCORCHE
    ;

manejador:
    | T_FUERADELPEROL abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    | T_FUERADELPEROL T_COMO abrir_scope T_IDENTIFICADOR T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope
    ;

manejo_error:
    T_T_MEANDO abrir_scope T_IZQLLAVE instrucciones T_DERLLAVE cerrar_scope manejador
    ;

%%

void yyerror(const char *s) {
    cerr << "Error sintáctico en línea " << yylineno << ": " << s << endl;
}