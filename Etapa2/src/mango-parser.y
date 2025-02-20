%{
#include <iostream>
#include <cstdlib>

using namespace std;

void yyerror(const char *s);
int yylex();
extern int yylineno;
%}

%union {
    int ival;
    double dval;
    char *sval;
}

%token T_SE_PRENDE T_ASIGNACION T_DOSPUNTOS T_PUNTOCOMA T_PUNTO T_COMA
%token T_SIESASI T_OASI T_NOJODA
%token T_REPITEBURDA T_ENTRE T_HASTA T_CONFLOW
%token T_ECHALEBOLAS
%token T_ROTALO T_KIETO
%token T_CULITO T_JEVA
%token T_MANGO T_MANGUITA T_MANGUANGUA T_NEGRO T_HIGUEROTE
%token T_TASCLARO T_SISA T_NOLSA T_ARROZCONMANGO T_COLIAO
%token T_AHITA T_AKITOY T_CEROKM T_BORRADOL T_PELABOLA
%token T_UNCONO
%token T_ECHARCUENTO T_LANZA T_LANZATE
%token T_RESCATA T_HABLAME
%token T_T_MEANDO T_FUERADELPEROL T_COMO
%token T_OPSUMA T_OPINCREMENTO T_OPASIGSUMA T_OPRESTA T_OPDECREMENTO T_OPASIGRESTA
%token T_OPMULT T_OPASIGMULT T_OPDIVDECIMAL T_OPDIVENTERA T_OPMOD
%token T_OPIGUAL T_OPDIFERENTE T_OPMAYORIGUAL T_OPMAYOR T_OPMENORIGUAL T_OPMENOR
%token T_YUNTA T_OSEA T_NELSON
%token T_IDENTIFICADOR T_VALUE
%token T_IZQPAREN T_DERPAREN T_IZQLLAVE T_DERLLAVE T_IZQCORCHE T_DERCORCHE

%start programa
%%

programa:
    instrucciones main
    | main
    ;

main:
    T_SE_PRENDE T_IZQPAREN T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE { cout << "Programa válido." << endl; } 
    ;

instrucciones:
    | instrucciones instruccion T_PUNTOCOMA
    ;

instruccion:
    declaraciones | asignacion | condicion | bucle | entrada_salida | funcion | manejo_error 
    ;

declaraciones:
    tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipo_valor
    | tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipo_valor T_ASIGNACION expresion
    ;

tipo_declaracion:
    T_CULITO | T_JEVA
    ;

tipo_valor:
    T_MANGO | T_MANGUITA | T_MANGUANGUA | T_NEGRO | T_HIGUEROTE
    ;

asignacion:
    T_IDENTIFICADOR T_ASIGNACION expresion
    ;

expresion:
    T_IDENTIFICADOR | T_MANGO | T_MANGUITA | T_MANGUANGUA | T_NEGRO | T_HIGUEROTE | T_VALUE
    | expresion operador expresion
    ;

operador:
    T_OPSUMA | T_OPRESTA | T_OPMULT | T_OPDIVDECIMAL | T_OPDIVENTERA | T_OPMOD
    ;

condicion:
    T_SIESASI T_IZQPAREN expresion T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE alternativa
    ;

alternativa:
    | T_OASI T_IZQPAREN expresion T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE
    | T_NOJODA T_IZQLLAVE instrucciones T_DERLLAVE
    ;

bucle:
    indeterminado | determinado
    ;

indeterminado:
    T_ECHALEBOLAS T_IZQPAREN expresion T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE
    ;

determinado:
    T_REPITEBURDA T_IDENTIFICADOR T_ENTRE T_VALUE T_HASTA T_VALUE T_IZQLLAVE instrucciones T_DERLLAVE
    | T_REPITEBURDA T_IDENTIFICADOR T_ENTRE T_VALUE T_HASTA T_VALUE T_CONFLOW T_VALUE T_IZQLLAVE instrucciones T_DERLLAVE
    ;

entrada_salida:
    ;

funcion:
    ;

manejo_error:
    ;
    
%%

void yyerror(const char *s) {
    cerr << "Error sintáctico en línea " << yylineno << ": " << s << endl;
}