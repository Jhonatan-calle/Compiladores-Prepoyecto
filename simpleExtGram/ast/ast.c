#include "ast.h"

Ast *ast_num(int v)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_NUM;
  res->type = NullType;
  res->op = NULL;
  res->ival = v;
  res->bval = -1;
  res->id = NULL;
  res->left = NULL;
  res->right = NULL;
  res->next = NULL;
  return res;
}

Ast *ast_bool(int v)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_BOOL;
  res->type = NullType;
  res->op = NULL;
  res->ival = -1;
  res->bval = v;
  res->id = NULL;
  res->left = NULL;
  res->right = NULL;
  res->next = NULL;
  return res;
}

Ast *ast_id(char *s)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_ID;
  res->type = NullType;
  res->op = NULL;
  res->ival = -1;
  res->bval = -1;
  res->id = strdup(s);
  res->left = NULL;
  res->right = NULL;
  res->next = NULL;
  return res;
}

EnumType stringType_toEnumType(char* t)
{
  if (strcmp(t, "Int") == 0 || strcmp(t, "Integer") == 0 || strcmp(t, "Entero") == 0)
    return TypeINT;
  if (strcmp(t, "Bool") == 0 || strcmp(t, "Boolean") == 0 || strcmp(t, "ValorVerdad") == 0)
    return TypeBOOL;
  if (strcmp(t, "Void") == 0 || strcmp(t, "Vacio") == 0)
    return TypeVOID;

  return NullType;
}

Ast* ast_decl(char* t, Ast* a)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_DECL;
  res->type = stringType_toEnumType(t);
  res->op = NULL;
  res->ival = -1;
  res->bval = -1;
  res->id = NULL;
  res->left = NULL;
  res->right = a;
  res->next = NULL;
  return res;
}

Ast *ast_unop(const char *op, Ast *a)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_UNOP;
  res->type = NullType;
  res->op = strdup(op);
  res->ival = -1;
  res->bval = -1;
  res->id = NULL;
  res->left = a;
  res->right = NULL;
  res->next = NULL;
  return res;
}

Ast *ast_binop(const char *op, Ast *a, Ast *b)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_BINOP;
  res->type = NullType;
  res->op = strdup(op);
  res->ival = -1;
  res->bval = -1;
  res->id = NULL;
  res->left = a;
  res->right = b;
  res->next = NULL;
  return res;
}

Ast *ast_assign(char *id, Ast *e)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_ASSIGN;
  res->type = NullType;
  res->op = strdup("=");
  res->ival = -1;
  res->bval = -1;
  res->id = strdup(id);
  res->left = e;
  res->right = NULL;
  res->next = NULL;
  return res;
}

Ast *ast_seq(Ast *a, Ast *b)
{
  if (!a)
    return b;
  Ast *res = a;
  while (res->next)
    res = res->next;
  res->next = b;
  return a;
}

Ast* ast_ret(char* ret, Ast* a)
{
  Ast *res = (Ast *)malloc(sizeof(Ast));
  res->kind = AST_RET;
  res->type = NullType;
  res->op = NULL;
  res->ival = -1;
  res->bval = -1;
  res->id = NULL;
  res->left = NULL;
  res->right = a;
  res->next = NULL;
  return res;
}

char *ast_kind_toString(AstKind ak)
{
  switch (ak)
  {
  case AST_NUM:
    return "AST_NUM";
  case AST_BOOL:
    return "AST_BOOL";
  case AST_ID:
    return "AST_ID";
  case AST_UNOP:
    return "AST_UNOP";
  case AST_BINOP:
    return "AST_BINOP";
  case AST_ASSIGN:
    return "AST_ASSIGN";
  case AST_SEQ:
    return "AST_SEQ";
  case AST_DECL:
    return "AST_DECL";
  default:
    return "Invalid!!";
  }
}

void printArbol(Ast *arbol)
{
  if (arbol == NULL)
    return;

  printf("Tipo=%s, ", ast_kind_toString(arbol->kind));

  if (arbol->id)
    printf("ID=%s, ", arbol->id);

  if (arbol->kind == AST_NUM)
    printf("Valor=%d, ", arbol->ival);
  else if (arbol->kind == AST_BOOL)
    printf("Valor=%d, ", arbol->bval);

  if (arbol->op)
    printf("Op=%s, ", arbol->op);

  printf("\n");

  if (arbol->left)
  {
    printf("  left de %s:\n", arbol->id ? arbol->id : ast_kind_toString(arbol->kind));
    printArbol(arbol->left);
  }

  if (arbol->right)
  {
    printf("  right de %s:\n", arbol->id ? arbol->id : ast_kind_toString(arbol->kind));
    printArbol(arbol->right);
  }

  if (arbol->next)
  {
    printf("  next de %s:\n", arbol->id ? arbol->id : ast_kind_toString(arbol->kind));
    printArbol(arbol->next);
  }
}
