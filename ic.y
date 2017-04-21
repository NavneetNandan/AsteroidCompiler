%{
#include "ic.h"
Quad *quadTable=NULL;
BBlock *bblockTable=NULL;
Label *labelTable=NULL;
char str[10];
int i;
char *ptr;
int numDim;
char labelpending[10];
char tempvar[10];
char tempLabel[10];
char switchExpResult[10];
char switchFlagName[10];
short int dataType;
short int signType;
short int storeType;
short int qualifierType;
short int dataSize;
int dimArray[DIMSIZE+1];
int totArrayElements;
extern int lineNo;
extern LNode* findSymbolHash(char*);
LNode* L;
Attr opnd1,opnd2,result;
Attr noAttr, tempAttr,constAttr,constAttr1,constAttr2,constAttr3;
Attr attr1,tempAttr1,tempAttr2,tempAttr3;
short int noDimensions;
typedef struct TFLABEL
{	
	char trueLabel[10];
  	char falseLabel[10];
}TFLABEL;
TFLABEL tflabel;
%}
%union
{
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
};

%left _or
%left _and
%left _eq _ne
%left _lt _le _gt _ge
%left _minus _plus
%left _mul _div _modulo
%nonassoc _uminus 
%token _char _int _float  _double _short _long _not
%token _else _break _struct
%token _main _assign _import
%token _leftb _rightb _leftp _rightp _leftsp _rightsp _comma _semicolon _colon
%token _void
%token _eofile
%token <attr> _id
%token <attr> _charcons
%token  <attr> _num _true _false
%token  <attr> _dnum
%type <attr> LValue
%type <attr> expression
%type <attr> Expr
%type <attr> sumExpression logicalExpression andExpression
%type <attr> unaryExpression unaryRelExpression relExpression 
%type <attr> term immutable factor mutable
%type <attr> arrayDims
%type <attr> condition
%token <tflabel> _if
%token <tflabel> _while
%token <forLabel> _for
%type <no> typeSpecifier sumop mulop relop

%%
Stmt 	: program;
program : importlist{
			initHash(HASHSIZE);
			createQuadList(&quadTable);
			createBBlockList(&bblockTable);
			createLabelsListHeader(&labelTable);
			strcpy(labelpending," ");} declarationList		{
			if(errCount == 0)
			{
				printCode(quadTable);
				split2BB(quadTable,&bblockTable);
				printBB(bblockTable);
				constructFlowGraph(bblockTable);
				printFlowGraph(bblockTable);
				printLabelsList(labelTable);
				printf("\n");
				//dispSymbolTableHash();
			}
			destroySymbolTable(HASHSIZE);
			return;
		};
importlist : importlist importstmnt| importstmnt;
importstmnt : _import _id
declarationList: Pgm; 
Pgm     : _int _main
	  _leftp _rightp _leftb statementList _rightb _eofile 

statementList   : statementList statement | statement	
	;

statement: expressionStmt
 	| vardeclaration 
 	| selectionStmt 
 	| whileStmt
 	| forStmt
 	| breakStmt;// return add

expressionStmt : expression _semicolon ;

vardeclaration   : typeSpecifier varList _semicolon
	;

varList : varList _comma mutable	
	|mutable
	;
mutable:	_id 			{
					sym.nameLen = strlen($1.name);
                                        sym.name = malloc(sym.nameLen+1);
					strcpy(sym.name,$1.name);
					sym.storage = storeType;
					sym.qualifier = qualifierType;
					sym.sign=signType;
				 	sym.subtype = BASIC; 
				 	sym.datatype = dataType; 
					sym.type = ID;
					sym.width = dataSize; 
					sym.relAddr=relAddr;
					relAddr = relAddr + sym.width;
					addSymbolHash(sym);
				}
	| _id dimList
				{
					sym.nameLen = strlen($1.name);
                                        sym.name = malloc(sym.nameLen+1);
					strcpy(sym.name,$1.name);
					sym.storage = storeType;
					sym.qualifier = qualifierType;
					sym.sign=signType;
					sym.type = ID;
				 	sym.subtype = ARRAY; 
				 	sym.datatype = dataType; 
					sym.width = dataSize; 
					totArrayElements = 1;
					if(sym.type == ARRAY)
						sym.dimArray = malloc(sizeof(int) * (dimArray[0]+1));
					totArrayElements = 1;
					for(i = 1;i <= dimArray[0];i++)
						totArrayElements *= dimArray[i];
					sym.relAddr = relAddr;
					sym.dimArray = malloc((dimArray[0]+1)*sizeof(int));
					memcpy(sym.dimArray,dimArray,(dimArray[0]+1) * sizeof(int));
					relAddr=relAddr+totArrayElements * sym.width;
					addSymbolHash(sym);
					numDim = 0;
				}
	;
dimList	: dimList _leftsp _num _rightsp 	{ 
					dimArray[0]=++numDim;
					dimArray[numDim] = $3.value.iVal;// atoi($3.name);
				}
	 |_leftsp _num _rightsp	{
				  	dimArray[0]=++numDim;
					dimArray[numDim] = $2.value.iVal;//atoi($2.name);
				}
	; 
typeSpecifier   : 
	 _char			{
					dataType = CHAR;
					dataSize=sizeof(char);
				} 
	| _short		{
					dataType = SHORT;
					dataSize=sizeof(short int);
				}
	| _int 			{
					dataType  = INT;
					dataSize=sizeof(int);
				}
	| _long			{
					dataType  = LONG;
					dataSize=sizeof(long int);
				}
	| _float 		{
					dataType  = FLOAT;
					dataSize=sizeof(float);
				}
	| _double		{
					dataType  = DOUBLE;
					dataSize = sizeof(double);
				}
	;

Expr: sumExpression	
	| logicalExpression; 

sumop : _plus {
		$$='+';
		}
		| _minus{
			$$='-';
		};
expression: LValue  _assign  Expr {
					$$ = $1;
					opnd2.type = NOP;
					if($1.subtype==BASIC)
					{
						addCode(quadTable,labelpending,ASSIGN,$3,opnd2,$1); 
					}
					else if($1.subtype == ARRAY || $1.subtype == OFFSET) //we have clarify how to differentiate bw ARRAY and OFFSET
					{
						opnd2 = $1;
						strcpy(opnd2.name,$1.offsetName);
						opnd2.type = TID;
						//opnd2.subtype = BASIC;
						result = $1;
						strcpy(result.name,$1.name);
						result.type = TID;
						result.subtype = BASIC;
						addCode(quadTable,labelpending,LASSIGN,$3,opnd2,result); 
						//format:  []= 'rightside value' 'offset' 'baseaddr'
	 				}
					
			      	}
	| LValue _assign expression { 
					$$=$1;
					opnd2.type = NOP;
					if(strcmp($1.offsetName,"")==0)
					{
						addCode(quadTable,labelpending,ASSIGN,$3,opnd2,$1); 
					}
					else
					{
						addCode(quadTable,labelpending,LASSIGN,$1,$3,$1); 
	 				}
			      	}

	;


LValue	: _id { 
			if(findSymbolHash($1.name) == NULL)
			{
				printf("%s: %d:Error %s: Undeclared Identifier\n",srcFileName,lineNo-1,$1.name);
				errCount++;
			}
			$$=$1;
			$$.subtype = BASIC;
			strcpy($$.offsetName,"");
		}
	| arrayDims {
			L = findSymbolHash($1.name);  //$1.name holds the lexeme of _id
			if(L == NULL)
			{
				printf("%s: %d:Error %s: Undeclared Identifier\n",srcFileName,lineNo-1,$1.name);
				errCount++;
			}

	   		$$.type = TID;
			$$.subtype = ARRAY;
			$$.datatype = $1.datatype;

			opnd2.type = CONST;			//opnd2 holds the multiplier
			opnd2.subtype = BASIC;
			opnd2.datatype = INT;
			opnd2.value.iVal = L->symbol.width;

			createTemp(result.name);		//result holds the displacement expr
			result.type = TID;
			result.subtype = BASIC;
			result.datatype = INT;
			strcpy($$.offsetName,result.name);	

	 		addCode(quadTable,labelpending,MUL,$1,opnd2,result);
			copyAttr2Symbol(result,&sym);
	   		addSymbolHash(sym);
	
			opnd1.type = CONST;			//opnd1 holds the base address from symbol table
			opnd1.subtype = BASIC; 		
			opnd1.datatype = LONG; 		
			opnd1.value.lVal = L->symbol.relAddr;

			opnd2.type=NOP;
	
			createTemp(result.name);		//base address from opnd1 is stored in temp mutable (result)
			result.type = TID;
			result.subtype = BASIC;
			result.datatype = INT;
	 		addCode(quadTable,labelpending,ASSIGN,opnd1,opnd2,result);
			
			sym = initSymbol();
			copyAttr2Symbol(result,&sym);
	   		addSymbolHash(sym);

			strcpy($$.name,result.name);	
	    	}
	
	;	
arrayDims	: arrayDims _leftsp Expr _rightsp 	
		{ 
			noDimensions += 1;
			createTemp($$.offsetName);
			strcpy($$.name,$1.name);
			$$.type = $1.type;
			//$$.subtype = ARRAY;
			$$.subtype = OFFSET;
			$$.datatype = $1.datatype;
			L = findSymbolHash($1.name);
			if(L == NULL)
			{
				printf("%s: %d:Error %s: Undeclared Identifier\n",srcFileName,lineNo-1,$1.name);
				errCount++;
			}
			createTemp(opnd2.name);
			opnd2.type = CONST;
			opnd2.datatype = INT;
			opnd2.value.iVal=L->symbol.dimArray[noDimensions];
	 		addCode(quadTable,labelpending,MUL,$1,opnd2,$$);
	 		addCode(quadTable,labelpending,PLUS,$$,$3,$$);
		}
	 |_id _leftsp Expr _rightsp
		{
			strcpy($$.name,$1.name);   //to propagate the mutable name
			//createTemp($$.offsetName); 
			$$.type=$1.type;
			$$.subtype=OFFSET;
			$$.datatype=$1.datatype;
			strcpy($$.offsetName,$3.name);
			opnd2.type = NOP;
			noDimensions = 1;
		}
	; 

sumExpression: sumExpression sumop term {
				switch($2){
					case '+':
						createTemp($$.name);
		 		   		addCode(quadTable,labelpending,PLUS,$1,$3,$$);
				   		$$.type = TID;
				   		sym=createTempSymbolWithType($1,$3,$$);
				   		addSymbolHash(sym);
					break;
					case '-': 
						createTemp($$.name);
		 		   		addCode(quadTable,labelpending,MINUS,$1,$3,$$);
				   		$$.type = TID;
				   		sym=createTempSymbolWithType($1,$3,$$);
				   		addSymbolHash(sym);
			   		break; 
				}
			}
			| term{//manage this
				$$=$1;
			};

mulop : _mul{
			$$='*';
		}
		| _div{
			$$='/';
		}
		| _modulo{
			$$='%';
		};

term : term mulop unaryExpression {
				switch($2){
					case '*': 
						createTemp($$.name);
		 		   		addCode(quadTable,labelpending,MUL,$1,$3,$$);
				   		$$.type = TID;
				   		sym=createTempSymbolWithType($1,$3,$$);
				   		addSymbolHash(sym);
					break;
					case '/':
						createTemp($$.name);
		 		   		addCode(quadTable,labelpending,DIV,$1,$3,$$);
				   		$$.type = TID;
				   		sym=createTempSymbolWithType($1,$3,$$);
				   		addSymbolHash(sym);
					break; 
					case '%': 
						createTemp($$.name);
		 		   		addCode(quadTable,labelpending,MOD,$1,$3,$$);
				   		$$.type = TID;
				   		sym=createTempSymbolWithType($1,$3,$$);
				   		addSymbolHash(sym);
				   	break;
				}
			}
		| unaryExpression {
			$$=$1;

		};


unaryExpression : sumop unaryExpression{
					switch($1){
						case _plus:
						break;
						case _minus: 			  		createTemp($$.name);
							opnd2.type = NOP;
					  		addCode(quadTable,labelpending,UMINUS,$2,opnd2, $$);
					   		$$.type = TID;
					   		sym=copySymbol($2,$$.name);
					   		addSymbolHash(sym);
						break;
					}
				}
				| factor{
					$$=$1;
				};
factor : LValue{
			if($1.subtype==BASIC)
						$$=$1;
					else if($1.subtype == ARRAY)
					{
						opnd1 = $1;			//opnd1 is the base address of array
						strcpy(opnd1.name,$1.name);
						opnd1.type = TID;
						opnd1.subtype = BASIC;
						opnd1.datatype = $1.datatype;

						opnd2 = $1;		       //opnd2 is the displacement of array
						strcpy(opnd2.name,$1.offsetName);
						opnd2.type = TID;
						opnd2.subtype = BASIC;
						opnd2.datatype = $1.datatype;

						$$ = $1;
			   			createTemp($$.name);
						$$.type=TID;
						$$.subtype=ARRAY;
						$$.datatype=$1.datatype;
						printf("RASSIGN = %d\n",RASSIGN);
	 		   			addCode(quadTable,labelpending,RASSIGN,opnd1,opnd2,$$);
						sym = initSymbol();
						copyAttr2Symbol($$,&sym);
			   			addSymbolHash(sym);
			   		}
		}
		| immutable{
		 	$$=$1;
		}
;
immutable : _leftp expression _rightp {
			$$=$2;	
			}
			| _num{
				$$=$1;
			} ; // define call
// Expr	: Expr _plus Expr 	{
			   		
// 			  	}
// 	| Expr _minus Expr	{
			   		
// 			  	}
 
// 	| Expr _mul Expr 	{
			   		
//                          	}
// 	| Expr _div Expr 	{
			   		
// 			 	}
// 	| Expr _modulo Expr 	{
			   		
// 			    	}
// 	| _uminus Expr 		{

// 		       		}
// 	| Expr _lt Expr 	{
// 			  		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,LT,$1,$3,$$);
// 			   		$$.type = TID;
// 			   		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 				}
	   
// 	| Expr _le Expr 	{
// 			   		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,LE,$1,$3,$$);
// 			   		$$.type = TID;
// 			   		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 				}
// 	| Expr _ge Expr 	{ 
// 			   		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,GE,$1,$3,$$);
// 			   		$$.type = TID;
// 			   		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 				}
// 	| Expr _gt Expr 	{
// 			   		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,GT,$1,$3,$$);
// 			   		$$.type = TID;
// 			   		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 				}
// 	| Expr _eq Expr 	{ 
// 			   		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,EQ,$1,$3,$$);
// 			        	$$.type = TID;
// 			   		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 			    	}
// 	| Expr _ne Expr  	{
// 			   		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,NE,$1,$3,$$);
// 			   		$$.type = TID;
// 			   		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 			      	}			
// 	| Expr _or Expr 	{
// 			   		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,OR,$1,$3,$$);
// 			   		$$.type = TID;
// 			   		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 				}
// 	| Expr _and Expr 	{ 
// 			   		createTemp($$.name);
// 	 		   		addCode(quadTable,labelpending,AND,$1,$3,$$);
// 			   		$$.type = TID;
// 			  		sym=createTempSymbolWithType($1,$3,$$);
// 			   		addSymbolHash(sym);
// 			 	}
// 	| _leftp  Expr _rightp 	{
// 					$$ = $2;
// 			   		$$.type = TID;
// 				}
// 	| LValue 		{
					// if($1.subtype==BASIC)
					// 	$$=$1;
					// else if($1.subtype == ARRAY)
					// {
					// 	opnd1 = $1;			//opnd1 is the base address of array
					// 	strcpy(opnd1.name,$1.name);
					// 	opnd1.type = TID;
					// 	opnd1.subtype = BASIC;
					// 	opnd1.datatype = $1.datatype;

					// 	opnd2 = $1;		       //opnd2 is the displacement of array
					// 	strcpy(opnd2.name,$1.offsetName);
					// 	opnd2.type = TID;
					// 	opnd2.subtype = BASIC;
					// 	opnd2.datatype = $1.datatype;

					// 	$$ = $1;
			  //  			createTemp($$.name);
					// 	$$.type=TID;
					// 	$$.subtype=ARRAY;
					// 	$$.datatype=$1.datatype;
					// 	printf("RASSIGN = %d\n",RASSIGN);
	 		 //   			addCode(quadTable,labelpending,RASSIGN,opnd1,opnd2,$$);
					// 	sym = initSymbol();
					// 	copyAttr2Symbol($$,&sym);
			  //  			addSymbolHash(sym);
						
// 					}
// 				}
// 	| _num 			{
// 					$$ = $1;
// 				}		
// 	| _dnum 		{
// 					$$=$1;
// 				}	
//         ;


logicalExpression : andExpression{
					$$ = $1;
					};

andExpression : andExpression _and unaryRelExpression{
					createTemp($$.name);
	 		   		addCode(quadTable,labelpending,AND,$1,$3,$$);
			   		$$.type = TID;
			  		sym=createTempSymbolWithType($1,$3,$$);
			   		addSymbolHash(sym);
				}
				| andExpression _or unaryRelExpression{
					createTemp($$.name);
	 		   		addCode(quadTable,labelpending,OR,$1,$3,$$);
			   		$$.type = TID;
			   		sym=createTempSymbolWithType($1,$3,$$);
			   		addSymbolHash(sym);
				}
				| unaryRelExpression{
					$$=$1;
				};

relop : _le {
			$$=1;
			}
		| _ge{
			$$=2;
			}
		| _ne{
			$$=3;
			} 
		| _lt{
			$$=4;
			}
		| _gt{
			$$=5;
			};
		| _eq{
			$$=6;
		}

relExpression : sumExpression relop sumExpression{
	switch($2)
	{
		case 1://<=
			createTemp($$.name);
		   	addCode(quadTable,labelpending,LE,$1,$3,$$);
	   		$$.type = TID;
	   		sym=createTempSymbolWithType($1,$3,$$);
	   		addSymbolHash(sym);
		break;
		case 2://>=
			createTemp($$.name);
		   		addCode(quadTable,labelpending,GE,$1,$3,$$);
	   		$$.type = TID;
	   		sym=createTempSymbolWithType($1,$3,$$);
	   		addSymbolHash(sym);
		break;
		case 4://<
			createTemp($$.name);
		   		addCode(quadTable,labelpending,LT,$1,$3,$$);
	   		$$.type = TID;
	   		sym=createTempSymbolWithType($1,$3,$$);
	   		addSymbolHash(sym);
		break;
		case 5://>
			createTemp($$.name);
		   	addCode(quadTable,labelpending,GT,$1,$3,$$);
	   		$$.type = TID;
	   		sym=createTempSymbolWithType($1,$3,$$);
	   		addSymbolHash(sym);
		break;
		case 3://!=
			createTemp($$.name);
		   		addCode(quadTable,labelpending,NE,$1,$3,$$);
	   		$$.type = TID;
	   		sym=createTempSymbolWithType($1,$3,$$);
	   		addSymbolHash(sym);
		break;
		case 6:
			createTemp($$.name);
		   	addCode(quadTable,labelpending,EQ,$1,$3,$$);
	        $$.type = TID;
	   		sym=createTempSymbolWithType($1,$3,$$);
	   		addSymbolHash(sym);
		break;
	}
};
unaryRelExpression : _not unaryRelExpression 
					| relExpression{
						$$=$1;
					} 
					| _true{
					$$=$1;
					}
					| _false{
						$$=$1;
					}


selectionStmt  : _if _leftp logicalExpression	{
					createLabel($1.falseLabel);
					opnd2.type = CONST;
					opnd2.datatype = INT;
					opnd2.value.iVal = 0;
					createTemp(result.name);
//					result.type = CONST;
					result.type = LABEL;
					strcpy(result.name,$1.falseLabel);
					//result.datatype = FALSE;
//					result.value.string = malloc(strlen($1.falseLabel)+1);
					addCode(quadTable,labelpending,IFEQ,$3,opnd2,result);
                              	} 
	  _rightp Stmtlist 	{
                                	strcpy(labelpending,$1.falseLabel);
					opnd1.type=NOP;
					opnd2.type=NOP;
					result.type=NOP;
					addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
				}
	;

whileStmt: _while		{ 
					createLabel($1.trueLabel); 
printf("In while->%s: ....\n",$1.trueLabel);
					strcpy(labelpending,$1.trueLabel);
				}
	_leftp logicalExpression	{
				      	createLabel($1.falseLabel);
printf("In while->%s: ....\n",$1.falseLabel);
					opnd2.type = CONST;
					opnd2.datatype = INT;
					opnd2.value.iVal = 0;
					createTemp(result.name);
					result.type = LABEL;
					strcpy(result.name,$1.falseLabel);
					addCode(quadTable,labelpending,IFEQ,$4,opnd2,result);
				}
	_rightp Stmtlist	{
					opnd1.type = NOP;
					opnd2.type = NOP;
					result.type = LABEL;
					strcpy(result.name,$1.trueLabel);
					addCode(quadTable," ",GOTO,opnd1, opnd2,result);
                                	strcpy(labelpending,$1.falseLabel);
					opnd1.type=NOP;
					opnd2.type=NOP;
					result.type=NOP;
					addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
				}
	;


forStmt : _for			{
					createLabel($1.cond2Label);
					createLabel($1.cond3Label);
					createLabel($1.cond2TestLabel);
					createLabel($1.nextStmtLabel);
				} 
  _leftp expression _semicolon 	{ 
					strcpy(labelpending,$1.cond2Label);
				} 
	logicalExpression _semicolon 	{
					result.type=LABEL;
					strcpy(result.name,$1.cond2TestLabel);
					opnd1.type=NOP;
					opnd2.type=NOP;
					addCode(quadTable," ",GOTO,opnd1,opnd2,result);
					//addCode(quadTable," ",GOTO," "," ",$1.cond2TestLabel);
					strcpy(labelpending,$1.cond3Label);
				} 
	expression _rightp 	{
					result.type=LABEL;
					strcpy(result.name,$1.cond2Label);
					opnd1.type=NOP;
					opnd2.type=NOP;
					addCode(quadTable," ",GOTO,opnd1,opnd2,result);
					strcpy(labelpending,$1.cond2TestLabel);
					opnd2.type = CONST;
					opnd2.datatype = INT;
					opnd2.value.iVal = 0;
					result.type=LABEL;
					strcpy(result.name,$1.nextStmtLabel);
		     			addCode(quadTable,labelpending,IFEQ,$7,opnd2,result);
				} 
	Stmtlist 		{
					opnd1.type = NOP;
					opnd2.type = NOP;
					result.type=LABEL;
					strcpy(result.name,$1.cond3Label);
					addCode(quadTable," ",GOTO,opnd1,opnd2,result); 
					strcpy(labelpending,$1.nextStmtLabel);
					opnd1.type=NOP;
					opnd2.type=NOP;
					result.type=NOP;
					addCode(quadTable,labelpending,NOP,opnd1,opnd2,result);
				}
	;

breakStmt: _break _semicolon
	;


Stmtlist: _leftb statementList _rightb 
	| statement 
	| _semicolon
	;

%%

int yyerror(char *errmsg)
{
	printf("Error has occurred\n%s\n",errmsg);
	exit(-1);
}

