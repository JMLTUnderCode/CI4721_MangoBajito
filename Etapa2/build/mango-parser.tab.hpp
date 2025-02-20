/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_HOME_JMLTUNDERCODE_CI4721_MANGOBAJITO_ETAPA2_BUILD_MANGO_PARSER_TAB_HPP_INCLUDED
# define YY_YY_HOME_JMLTUNDERCODE_CI4721_MANGOBAJITO_ETAPA2_BUILD_MANGO_PARSER_TAB_HPP_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    T_SE_PRENDE = 258,             /* T_SE_PRENDE  */
    T_ASIGNACION = 259,            /* T_ASIGNACION  */
    T_DOSPUNTOS = 260,             /* T_DOSPUNTOS  */
    T_PUNTOCOMA = 261,             /* T_PUNTOCOMA  */
    T_PUNTO = 262,                 /* T_PUNTO  */
    T_COMA = 263,                  /* T_COMA  */
    T_SIESASI = 264,               /* T_SIESASI  */
    T_OASI = 265,                  /* T_OASI  */
    T_NOJODA = 266,                /* T_NOJODA  */
    T_REPITEBURDA = 267,           /* T_REPITEBURDA  */
    T_ENTRE = 268,                 /* T_ENTRE  */
    T_HASTA = 269,                 /* T_HASTA  */
    T_CONFLOW = 270,               /* T_CONFLOW  */
    T_ECHALEBOLAS = 271,           /* T_ECHALEBOLAS  */
    T_ROTALO = 272,                /* T_ROTALO  */
    T_KIETO = 273,                 /* T_KIETO  */
    T_CULITO = 274,                /* T_CULITO  */
    T_JEVA = 275,                  /* T_JEVA  */
    T_MANGO = 276,                 /* T_MANGO  */
    T_MANGUITA = 277,              /* T_MANGUITA  */
    T_MANGUANGUA = 278,            /* T_MANGUANGUA  */
    T_NEGRO = 279,                 /* T_NEGRO  */
    T_HIGUEROTE = 280,             /* T_HIGUEROTE  */
    T_TASCLARO = 281,              /* T_TASCLARO  */
    T_SISA = 282,                  /* T_SISA  */
    T_NOLSA = 283,                 /* T_NOLSA  */
    T_ARROZCONMANGO = 284,         /* T_ARROZCONMANGO  */
    T_COLIAO = 285,                /* T_COLIAO  */
    T_AHITA = 286,                 /* T_AHITA  */
    T_AKITOY = 287,                /* T_AKITOY  */
    T_CEROKM = 288,                /* T_CEROKM  */
    T_BORRADOL = 289,              /* T_BORRADOL  */
    T_PELABOLA = 290,              /* T_PELABOLA  */
    T_UNCONO = 291,                /* T_UNCONO  */
    T_ECHARCUENTO = 292,           /* T_ECHARCUENTO  */
    T_LANZA = 293,                 /* T_LANZA  */
    T_LANZATE = 294,               /* T_LANZATE  */
    T_RESCATA = 295,               /* T_RESCATA  */
    T_HABLAME = 296,               /* T_HABLAME  */
    T_T_MEANDO = 297,              /* T_T_MEANDO  */
    T_FUERADELPEROL = 298,         /* T_FUERADELPEROL  */
    T_COMO = 299,                  /* T_COMO  */
    T_OPSUMA = 300,                /* T_OPSUMA  */
    T_OPINCREMENTO = 301,          /* T_OPINCREMENTO  */
    T_OPASIGSUMA = 302,            /* T_OPASIGSUMA  */
    T_OPRESTA = 303,               /* T_OPRESTA  */
    T_OPDECREMENTO = 304,          /* T_OPDECREMENTO  */
    T_OPASIGRESTA = 305,           /* T_OPASIGRESTA  */
    T_OPMULT = 306,                /* T_OPMULT  */
    T_OPASIGMULT = 307,            /* T_OPASIGMULT  */
    T_OPDIVDECIMAL = 308,          /* T_OPDIVDECIMAL  */
    T_OPDIVENTERA = 309,           /* T_OPDIVENTERA  */
    T_OPMOD = 310,                 /* T_OPMOD  */
    T_OPIGUAL = 311,               /* T_OPIGUAL  */
    T_OPDIFERENTE = 312,           /* T_OPDIFERENTE  */
    T_OPMAYORIGUAL = 313,          /* T_OPMAYORIGUAL  */
    T_OPMAYOR = 314,               /* T_OPMAYOR  */
    T_OPMENORIGUAL = 315,          /* T_OPMENORIGUAL  */
    T_OPMENOR = 316,               /* T_OPMENOR  */
    T_YUNTA = 317,                 /* T_YUNTA  */
    T_OSEA = 318,                  /* T_OSEA  */
    T_NELSON = 319,                /* T_NELSON  */
    T_IDENTIFICADOR = 320          /* T_IDENTIFICADOR  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 12 "src/mango-parser.y"

    int ival;
    double dval;
    char *sval;

#line 135 "/home/jmltundercode/CI4721_MangoBajito/Etapa2/build/mango-parser.tab.hpp"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_HOME_JMLTUNDERCODE_CI4721_MANGOBAJITO_ETAPA2_BUILD_MANGO_PARSER_TAB_HPP_INCLUDED  */
