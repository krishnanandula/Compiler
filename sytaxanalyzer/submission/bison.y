%{
#include <cstdio>
#include <iostream>
using namespace std;


extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" FILE *yyout;
extern int line_num;
 
void yyerror(const char *s);
%}



%union {
	int ival;
	float fval;
	char *sval;
	bool bval;
}

%token CLASS PROGRAM CALLOUT  VOID TRUE FALSE DECIMAL 
%token  END ENDL
%token  TCASSIGNMENT TCEQ TCNE TCLT TCLE TCGT TCGE 
%token  TCLP TCRP TCLB TCRB TCSRB TCSLB TCOMMA TCDOT 
%token  ADDITION SUBTRACTION MULTIPLICATION DIVISION
%token <ival> INT
%token <ival> NUMBER
%token <ival> DOUBLE
%token <sval> STRING
%token <sval> IDENTI
%token <sval> BOOLEAN
%token <sval> TCSEMICOLON


%left ADDITION  SUBTRACTION
%left MULTIPLICATION  DIVISION

%start program
%%

program: CLASS PROGRAM TCLB DeclList TCRB  { fprintf(yyout, "PROGRAM ENCOUNTERED" ); }
	;

DeclList:
  DeclList Decl        
 | Decl                 
;

Decl:
 VarDecl 
 |VarDeclSize
;

VarDecl:
  BOOLEAN IDENTI TCSEMICOLON     	{fprintf(yyout, "BOOLEAN VARIABLE DECLARED. ID= %s\n",$2);}
 |INT IDENTI TCSEMICOLON    		{fprintf(yyout, "INT VARIABLE DECLARED. ID= %s\n",$2);}
 |DOUBLE IDENTI TCSEMICOLON      	{fprintf(yyout, "DOUBLE VARIABLE DECLARED. ID= %s\n",$2);}
 |STRING IDENTI TCSEMICOLON      	{fprintf(yyout, "STRING VARIABLE DECLARED. ID= %s\n",$2);}
;

VarDeclSize:
 INT IDENTI TCSLB NUMBER TCSRB TCSEMICOLON         { fprintf(yyout, "INT VARIABLE DECLARED. ID= %s SIZE =%d\n",$2,$4);}
 |DOUBLE IDENTI TCSLB NUMBER TCSRB TCSEMICOLON      { fprintf(yyout, "DOUBLE VARIABLE DECLARED. ID= %s SIZE =%d\n",$2,$4);}
 |STRING IDENTI TCSLB NUMBER TCSRB TCSEMICOLON       { fprintf(yyout, "STRING VARIABLE DECLARED. ID= %s SIZE =%d\n",$2,$4);}
 |BOOLEAN IDENTI TCSLB NUMBER TCSRB TCSEMICOLON       { fprintf(yyout, "BOOLEAN VARIABLE DECLARED. ID= %s SIZE =%d\n",$2,$4); }
;



%%

int main(int argc,char* argv[]) {
	
	// open a file handle to a particular file:
	FILE *myfile = fopen(argv[1], "r");
	yyout = fopen("bison_output.txt","w+");
	// make sure it's valid:
	if (!myfile) {
		cout << "I can't open file!" << endl;
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
	fclose(yyout);
}

void yyerror(const char *s) {
	cout << "parse error on line " << line_num << "!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}

