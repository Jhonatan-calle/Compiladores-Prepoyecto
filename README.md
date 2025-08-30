Para la materia Compiladores, del segundo cuatrimestre del 2025.

### 1
El Preproyecto consiste en extender una gramatica con expresion de declaracion de variables, asignaciones y uso de variables.
Las variables pueden ser de tipo entero o logico.

Se debe permitir una o mas declaraciones de variables enteras o booleanas estilo C.
Cada declaracion consiste de la palabra reservada que indica el tipo, el nombre de una variable y fianliza con un valor de ;.

Los nombres de variables deben comenzar con una letra y pueden seguir con una o mas letras o numeros.

El lenguaje debe permitir una secuencia de sentencias, asignaciones y retornos de valores (sentencia **return <expr>;** o **return;**)
en una unica funcion main. La funcion main puede retornar un valor de tipo int, bool o no retornar un valor (void).

### 2
Dar expresiones regulares que definan la estructura de las palabras reservadas, variables, valores constantes, operadores y delimitadores del lenguaje del punto 1.

### 3
Implementar un analizar lexico usando _lex_ para el lenguaje extendido.

### 4
Implementar un parser usando _lex_ y _bison_ para la gramatica extendida.

### 5
Utilizando el parser del punto 4, generar un **AST** (Arbol sintactico abstracto) de los programas del lenguaje.

### 6
Generar sobre el AST un interprete (evaluador) de expresiones.
Nota: verificar que las variables usadas esten declaradas previamente. 
Generar una tabla de simbolos para mantener informacion sobre las variables declaradas y referenciarlas desde el AST

### 7
Generar sobre el AST un generador de un pseudo-assembly (no hace falta que sea un assembly real, alcanza con que sea similar a un assembly)..


