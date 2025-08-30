%{
    #include <string.h>
    #include <stdio.h>
	#include <stdlib.h>
    #include "sintaxis.tab.h" //biblio del sintactico 
%}

%option noyywrap
%option yylineno

letra [a-zA-Z]      
digito [0-9]   
ID {letra}({letra}|{digito})*

%%

"int"       { return INT; }
"bool"      { return BOOL; }
"void"      { return VOID; }
"main"      { return MAIN; }
"return"    { return RETURN; }
"true"      { return TOKEN_TRUE; }
"false"     { return TOKEN_FALSE; }
"&&"        { return AND; }
"||"        { return OR; }

{ID}        { 
	yylval.id = strdup(yytext);
	return ID; 
	}

{digito}+   { 
	yylval.val = atoi(yytext);
	return NUM; 
	}

[+*;(){}=] { return *yytext; }

[ \t\n\r]+  ;   /* ignorar espacios y saltos de línea */

.           { printf("Caracter no reconocido: %s\n", yytext); }

%%

void yyerror(){
	printf("%s%d\n","-> ERROR Sintactico en la linea: ",yylineno);
}

