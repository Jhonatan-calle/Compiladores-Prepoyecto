%code requires {
    #include "headers/tipos.h"
    #include "headers/simbolos.h"
    #include "headers/ast.h"
    #include "headers/utils.h"
}

%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <stdarg.h>
    #include <string.h>

    extern FILE *yyin;

    int yylex(void);
    void yyerror(const char *s);
%}

%union {
    struct AST *node;
    Tipos tipo;
    char *id;
    int val;
}

%code {
    AST *root;
}


%token <val> NUM
%token <id> ID
%type <tipo> tipos tiposF
%token <tipo> INT BOOL
%token RETURN MAIN VOID AND OR TOKEN_TRUE TOKEN_FALSE
%type <node> prog lista_sentencias sentencia expr valor

%left OR
%left AND
%left '+'
%left '*'

%%

prog: tiposF MAIN '(' ')' '{' lista_sentencias '}'
    {
        $$ = new_node(TR_PROGRAMA,2,$1,$6);
        root = $$;
        // print_ast($$,0);
        gen_code(root);
        free_ast($$);
    }
    ;

tiposF: INT   { $$ = T_INT;}
       | VOID  { $$ = T_VOID;}
       ;

tipos: INT   { $$ = T_INT;}
       | BOOL  { $$ = T_BOOL;}
       ;


lista_sentencias: sentencia
    {$$ = new_node(TR_LISTA_SENTENCIAS,1,$1);}
    | lista_sentencias sentencia
    {$$ = append_child($1,$2); }
    ;

sentencia: tipos ID ';'
    {$$ = new_node(TR_DECLARACION,2,$1,$2); }
    |   ID '=' expr ';'
    {$$ = new_node(TR_ASIGNACION,2,$1,$3);}
    |   RETURN ';'
    {$$ = new_node(TR_RETURN,0); }
    |   RETURN expr ';'
    {$$ = new_node(TR_RETURN,1,$2); }
    ;


expr: valor
    { $$ = $1 ;}
    | ID
    { $$ = new_node(TR_IDENTIFICADOR, 1, $1); }
    | expr '+' expr
    { $$ = new_node(TR_SUMA, 2, $1, $3); }
    | expr '*' expr
    { $$ = new_node(TR_MULTIPLICACION, 2, $1, $3); }
    | expr AND expr
    { $$ = new_node(TR_AND, 2, $1, $3); }
    | expr OR expr
    { $$ = new_node(TR_OR, 2, $1, $3); }
    | '(' expr ')'
    { $$ = $2; }
    ;

valor: NUM
    {$$ = new_node(TR_VALOR,0,T_INT, $1);}
    | TOKEN_FALSE
    {$$ = new_node(TR_VALOR,0,T_BOOL, 0);}
    | TOKEN_TRUE
    {$$ = new_node(TR_VALOR,0,T_BOOL, 1);}
    ;
%%

int main(int argc,char *argv[]){
	t = crear_tabla(10);
	++argv,--argc;
	if (argc > 0)
		yyin = fopen(argv[0],"r");
	else
		yyin = stdin;

	yyparse();
    liberar_tabla();
}
