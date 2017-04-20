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

#ifndef YY_YY_IC_TAB_H_INCLUDED
# define YY_YY_IC_TAB_H_INCLUDED
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
    _not = 278,
    _else = 279,
    _break = 280,
    _struct = 281,
    _main = 282,
    _assign = 283,
    _import = 284,
    _leftb = 285,
    _rightb = 286,
    _leftp = 287,
    _rightp = 288,
    _leftsp = 289,
    _rightsp = 290,
    _comma = 291,
    _semicolon = 292,
    _colon = 293,
    _void = 294,
    _eofile = 295,
    _id = 296,
    _charcons = 297,
    _num = 298,
    _true = 299,
    _false = 300,
    _dnum = 301,
    _if = 302,
    _while = 303,
    _for = 304
  };
#endif

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

#line 124 "ic.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_IC_TAB_H_INCLUDED  */
