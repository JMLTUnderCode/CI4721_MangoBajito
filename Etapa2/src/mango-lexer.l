%{
#include <iostream>
#include <string>
#include "mango-parser.tab.hpp"

using namespace std;
%}

%option header="build/mango-lexer.yy.hpp"
%option noyywrap

/* Definición de patrones para tokens */
MANGO         [0-9]+
MANGUITA      [0-9]+\.[0-9]+
MANGUANGUA    [0-9]+\.[0-9]+[eE][-+]?[0-9]+
NEGRO         '\.'
HIGUEROTE     \"[^\"]*\"
IDENTIFICADOR [a-zA-Z_][a-zA-Z0-9_]*

%%
"se_prende"      return T_SE_PRENDE;

"="              return T_ASIGNACION;
":"              return T_DOSPUNTOS;
";"              return T_PUNTOCOMA;
"."              return T_PUNTO;
"->"			 return T_FLECHA;
","              return T_COMA;

"si_es_asi"      return T_SIESASI;
"o_asi"          return T_OASI;
"nojoda"         return T_NOJODA;

"repite_burda"    return T_REPITEBURDA;
"entre"           return T_ENTRE;
"hasta"           return T_HASTA;
"con_flow"        return T_CONFLOW;

"echale_bolas_si" return T_ECHALEBOLAS;

"rotalo"          return T_ROTALO;
"uy_kieto"        return T_KIETO;

"culito"          return T_CULITO;
"jeva"            return T_JEVA;

"mango"           return T_MANGO;
"manguita"        return T_MANGUITA;
"manguangua"      return T_MANGUANGUA;
"negro"           return T_NEGRO;
"higuerote"       return T_HIGUEROTE;
"tas_claro"       return T_TASCLARO;
"Sisa"            return T_SISA;
"Nolsa"           return T_NOLSA;
"arroz_con_mango" return T_ARROZCONMANGO;
"coliao"          return T_COLIAO;

"ahi_ta"          return T_AHITA;
"aki_toy"         return T_AKITOY;
"cero_km"         return T_CEROKM;
"borradol"        return T_BORRADOL;
"pelabola"        return T_PELABOLA;

"un_coño"         return T_UNCONO;

"echar_cuento"    return T_ECHARCUENTO;
"lanza"           return T_LANZA;
"lanzate"         return T_LANZATE;

"rescata"         return T_RESCATA;
"hablame"         return T_HABLAME;

"meando"          return T_T_MEANDO;
"fuera_del_perol" return T_FUERADELPEROL;
"como"            return T_COMO;

"+"               return T_OPSUMA;
"++"              return T_OPINCREMENTO;
"+="              return T_OPASIGSUMA;
"-"               return T_OPRESTA;
"--"              return T_OPDECREMENTO;
"-="              return T_OPASIGRESTA;
"*"               return T_OPMULT;
"*="              return T_OPASIGMULT;
"/"               return T_OPDIVDECIMAL;
"//"              return T_OPDIVENTERA;
"%"               return T_OPMOD;
"**"			  return T_OPEXP;
"igualito"        return T_OPIGUAL;
"nie"             return T_OPDIFERENTE;
"lidel"           return T_OPMAYORIGUAL;
"mayol"           return T_OPMAYOR;
"peluche"         return T_OPMENORIGUAL;
"menol"           return T_OPMENOR;
"yunta"           return T_YUNTA;
"o_sea"           return T_OSEA;
"nelson"          return T_NELSON;

{MANGO} {
    yylval.ival = atoi(yytext);
    cout << "Entero: " << yytext << endl;
    return T_VALUE;  // Token específico para enteros
}

{MANGUITA} {
    yylval.fval = strtof(yytext, nullptr);
    cout << "Float: " << yytext << endl;
    return T_VALUE;  // Token específico para floats
}

{MANGUANGUA} {
    yylval.dval = strtod(yytext, nullptr);
    cout << "Double: " << yytext << endl;
    return T_VALUE;  // Token específico para doubles
}

{NEGRO} {
    yylval.cval = yytext[1];  // Extrae el carácter (ignora las comillas)
    cout << "Carácter: " << yytext << endl;
    return T_VALUE;  // Token específico para caracteres
}

{HIGUEROTE} {
    // Elimina las comillas y guarda el string
    yylval.sval = strdup(yytext + 1);
    yylval.sval[strlen(yylval.sval) - 1] = '\0';
    cout << "String: " << yylval.sval << endl;
    return T_VALUE;  // Token específico para strings
}

{IDENTIFICADOR} {
    yylval.sval = strdup(yytext);
    cout << "ID: " << yytext << endl;
    return T_IDENTIFICADOR;
}


[ \t\r\n]+         ;  /* Ignora espacios */
"#".*            ;  /* Comentarios de una línea */
"("               return T_IZQPAREN;
")"               return T_DERPAREN;
"{"               return T_IZQLLAVE;
"}"               return T_DERLLAVE;
"["               return T_IZQCORCHE;
"]"               return T_DERCORCHE;
.                { cerr << "Error léxico: " << yytext << endl; }

%%
