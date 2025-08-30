%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "gram.tab.h"

  void yyerror(char* msg);

  extern FILE *yyin;
%}

%option noyywrap
%option yylineno

letra                 [a-zA-Z]
numero                [0-9]+
valorBoolVerdadero    True|Verdadero
valorBoolFalso        False|Falso
identificador         {letra}({letra}|{numero}|_)*
cadena                \"([^"])*\"
tipoEntero            Int|Integer|Entero
tipoBooleano          Bool|Boolean|ValorVerdad
tipoString            String|Cadena
tipoVoid              Void|Vacio
reservadaRetorno      Return|Retornar
condicionalSi         If|Si
condicionalSino       Else|Sino
iteracionMientras     While|Mientras
iteracionPara         For|Para
iteracionRepetir      Do|Repetir
finEstructura         End|Fin
comentarioUnilinea    #[^\n]*
comentarioMultilinea  "#-"(.|\n)*"-#"
eol                   ";"


%%

{eol}                   { return FinLinea; }

{tipoEntero}            { strcpy(yylval.tipoEntero, yytext); return T_INT; }
{tipoBooleano}          { strcpy(yylval.tipoBooleano, yytext); return T_BOOL; }
{tipoVoid}              { strcpy(yylval.tipoVoid, yytext); return T_VOID; }

{reservadaRetorno}      { return R_RETURN; }
{condicionalSi}         { return R_SI; }
{condicionalSino}       { return R_SINO; }
{iteracionMientras}     { return R_MIENTRAS; }
{iteracionPara}         { return R_PARA; }
{iteracionRepetir}      { return R_REPETIR; }
{finEstructura}         { return R_FINBLOQUE; }

{valorBoolVerdadero}    { strcpy(yylval.valorBoolVerdadero, yytext); return V_VERDADERO; }
{valorBoolFalso}        { strcpy(yylval.valorBoolFalso, yytext); return V_FALSO; }

{numero}                { yylval.numero = atoi(yytext); return V_NUMERO; }
{identificador}         { yylval.identificador = strdup(yytext); return ID; }

[+*(){}=]              { return *yytext; }

{comentarioUnilinea}    { /* comentario unilinea! */ }
{comentarioMultilinea}  { /* comentario multilinea */ }

[ \t\r\n]+              { /* espacio, salto de linea y tabulacion */ }

.                       { yyerror(yytext); printf("ultima regla lexer!\n"); }

%%

void yyerror(char* msg) {
  printf("Error de sintaxis: %s -- ", msg);
  printf("En la linea: %d\n", yylineno);
}

int main(int argc, char *argv[]) {
  ++argv,--argc;
  if (argc > 0)
    yyin = fopen(argv[0],"r");
  else
    yyin = stdin;

  yyparse();
  return 0;
}