%code requires {
    typedef enum {
        TR_PROGRAMA = 0,
        TR_LISTA_SENTENCIAS = 1,
        TR_PERFIL = 2,
        TR_DECLARACION = 3,
        TR_ASIGNACION = 4,
        TR_RETURN = 5,
        TR_EXPRESION = 6,
        TR_VALOR = 7,
        TR_IDENTIFICADOR = 8,
        TR_SUMA = 9,
        TR_MULTIPLICACION = 10,
        TR_AND = 11,
        TR_OR = 12

    }TipoNodo;

    typedef enum{
        T_INT = 0, 
        T_BOOL = 1,
        T_VOID = 2,
    } Tipos;

    //estructuras para tabla de simbolos 

    typedef struct {
        char *nombre;   // identificador
        Tipos tVar;
        int valor;    // valor (puede ser string, o podés cambiarlo a int/double)
    } Simbolo;

    typedef struct {
        Simbolo **tabla;
        size_t capacidad;
        size_t usados;
    } TablaSimbolos;

    //estructuras para nodos

    typedef struct AST{
        TipoNodo type; 
        Simbolo *info; 
        int child_count;
        struct AST **childs;
    } AST;

    
    AST *append_child(AST *list, AST *child);
    void free_ast(AST *node);
    TablaSimbolos *crear_tabla(size_t capacidad_inicial);
    void tar_simbolo(Simbolo *e);
    Simbolo* buscar_simbolo(char *nombre) ;
    void print_indent(int level);
    const char* tipoNodoToStr(TipoNodo type);
    void print_ast(AST *node, int level);
    const char* tipoDatoToStr(Tipos type);
    char *new_temp();
    char *gen_code(AST *node);
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
    TablaSimbolos *t;
    AST *root;
    int temp_counter = 0;
    


    //rutinas para tabla de simbolos
    TablaSimbolos *crear_tabla(size_t capacidad_inicial) {
        TablaSimbolos *t = malloc(sizeof(TablaSimbolos));
        t->capacidad = capacidad_inicial;
        t->usados = 0;
        t->tabla = malloc(capacidad_inicial * sizeof(Simbolo *));
        return t;
    }

    void insertar_simbolo(Simbolo *e) {
        // buscar si ya existe
        // for (size_t i = 0; i < t->usados; i++) {
        //     if (strcmp(t->tabla[i].nombre, nombre) == 0) {
        //         free(t->tabla[i].valor);
        //         t->tabla[i].valor = strdup(valor);
        //         return;
        //     }
        // }

        // si no existe, agregar nuevo
        if (t->usados >= t->capacidad) {
            t->capacidad *= 2;
            t->tabla = realloc(t->tabla, t->capacidad * sizeof(Simbolo *));
        }
        t->tabla[t->usados] = e;
        t->usados++;
    }

    Simbolo* buscar_simbolo(char *nombre) {
        for (size_t i = 0; i < t->usados; i++) {
            if (strcmp(t->tabla[i]->nombre, nombre) == 0) {
                return t->tabla[i];
            }
        }
        return NULL; // no encontrado
    }

    void liberar_tabla() {
        for (size_t i = 0; i < t->usados; i++) {
            free(t->tabla[i]);
        }
        free(t->tabla);
        free(t);
    }


        

    char *new_temp() {
        char buffer[16];
        snprintf(buffer, sizeof(buffer), "t%d", temp_counter++);
        return strdup(buffer);
    }

    char *gen_code(AST *node) {
        if (!node) return NULL;

        switch (node->type) {
            case TR_VALOR: {
                char *t = new_temp();
                printf("LOAD %s, %d\n", t, node->info->valor);
                return t;
            }

            case TR_IDENTIFICADOR: {
                char *t = new_temp();
                printf("LOAD %s, %s\n", t, node->info->nombre);
                return t;
            }

            case TR_ASIGNACION: {
                // child[0] = identificador
                // child[1] = expresión
                char *rhs = gen_code(node->childs[1]);
                printf("STORE %s, %s\n", node->childs[0]->info->nombre, rhs);
                return rhs;
            }

            case TR_SUMA: {
                char *lhs = gen_code(node->childs[0]);
                char *rhs = gen_code(node->childs[1]);
                char *t = new_temp();
                printf("ADD %s, %s, %s\n", t, lhs, rhs);
                return t;
            }

            case TR_MULTIPLICACION: {
                char *lhs = gen_code(node->childs[0]);
                char *rhs = gen_code(node->childs[1]);
                char *t = new_temp();
                printf("MUL %s, %s, %s\n", t, lhs, rhs);
                return t;
            }

            case TR_AND: {
                char *lhs = gen_code(node->childs[0]);
                char *rhs = gen_code(node->childs[1]);
                char *t = new_temp();
                printf("AND %s, %s, %s\n", t, lhs, rhs);
                return t;
            }

            case TR_OR: {
                char *lhs = gen_code(node->childs[0]);
                char *rhs = gen_code(node->childs[1]);
                char *t = new_temp();
                printf("OR %s, %s, %s\n", t, lhs, rhs);
                return t;
            }

            case TR_LISTA_SENTENCIAS: {
                for (int i = 0; i < node->child_count; i++) {
                    gen_code(node->childs[i]);
                }
                return NULL;
            }

            case TR_PROGRAMA: {
                printf("; inicio programa\n");
                gen_code(node->childs[0]);
                printf("; fin programa\n");
                return NULL;
            }

            default:
                return NULL;
        }
    }




    // rutinas para arbol sintactico
    AST *new_node(TipoNodo type, int child_count, ...) {
        AST *node = malloc(sizeof(AST));
        if (!node) {
            fprintf(stderr, "<<<<<Error: no se pudo reservar memoria para AST>>>>>\n");
            exit(EXIT_FAILURE);
        }

        node->type = type;
        node->info = NULL;
        node->child_count = child_count;
        node->childs = NULL;

        va_list args;
        va_start(args, child_count);

        switch (type) {
            case TR_PROGRAMA: {
                node->info = malloc(sizeof(Simbolo));
                node->info->nombre = strdup("programa");
                node->info->tVar = va_arg(args, int);   // tipo de retorno
                node->child_count = 1;
                node->childs = malloc(sizeof(AST *));
                node->childs[0] = va_arg(args, AST *);
            } break;

            case TR_DECLARACION: {
                int tipoIdentificador = va_arg(args, int);
                char *nombre = va_arg(args, char*);
                Simbolo *id = buscar_simbolo(nombre);
                if(id){
                    fprintf(stderr, "<<<<<Error: identificador '%s' ya declarado>>>>>\n", nombre);
                    exit(EXIT_FAILURE);
                }
                node->info = malloc(sizeof(Simbolo));
                node->info->tVar = tipoIdentificador;     // tipo (enum Tipos)
                node->info->nombre = nombre; // identificador
                insertar_simbolo(node->info);
                node->child_count = 0;
            } break;

            case TR_ASIGNACION: {
                char *nombre = va_arg(args, char*);
                Simbolo *id = buscar_simbolo(nombre);
                if (!id) {
                    fprintf(stderr, "<<<<<Error: identificador '%s' no declarado>>>>>\n", nombre);
                    exit(EXIT_FAILURE);
                }

                AST *exp = va_arg(args, AST *);

                if (exp->info->tVar != id->tVar) {
                    fprintf(stderr,
                        "<<<<<Error semántico: el identificador '%s' es de tipo '%s' "
                        "pero se intenta asignar un valor de tipo '%s'>>>>>\n",
                        id->nombre,
                        tipoDatoToStr(id->tVar),
                        tipoDatoToStr(exp->info->tVar)
                    );
                    exit(EXIT_FAILURE);
                }
                id->valor = exp->info->valor;
                node->child_count = 2;
                node->childs = malloc(sizeof(AST *) * 2);

                AST *aux = malloc(sizeof(AST));
                aux->type = TR_IDENTIFICADOR;
                aux->info = id;
                aux->child_count = 0;
                aux->childs = NULL;

                node->childs[0] = aux;
                node->childs[1] = exp;
            } break;

            case TR_VALOR: {
                node->info = malloc(sizeof(Simbolo));
                node->info->tVar = va_arg(args, int);
                node->info->nombre = strdup("TR_VALOR");
                node->info->valor = va_arg(args, int);
                node->child_count = 0;
            } break;


            case TR_IDENTIFICADOR: {
                char *nombre = va_arg(args, char*);
                Simbolo *id = buscar_simbolo(nombre);
                if (!id) {
                    fprintf(stderr, "<<<<<Error: identificador '%s' no declarado>>>>>\n", nombre);
                    exit(EXIT_FAILURE);
                }
                node->info = id;
                node->child_count = 0;
                node->childs = NULL;
            } break;

            case TR_SUMA:
            case TR_MULTIPLICACION:
             {
                AST *op1 = va_arg(args, AST *);
                AST *op2 = va_arg(args, AST *);
                if(op1->info->tVar != T_INT || op2->info->tVar != T_INT){
                    fprintf(stderr,
                        "operacion con tipos invalidos\n"
                    );
                    exit(EXIT_FAILURE);
                }
                node->info = malloc(sizeof(Simbolo));
                node->info->tVar = T_INT;
                node->info->nombre = strdup(tipoNodoToStr(type));
                switch(type){
                    case TR_SUMA: {
                        node->info->valor = op1->info->valor + op2->info->valor;
                        }break;
                    case TR_MULTIPLICACION: {
                        node->info->valor = op1->info->valor * op2->info->valor;
                    }break;
                    default: break;

                }
                
                node->child_count = 2;
                node->childs = malloc(sizeof(AST *) * 2);

                node->childs[0] = op1;
                node->childs[1] = op2;

            }break;

            case TR_AND:
            case TR_OR:
             {
                AST *op1 = va_arg(args, AST *);
                AST *op2 = va_arg(args, AST *);
                if (op1->info->tVar != T_BOOL || op2->info->tVar != T_BOOL) {
                    fprintf(stderr, "operacion con tipos invalidos\n");
                    exit(EXIT_FAILURE);
                }
                node->info = malloc(sizeof(Simbolo));
                node->info->tVar = T_BOOL;
                node->info->nombre = strdup(tipoNodoToStr(type));
                switch(type){
                    case TR_AND: {
                        node->info->valor = (op1->info->valor != 0) && (op2->info->valor != 0);
                    }break;
                    case TR_OR: {
                        node->info->valor = (op1->info->valor != 0) || (op2->info->valor != 0);
                    }break;
                    default: break;

                }
                
                node->child_count = 0;
            }

            default :{
                node->childs = malloc(sizeof(AST *) * child_count);
                for (int i = 0; i < child_count; i++) {
                    node->childs[i] = va_arg(args, AST *);
                }
            } break;

        }

        va_end(args);
        return node;
    }

    AST *append_child(AST *list, AST *child) {
        if (!list) {
            return new_node(TR_LISTA_SENTENCIAS,1, child);
        }
        list->childs = realloc(list->childs, sizeof(AST*)  * (list->child_count + 1));
        if (!list->childs) {
            fprintf(stderr, "Error realloc en append_child\n");
            exit(EXIT_FAILURE);
        }
        list->childs[list->child_count] = child;
        list->child_count += 1;

        return list;
    }

    void free_ast(AST *node) {
        if (!node) return;

        for (int i = 0; i < node->child_count; i++) {
            free_ast(node->childs[i]);
        }
        free(node->childs);
        free(node);
    }

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
}	


void print_ast(AST *node, int level) {
    if (!node) return;

    print_indent(level);
    printf("%s", tipoNodoToStr(node->type));

    switch (node->type) {
        case TR_PROGRAMA: {
            printf(" [tipo retorno: %s]", tipoDatoToStr(node->info->tVar));
        } break;

        case TR_DECLARACION: {
            printf(" [tipo: %s, id: %s]", 
                   tipoDatoToStr(node->info->tVar),
                   node->info->nombre);
        } break;

        case TR_ASIGNACION: {
            if (node->childs && node->childs[0] && node->childs[0]->info) {
                printf(" [asigna a id: %s]", node->childs[0]->info->nombre);
            }
        } break;

        case TR_VALOR: {
            printf(" [valor: %d, tipo: %s]", 
                   node->info->valor,
                   tipoDatoToStr(node->info->tVar));
        } break;

        case TR_IDENTIFICADOR: {
            if (node->info) {
                printf(" [id: %s, tipo: %s]", 
                       node->info->nombre,
                       tipoDatoToStr(node->info->tVar));
            }
        } break;

        case TR_SUMA: {
            printf(" [+], valor: %d]",
            node->info->valor);
        } break;

        case TR_MULTIPLICACION: {
            printf(" [*], valor: %d]",
            node->info->valor);
        } break;

        case TR_LISTA_SENTENCIAS: {
            printf(" [lista de sentencias]");
        } break;

        case TR_RETURN: {
            printf(" [return]");
        } break;

        default:
            printf(" [?]");
            break;
    }

    printf("\n");

    // Recursión en hijos
    for (int i = 0; i < node->child_count; i++) {
        print_ast(node->childs[i], level + 1);
    }
}




void print_indent(int level) {
    for (int i = 0; i < level; i++) {
        printf("  "); // 2 espacios por nivel
    }
}

const char* tipoNodoToStr(TipoNodo type) {
    switch (type) {
        case TR_PROGRAMA:     return "PROGRAMA";
        case TR_PERFIL:       return "PERFIL";
        case TR_DECLARACION:  return "DECLARACION";
        case TR_ASIGNACION:   return "ASIGNACION";
        case TR_RETURN:       return "RETURN";
        case TR_VALOR:           return "VALOR";
        case TR_IDENTIFICADOR:       return "IDENTIFICADOR";
        case TR_SUMA:       return "SUMA";
        case TR_MULTIPLICACION:       return "MULTIPLICACION";
        case TR_LISTA_SENTENCIAS:       return "LISTA_SENTENCIAS";
        // agrega los que falten...
        default:           return "DESCONOCIDO";
    }
}

const char* tipoDatoToStr(Tipos type) {
    switch (type) {
        case T_INT:   return "INT";
        case T_BOOL:  return "BOOL";
        case T_VOID:  return "VOID";
        default:      return "DESCONOCIDO";
    }
}