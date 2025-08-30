#!/bin/bash

echo "Inicio compilacion flex y bison"
bison -d -Wall -Wcounterexamples sintaxis.y
flex lexico.l
gcc -Wall -o parser sintaxis.tab.c lex.yy.c
echo "Fin compliacion!"
