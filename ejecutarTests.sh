#!/bin/bash

echo "___________________________"
echo "Inicio ejecucion parser!"

echo "#################################"
echo "Caso 1: correcto.txt"
./parser test/correcto.txt
echo "#################################"

echo "#################################"
echo "Caso 2: errorIdUnknown.txt"
./parser test/errorIdUnknown.txt
echo "#################################"

echo "#################################"
echo "Caso 1: errorRedeclarado.txt"
./parser test/errorRedeclarado.txt
echo "#################################"

echo "Fin ejecucion"
echo "___________________________"

