#!/bin/bash

echo "Inicio compilacion flex y bison"
gcc -Wall -c src/simbolos.c -o build/simbolos.o
gcc -Wall -c src/ast.c -o build/ast.o
gcc -Wall -c src/utils.c -o build/utils.o
bison -d -Wall -Wcounterexamples sintaxis.y
flex lexico.l
gcc -Wall sintaxis.tab.c lex.yy.c build/simbolos.o build/ast.o build/utils.o -o parser
echo "Fin compliacion!"
