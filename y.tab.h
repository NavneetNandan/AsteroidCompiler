/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    _or = 258,
    _and = 259,
    _eq = 260,
    _ne = 261,
    _lt = 262,
    _le = 263,
    _gt = 264,
    _ge = 265,
    _minus = 266,
    _plus = 267,
    _mul = 268,
    _div = 269,
    _modulo = 270,
    _uminus = 271,
    _char = 272,
    _int = 273,
    _float = 274,
    _double = 275,
    _short = 276,
    _long = 277,
    _else = 278,
    _break = 279,
    _struct = 280,
    _main = 281,
    _assign = 282,
    _import = 283,
    _leftb = 284,
    _rightb = 285,
    _leftp = 286,
    _rightp = 287,
    _leftsp = 288,
    _rightsp = 289,
    _comma = 290,
    _semicolon = 291,
    _colon = 292,
    _void = 293,
    _eofile = 294,
    _id = 295,
    _charcons = 296,
    _num = 297,
    _dnum = 298,
    _if = 299,
    _while = 300,
    _for = 301
  };
#endif
/* Tokens.  */
#define _or 258
#define _and 259
#define _eq 260
#define _ne 261
#define _lt 262
#define _le 263
#define _gt 264
#define _ge 265
#define _minus 266
#define _plus 267
#define _mul 268
#define _div 269
#define _modulo 270
#define _uminus 271
#define _char 272
#define _int 273
#define _float 274
#define _double 275
#define _short 276
#define _long 277
#define _else 278
#define _break 279
#define _struct 280
#define _main 281
#define _assign 282
#define _import 283
#define _leftb 284
#define _rightb 285
#define _leftp 286
#define _rightp 287
#define _leftsp 288
#define _rightsp 289
#define _comma 290
#define _semicolon 291
#define _colon 292
#define _void 293
#define _eofile 294
#define _id 295
#define _charcons 296
#define _num 297
#define _dnum 298
#define _if 299
#define _while 300
#define _for 301

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 37 "ic.y" /* yacc.c:1909  */

  char name[NAMESIZE];
  int no;
  Attr attr;
  
  /*Label label;*/
  struct tfLabel
  {	
	char trueLabel[10];
  	char falseLabel[10];
  }tflabel;
 struct ForLabel
 {
	char cond2Label[10];
	char cond3Label[10];
	char cond2TestLabel[10];
	char nextStmtLabel[10];
 }forLabel;

#line 166 "y.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
