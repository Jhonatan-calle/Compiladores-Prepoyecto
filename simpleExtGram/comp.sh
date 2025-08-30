#!/bin/bash

echo "Inicio compilacion flex y bison"
bison -d -Wall -Wcounterexamples gram.y
flex exprReg.l
gcc -Wall -o parser gram.tab.c lex.yy.c ast/ast.c -lfl
echo "Fin compliacion!"

