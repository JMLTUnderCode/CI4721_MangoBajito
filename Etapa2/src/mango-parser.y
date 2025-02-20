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
%token T_IDENTIFICADOR

%start programa
%%

programa:
    T_SE_PRENDE declaraciones bloque { cout << "Programa válido." << endl; }
    ;

declaraciones:
    | declaraciones declaracion
    ;

declaracion:
    tipo T_IDENTIFICADOR T_PUNTOCOMA
    ;

tipo:
    T_MANGO | T_MANGUITA | T_MANGUANGUA | T_NEGRO | T_HIGUEROTE
    ;

bloque:
    T_AHITA instrucciones T_AKITOY
    ;

instrucciones:
    | instrucciones instruccion
    ;

instruccion:
    asignacion | condicion | bucle | entrada_salida
    ;

asignacion:
    T_IDENTIFICADOR T_ASIGNACION expresion T_PUNTOCOMA
    ;

expresion:
    T_IDENTIFICADOR | T_MANGO | T_MANGUITA | T_MANGUANGUA | T_NEGRO | T_HIGUEROTE
    | expresion operador expresion
    ;

operador:
    T_OPSUMA | T_OPRESTA | T_OPMULT | T_OPDIVDECIMAL | T_OPDIVENTERA | T_OPMOD
    ;

condicion:
    T_SIESASI expresion bloque alternativa
    ;

alternativa:
    | T_OASI bloque | T_NOJODA bloque
    ;

bucle:
    T_REPITEBURDA T_ENTRE expresion T_HASTA expresion T_CONFLOW bloque
    ;

entrada_salida:
    T_ECHARCUENTO T_IDENTIFICADOR T_PUNTOCOMA
    | T_LANZA T_HIGUEROTE T_PUNTOCOMA
    ;
%%

void yyerror(const char *s) {
    cerr << "Error sintáctico en línea " << yylineno << ": " << s << endl;
}