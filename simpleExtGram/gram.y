%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int yylex();
  void yyerror(char* msg);
%}

%code requires {
  #include "ast/ast.h"
  extern Ast* root;
}

%code {
  Ast* root = NULL;
}

%union{
  int numero;
  char tipoEntero[7];
  char tipoVoid[5];
  char valorBoolVerdadero[9];
  char valorBoolFalso[5];
  char tipoBooleano[11];
  char reservadas[8];
  char* identificador;
  Ast *node;
}

%token <tipoEntero> T_INT
%token <tipoBooleano> T_BOOL
%token <tipoVoid> T_VOID

%token <reservadas> R_RETURN
%token <reservadas> R_SI
%token <reservadas> R_SINO
%token <reservadas> R_MIENTRAS
%token <reservadas> R_PARA
%token <reservadas> R_REPETIR
%token <reservadas> R_FINBLOQUE

%token <valorBoolVerdadero> V_VERDADERO
%token <valorBoolFalso> V_FALSO
%token <numero> V_NUMERO

%token <identificador> ID

%token FinLinea

%left "||"
%left "&&"
%left "=="
%left '+' '-'
%left '*' '/'
%precedence '!'
%precedence UMINUS

%type <node> prog
%type <node> instrucciones asignaciones asignacion declaracion declaraciones
%type <node> intTypeDeclaration boolTypeDeclaration voidTypeDeclaration
%type <node> declaracionFuncion expresion primario

%%

prog
  : instrucciones                             { root = $1; printArbol(root); }
  ;

instrucciones
  : declaraciones asignaciones R_RETURN expresion FinLinea      { $$ = ast_seq($1, ast_seq($2, ast_ret($3, $4))); }
  | declaraciones asignaciones                                  { $$ = ast_seq($1, $2); }
  | declaraciones                                               { $$ = $1; }
  ;

asignaciones
  : asignaciones asignacion                   { $$ = ast_seq($1, $2); }
  | asignacion                                { $$ = $1; }
  ;

asignacion
  : ID '=' expresion FinLinea          { $$ = ast_assign($1, $3); }
  ;

declaraciones
  : declaraciones declaracion                 { $$ = ast_seq($1, $2); }
  | declaracion                               { $$ = $1; }
  ;

declaracion
  : declaracionFuncion                        { $$ = $1; }
  | intTypeDeclaration  FinLinea              { $$ = $1; }
  | boolTypeDeclaration FinLinea              { $$ = $1; }
  | voidTypeDeclaration FinLinea              { $$ = $1; }
  ;

intTypeDeclaration
  : T_INT ID '=' expresion             { $$ = ast_decl($1, ast_assign($2, $4)); }
  | T_INT ID                                  { $$ = ast_decl($1, ast_id($2)); }
  ;

boolTypeDeclaration
  : T_BOOL ID '=' expresion            { $$ = ast_decl($1, ast_assign($2, $4)); }
  | T_BOOL ID                                 { $$ = ast_decl($1, ast_id($2)); }
  ;

voidTypeDeclaration
  : T_VOID ID     { $$ = ast_decl($1, ast_id($2)); }
  ;

declaracionFuncion
  : T_INT   ID '(' ')' '{' '}'               { printf("funcInt(){} \n"); $$ = ast_decl($1, ast_id($2)); }
  | T_BOOL  ID '(' ')' '{' '}'               { printf("funcBool(){} \n"); $$ = ast_decl($1, ast_id($2)); }
  | T_VOID  ID '(' ')' '{' '}'               { printf("funcVoid(){} \n"); $$ = ast_decl($1, ast_id($2)); }
  | T_INT   ID '(' ')' '{' instrucciones '}' { printf("funcInt(){ instrucciones } \n"); $$ = ast_decl($1, ast_seq(ast_id($2), $6)); }
  | T_BOOL  ID '(' ')' '{' instrucciones '}' { printf("funcBool(){ instrucciones } \n"); $$ = ast_decl($1, ast_seq(ast_id($2), $6)); }
  | T_VOID  ID '(' ')' '{' instrucciones '}' { printf("funcVoid(){ instrucciones } \n"); $$ = ast_decl($1, ast_seq(ast_id($2), $6)); }
  ;

primario
  : V_NUMERO      { $$ = ast_num($1); }
  | V_VERDADERO   { $$ = ast_bool(1); }
  | V_FALSO       { $$ = ast_bool(0); }
  | ID            { $$ = ast_id($1); }
  ;

expresion
  : primario                          { $$ = $1; }
  | '(' expresion ')'                 { $$ = $2; }
  | '!' expresion                     { $$ = ast_unop("!", $2); }
  | '-' expresion %prec UMINUS        { $$ = ast_unop("neg", $2); } /* para el signo menos unario, defino precedencia con %prec UMINUS, osea, resuelve el conflicto entre el unario y el binario */
  | expresion '+' expresion           { $$ = ast_binop("+", $1, $3); }
  | expresion '-' expresion           { $$ = ast_binop("-", $1, $3); }
  | expresion '*' expresion           { $$ = ast_binop("*", $1, $3); }
  | expresion '/' expresion           { $$ = ast_binop("/", $1, $3); }
  | expresion "==" expresion          { $$ = ast_binop("==", $1, $3); }
  | expresion "&&" expresion          { $$ = ast_binop("&&", $1, $3); }
  | expresion "||" expresion          { $$ = ast_binop("||", $1, $3); }
  ;

%%
