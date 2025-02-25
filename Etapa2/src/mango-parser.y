%{
#include <iostream>
#include <cstdlib>
#include "mango-bajito.hpp"

using namespace std;

void yyerror(const char *s);
int yylex();
extern int yylineno;

SymbolTable symbolTable = SymbolTable();
%}

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

%token T_ERROR
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
%token T_IDENTIFICADOR T_VALUE
%token T_IZQPAREN T_DERPAREN T_IZQLLAVE T_DERLLAVE T_IZQCORCHE T_DERCORCHE

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

programa:
    instrucciones main
    | main
    ;

main:
    T_SE_PRENDE T_IZQPAREN T_DERPAREN T_IZQLLAVE instruccionesopt T_DERLLAVE T_PUNTOCOMA { cout << "Programa válido." << endl; } 
    ;

instrucciones:
    instruccion T_PUNTOCOMA | instrucciones instruccion T_PUNTOCOMA
    ;

instruccionesopt:
    instrucciones |
    ;

instruccion:
    T_VALUE T_OPSUMA T_VALUE
    | declaracion 
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
    | error
    ;

declaracion:
    tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipos
    ;

declaracion_aputador:
    | T_AHITA
    ;

tipo_declaracion:
    declaracion_aputador T_CULITO 
    | declaracion_aputador T_JEVA
    ;

tipos:
    tipo_valor 
    | tipos T_IZQCORCHE expresion T_DERCORCHE
    ;

tipo_valor:
    T_MANGO 
    | T_MANGUITA 
    | T_MANGUANGUA 
    | T_NEGRO 
    | T_HIGUEROTE 
    | T_TASCLARO 
    ;

operadores_asginacion:
    T_ASIGNACION
    | T_OPASIGSUMA
    | T_OPASIGRESTA
    | T_OPASIGMULT
    ;

asignacion:
    T_IDENTIFICADOR operadores_asginacion expresion
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
    T_SIESASI T_IZQPAREN expresion T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE alternativa
    ;

alternativa:
    | T_OASI T_IZQPAREN expresion T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE
    | T_NOJODA T_IZQLLAVE instrucciones T_DERLLAVE
    ;

bucle:
    indeterminado 
    | determinado
    ;

indeterminado:
    T_ECHALEBOLAS T_IZQPAREN expresion T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE 
    ;

determinado:
    T_REPITEBURDA T_IDENTIFICADOR T_ENTRE T_VALUE T_HASTA T_VALUE T_IZQLLAVE instrucciones T_DERLLAVE
    | T_REPITEBURDA T_IDENTIFICADOR T_ENTRE T_VALUE T_HASTA T_VALUE T_CONFLOW T_VALUE T_IZQLLAVE instrucciones T_DERLLAVE
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
    T_COLIAO T_IDENTIFICADOR T_IZQLLAVE secuencia_declaraciones T_DERLLAVE
    ;

struct: 
    T_ARROZCONMANGO T_IDENTIFICADOR T_IZQLLAVE secuencia_declaraciones T_DERLLAVE
    ;

firma_funcion: 
    T_ECHARCUENTO T_IDENTIFICADOR T_IZQPAREN secuencia T_DERPAREN
    ;

tipo_funcion:
    tipos 
    | T_UNCONO
    ;

funcion:
    firma_funcion T_LANZA tipo_funcion T_IZQLLAVE instrucciones T_DERLLAVE
    ;

arreglo:
    T_IZQCORCHE secuencia T_DERCORCHE
    ;

manejador:
    | T_FUERADELPEROL T_IZQLLAVE instrucciones T_DERLLAVE
    | T_FUERADELPEROL T_COMO T_IDENTIFICADOR T_IZQLLAVE instrucciones T_DERLLAVE
    ;

manejo_error:
    T_T_MEANDO T_IZQLLAVE instrucciones T_DERLLAVE manejador
    ;

%%

void yyerror(const char *s) {
    cerr << "Error sintáctico en línea " << yylineno << ": " << s << endl;
}