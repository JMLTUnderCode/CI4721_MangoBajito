%{
#include <iostream>
#include <string>
#include "mango_parser.tab.hpp"

using namespace std;

// Define la estructura de ubicación
typedef struct YYLTYPE {
	int first_line;
	int first_column;
} YYLTYPE;

// Declara la variable global de ubicación
YYLTYPE yylloc;

// Variables para seguimiento de ubicación
extern YYLTYPE yylloc;		// Declaración externa de Bison
int current_column = 1;		// Lleva el seguimiento de la columna actual

// Macro para actualizar ubicación
#define UPDATE_LOC \
	yylloc.first_line = yylineno; \
	yylloc.first_column = current_column; \
	current_column += yyleng;

%}

%option header="build/mango_lexer.yy.hpp"
%option noyywrap
%option yylineno

/* Definición de patrones para tokens */
MANGO			(0|[1-9][0-9]{0,8}|1[0-9]{9}|20[0-9]{8}|21[0-3][0-9]{7}|214[0-6][0-9]{6}|2147[0-3][0-9]{5}|21474[0-7][0-9]{4}|214748[0-2][0-9]{3}|2147483[0-5][0-9]{2}|21474836[0-3][0-9]|214748364[0-7])
MANGUITA		[0-9]+\.[0-9]{1,7}
MANGUANGUA		([0-9]*\.?[0-9]{1,15}|[0-9]+\.?[0-9]*)([eE][+-]?[0-9]+)?
NEGRO           \'(\\0|\\.|[^\\'])\'
HIGUEROTE		\"[^\"]*\"
IDENTIFICADOR	[a-zA-Z_][a-zA-Z0-9_]*
CASTING			\(mango\)|\(manguita\)|\(manguangua\)|\(negro\)|\(higuerote\)|\(tas_claro\)

%%
[ \t]+				{ current_column += yyleng; }  // Espacios/tabs
\r?\n				{ current_column = 1; }  // Saltos de línea

".me_pide"          { UPDATE_LOC return T_MEPIDE; }
"se_prende"			{ UPDATE_LOC return T_SE_PRENDE; }

"="					{ UPDATE_LOC return T_ASIGNACION; }
":"					{ UPDATE_LOC return T_DOSPUNTOS; }
";"					{ UPDATE_LOC return T_PUNTOCOMA; }
"."					{ UPDATE_LOC return T_PUNTO; }
"->"				{ UPDATE_LOC return T_FLECHA; }
","					{ UPDATE_LOC return T_COMA; }

"si_es_asi"			{ UPDATE_LOC return T_SIESASI; }
"o_asi"				{ UPDATE_LOC return T_OASI; }
"nojoda"			{ UPDATE_LOC return T_NOJODA; }

"repite_burda"		{ UPDATE_LOC return T_REPITEBURDA; }
"entre"				{ UPDATE_LOC return T_ENTRE; }
"hasta"				{ UPDATE_LOC return T_HASTA; }
"con_flow"			{ UPDATE_LOC return T_CONFLOW; }

"echale_bolas_si"	{ UPDATE_LOC return T_ECHALEBOLAS; }

"rotalo"			{ UPDATE_LOC return T_ROTALO; }
"uy_kieto"			{ UPDATE_LOC return T_KIETO; }

"culito"			{ UPDATE_LOC return T_CULITO; }
"jeva"				{ UPDATE_LOC return T_JEVA; }

"mango"				{ UPDATE_LOC return T_MANGO; }
"manguita"			{ UPDATE_LOC return T_MANGUITA; }
"manguangua"		{ UPDATE_LOC return T_MANGUANGUA; }
"negro"				{ UPDATE_LOC return T_NEGRO; }
"higuerote"			{ UPDATE_LOC return T_HIGUEROTE; }
"tas_claro"			{ UPDATE_LOC return T_TASCLARO; }
"Sisa"				{ 
						UPDATE_LOC
						yylval.att_val.type = Type_and_Value::BOOL;
						yylval.att_val.sval = strdup(yytext);
						return T_SISA;
					}
"Nolsa"				{ 
						UPDATE_LOC
						yylval.att_val.type = Type_and_Value::BOOL;
						yylval.att_val.sval = strdup(yytext);
						return T_NOLSA; 
					}

"arroz_con_mango"	{ UPDATE_LOC return T_ARROZCONMANGO; }
"coliao"			{ UPDATE_LOC return T_COLIAO; }

"ahi_ta"			{ UPDATE_LOC return T_AHITA; }
"aki_toy"			{ UPDATE_LOC return T_AKITOY; }
"cero_km"			{ UPDATE_LOC return T_CEROKM; }
"borradol"			{ UPDATE_LOC return T_BORRADOL; }
"pelabola"			{ UPDATE_LOC return T_PELABOLA; }

"un_coño"			{ UPDATE_LOC return T_UNCONO; }

"echar_cuento"		{ UPDATE_LOC return T_ECHARCUENTO; }
"lanza"				{ UPDATE_LOC return T_LANZA; }
"lanzate"			{ UPDATE_LOC return T_LANZATE; }

"rescata"			{ UPDATE_LOC return T_RESCATA; }
"hablame"			{ UPDATE_LOC return T_HABLAME; }

"meando"			{ UPDATE_LOC return T_T_MEANDO; }
"fuera_del_perol"	{ UPDATE_LOC return T_FUERADELPEROL; }
"como"				{ UPDATE_LOC return T_COMO; }

"+"					{ UPDATE_LOC return T_OPSUMA; }
"++"				{ UPDATE_LOC return T_OPINCREMENTO; }
"+="				{ UPDATE_LOC return T_OPASIGSUMA; }
"-"					{ UPDATE_LOC return T_OPRESTA; }
"--"				{ UPDATE_LOC return T_OPDECREMENTO; }
"-="				{ UPDATE_LOC return T_OPASIGRESTA; }
"*"					{ UPDATE_LOC return T_OPMULT; }
"*="				{ UPDATE_LOC return T_OPASIGMULT; }
"/"					{ UPDATE_LOC return T_OPDIVDECIMAL; }
"//"				{ UPDATE_LOC return T_OPDIVENTERA; }
"%"					{ UPDATE_LOC return T_OPMOD; }
"**"				{ UPDATE_LOC return T_OPEXP; }
"igualito"			{ UPDATE_LOC return T_OPIGUAL; }
"nie"				{ UPDATE_LOC return T_OPDIFERENTE; }
"lidel"				{ UPDATE_LOC return T_OPMAYORIGUAL; }
"mayol"				{ UPDATE_LOC return T_OPMAYOR; }
"peluche"			{ UPDATE_LOC return T_OPMENORIGUAL; }
"menol"				{ UPDATE_LOC return T_OPMENOR; }
"yunta"				{ UPDATE_LOC return T_YUNTA; }
"o_sea"				{ UPDATE_LOC return T_OSEA; }
"nelson"			{ UPDATE_LOC return T_NELSON; }

{MANGO} {
	UPDATE_LOC
	yylval.att_val.type = Type_and_Value::INT;
	yylval.att_val.ival = atoi(yytext);
	return T_VALUE;
}

{MANGUITA} {
	UPDATE_LOC
	yylval.att_val.type = Type_and_Value::FLOAT;
	yylval.att_val.fval = strtof(yytext, nullptr);
	return T_VALUE;
}

{MANGUANGUA} {
	UPDATE_LOC
	yylval.att_val.type = Type_and_Value::DOUBLE;
	yylval.att_val.dval = strtod(yytext, nullptr);
	return T_VALUE;
}

{NEGRO} {
	UPDATE_LOC

	yylval.att_val.type = Type_and_Value::CHAR;

	if (yytext[1] == '\\' && yytext[2] == '0') {
		yylval.att_val.cval = '\0';
	} else if (yyleng == 3 && yytext[0] == '\'' && yytext[2] == '\'') {
		yylval.att_val.cval = yytext[1];
	} else {
		// No debería llegar aquí, pero por seguridad:
		cerr << "Error léxico en línea " << yylloc.first_line 
			<< ", columna " << yylloc.first_column 
			<< ": Carácter inválido '" << yytext << "'" << endl;
			continue;
	}

	return T_VALUE;
}

{HIGUEROTE} {
	UPDATE_LOC
	yylval.att_val.type = Type_and_Value::STRING;
	yytext[yyleng - 1] = '\0';
	yylval.att_val.sval = strdup(yytext + 1);
	return T_VALUE;
}

{IDENTIFICADOR} {
	UPDATE_LOC
	yylval.sval = strdup(yytext);
	return T_ID;
}

{CASTING} { 
	UPDATE_LOC
	yytext[yyleng - 1] = '\0';
	yylval.sval = strdup(yytext + 1);
	return T_CASTEO;
}

"#".*	;  /* Comentarios de una línea */
"("		{ UPDATE_LOC return T_IZQPAREN; }
")"		{ UPDATE_LOC return T_DERPAREN; }
"{"		{ UPDATE_LOC return T_IZQLLAVE; }
"}"		{ UPDATE_LOC return T_DERLLAVE; }
"["		{ UPDATE_LOC return T_IZQCORCHE; }
"]"		{ UPDATE_LOC return T_DERCORCHE; }

.		{
			UPDATE_LOC
			cerr << "Error léxico en línea " << yylloc.first_line 
			<< ", columna " << yylloc.first_column 
			<< ": Carácter inválido '" << yytext << "'" << endl;
			continue;
		}
%%