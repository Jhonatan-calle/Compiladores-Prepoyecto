#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
  AST_NUM, AST_BOOL, AST_ID,
  AST_UNOP, AST_BINOP,
  AST_ASSIGN, AST_SEQ,
  AST_DECL, AST_RET
} AstKind;

typedef enum {
  TypeINT, TypeBOOL, TypeVOID, NullType
} EnumType;

typedef struct Ast {
  AstKind kind;
  EnumType type;
  char* op;            // "+", "-", "==", "!", etc. (cuando aplique)
  int   ival;          // números
  int   bval;          // bool
  char* id;            // identificadores
  struct Ast* left;
  struct Ast* right;
  struct Ast* next;    // para secuencias
} Ast;


Ast* ast_num(int v);
Ast* ast_bool(int v);
Ast* ast_id(char* s);
Ast* ast_decl(char* t, Ast* a);
Ast* ast_unop(const char* op, Ast* a);
Ast* ast_binop(const char* op, Ast* a, Ast* b);
Ast* ast_assign(char* id, Ast* e);
Ast* ast_seq(Ast* a, Ast* b);
Ast* ast_ret(char* ret, Ast* a);


void printArbol(Ast* arbol);

#endif
