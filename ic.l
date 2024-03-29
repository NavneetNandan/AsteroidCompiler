%{
#include<string.h>
#include<stdlib.h>
#include"ic.h"
#include "ic.tab.h"
%}
%start BM
%%
[ \t]		;
[\n] 		{BEGIN 0; lineNo++;}
"break"		{BEGIN 0;return _break;}
"char"		{BEGIN 0;return _char;}
"double"	{BEGIN 0;return _double;}
"else"		{BEGIN 0;return _else;}
"float"		{BEGIN 0;return _float;}
"for"		{BEGIN 0;return _for;}
"if"		{BEGIN 0;return _if;}
"int"		{BEGIN 0;return _int;}
"long"		{BEGIN 0;return _long;}
"main"		{BEGIN 0;return _main;}
"short"		{BEGIN 0;return _short;}
"struct"	{BEGIN 0;return _struct;}//struct not in grammar
"void"		{BEGIN 0;return _void;}
"while"		{BEGIN 0;return _while;}
","		{BEGIN 0;return _comma;}
"="		{BEGIN 0;return _assign;}
";"		{BEGIN 0;return _semicolon;}
":"		{BEGIN 0;return _colon;}
"{"		{BEGIN 0;return _leftb;}
"}"		{BEGIN 0;return _rightb;}
"["		{BEGIN 0;return _leftsp;}
"]"		{BEGIN BM;return _rightsp;}
"("		{BEGIN 0;return _leftp;}
")"		{BEGIN BM;return _rightp;}
"+"		{BEGIN 0;return _plus;}
<BM>"-"		{BEGIN 0;return _minus;}
"-"		{return _uminus;}
"!"		{BEGIN 0; return _not;}
"*"		{BEGIN 0;return _mul;}
"/"		{BEGIN 0;return _div;}
"%"		{BEGIN 0;return _modulo;}
">"		{BEGIN 0;return _gt;}
">="		{BEGIN 0;return _ge;}
"<"		{BEGIN 0;return _lt;}
"<="		{BEGIN 0;return _le;}
"=="		{BEGIN 0;return _eq;}
"!="		{BEGIN 0;return _ne;}
"&&"		{BEGIN 0;return _and;}
"||"		{BEGIN 0;return _or;}
"import"    {return _import;}
"true"    {BEGIN BM;
		 	strcpy(yylval.attr.name,yytext); 
		 	yylval.attr.type=CONST; 
		 	yylval.attr.datatype=INT; 
		 	yylval.attr.value.iVal=1;
		 	return _true;}
"false"    {
			BEGIN BM;
		 	strcpy(yylval.attr.name,yytext); 
		 	yylval.attr.type=CONST; 
		 	yylval.attr.datatype=INT; 
		 	yylval.attr.value.iVal=0;
			return _false;
			}
[a-zA-Z][a-zA-Z0-9]*	{
				BEGIN BM;
				strcpy(yylval.attr.name,yytext); 
				yylval.attr.type=ID;
				return _id;
			}
[0-9]+		{
			BEGIN BM;
		 	strcpy(yylval.attr.name,yytext); 
		 	yylval.attr.type=CONST; 
		 	yylval.attr.datatype=INT; 
		 	yylval.attr.value.iVal=atoi(yytext);
		 	return _num;
		}
(([0-9]*[.][0-9]+)|([0-9]+[.][0-9]*))([eE][+-]?[0-9]+)?	{
			BEGIN BM;
		 	//strcpy(yylval.attr.name,yytext); 
		 	yylval.attr.type=CONST; 
		 	yylval.attr.datatype=DOUBLE; 
		 	yylval.attr.value.dVal=atof(yytext);
			return _dnum;
		}
['].[']		{
			BEGIN BM; 
		 	//yylval.attr.name[0]=yytext[1]; 
		 	//yylval.attr.name[1]='\0';
		 	yylval.attr.type=CONST; 
		 	yylval.attr.datatype=CHAR; 
		 	yylval.attr.value.cVal=yytext[0]; 
			return _charcons;
		}
<<EOF>>		{
			return _eofile;
		}
%%

int yywrap()
{
  return 1;
}
