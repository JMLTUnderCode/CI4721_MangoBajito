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
    double dval;
    char *sval;
}

%token T_SE_PRENDE T_ASIGNACION T_DOSPUNTOS T_PUNTOCOMA T_COMA
%token T_SIESASI T_OASI T_NOJODA
%token T_REPITEBURDA T_ENTRE T_HASTA T_CONFLOW
%token T_ECHALEBOLAS
%token T_ROTALO T_KIETO
%token T_CULITO T_JEVA
%token T_MANGO T_MANGUITA T_MANGUANGUA T_NEGRO T_HIGUEROTE
%token T_TASCLARO T_SISA T_NOLSA T_ARROZCONMANGO T_COLIAO T_PUNTO
%token T_AHITA T_AKITOY T_CEROKM T_BORRADOL T_PELABOLA
%token T_UNCONO
%token T_ECHARCUENTO T_LANZA T_LANZATE
%token T_RESCATA T_HABLAME
%token T_T_MEANDO T_FUERADELPEROL T_COMO
%token T_OPSUMA T_OPRESTA T_OPINCREMENTO T_OPDECREMENTO T_OPASIGRESTA T_OPASIGSUMA T_OPASIGMULT
%token T_OPMULT T_OPDIVDECIMAL T_OPDIVENTERA T_OPMOD
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
    T_SE_PRENDE T_IZQPAREN T_DERPAREN T_IZQLLAVE instrucciones T_DERLLAVE { cout << "Programa válido." << endl; symbolTable.print_table(); } 
    ;

instrucciones:
    | instrucciones instruccion T_PUNTOCOMA
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
    | T_IDENTIFICADOR operadores_sufijo 
    | T_LANZATE expresion
    | T_BORRADOL T_IDENTIFICADOR 
    | declaracion T_ASIGNACION expresion
    | T_BORRADOL T_IDENTIFICADOR T_PUNTO T_IDENTIFICADOR 
    ;

declaracion:
    tipo_declaracion T_IDENTIFICADOR T_DOSPUNTOS tipo_valor
    ;

declaracion_aputador:
    | T_AHITA
    ;

tipo_declaracion:
    declaracion_aputador T_CULITO 
    | declaracion_aputador T_JEVA
    ;

tipo_valor_arreglo:
    | T_IZQCORCHE expresion T_DERCORCHE
    ;
tipo_valor:
    T_MANGO tipo_valor_arreglo
    | T_MANGUITA tipo_valor_arreglo
    | T_MANGUANGUA tipo_valor_arreglo
    | T_NEGRO tipo_valor_arreglo
    | T_HIGUEROTE tipo_valor_arreglo
    | T_TASCLARO tipo_valor_arreglo
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
    T_CEROKM tipo_valor T_IZQPAREN T_VALUE T_DERPAREN
    | T_CEROKM tipo_valor T_IZQCORCHE T_VALUE T_DERCORCHE
    ;

expresion:
    T_IDENTIFICADOR 
    | T_VALUE 
    | T_PELABOLA
    | valores_booleanos 
    | expresion_apuntador 
    | expresion_nuevo
    | arreglo
    | operadores_unario expresion
    | expresion operador_binario expresion
    ;

operadores_aritmeticos:
    T_OPSUMA 
    | T_OPRESTA 
    | T_OPMULT 
    | T_OPDIVDECIMAL 
    | T_OPDIVENTERA 
    | T_OPMOD
    ;

operadores_comparacion:
    T_OPIGUAL 
    | T_OPDIFERENTE 
    | T_OPMAYOR 
    | T_OPMAYORIGUAL 
    | T_OPMENOR 
    | T_OPMENORIGUAL
    ;

operadores_booleanos:
    T_YUNTA | T_OSEA
    ;

operadores_unario:
    T_NELSON
    ;

operador_binario:
    operadores_aritmeticos 
    | operadores_comparacion 
    | operadores_booleanos
    ;

operadores_sufijo:
    T_OPINCREMENTO
    | T_OPDECREMENTO
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
    | secuencia_declaraciones T_PUNTOCOMA T_IDENTIFICADOR T_DOSPUNTOS tipo_valor 
    | T_IDENTIFICADOR T_DOSPUNTOS tipo_valor 
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
    tipo_valor 
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