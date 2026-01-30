%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils/arvore.h"
#include "utils/tokens.h"

extern int linha;
extern int coluna;
extern int yychar;
extern char *yytext;
extern FILE *yyin;

no *raiz_arvore = NULL;

void erro_semantico(const char *msg, const char *detalhe);
void yyerror(const char *s);
extern int yylex();

const char* nome_tipo(int tipo) {
    switch (tipo) {
        case T_INT:    return "int";
        case T_FLOAT:  return "float";
        case T_STRING: return "string";
        case T_CHAR:   return "char";
        case T_VOID:   return "void";
        case T_ERRO:   return "erro";
        default:       return "desconhecido";
    }
}

%}

%error-verbose

%union {
    int tipo_val;       
    struct no *node;    
}

%token <node> IDENTIFICADOR NUMERO_INTEIRO NUMERO_REAL STRING CARACTER
%token IMPORT INPUT PRINT
%token TIPO_INTEIRO TIPO_CARACTER TIPO_BOOL TIPO_STRING TIPO_FLOAT TIPO_DOUBLE TIPO_VOID
%token OPERADOR_ATRIBUICAO ATRIBUICAO_CONDICIONAL
%token ACUMULADOR_SOMA ACUMULADOR_SUBTRACAO
%token PONTO_E_VIRGULA VIRGULA
%token CHAVE_E CHAVE_D PARENTESE_E PARENTESE_D
%token WHILE FOR RETURN BREAK COLCHETE_E COLCHETE_D IF ELSE
%token STRING_MAL_FORMADA COMENTARIO_SEM_FECHADOR NUM_MAL_FORMADO
%token NE EQ GE LE MENOR_QUE MAIOR_QUE
%token OPERADOR_SOMA OPERADOR_SUBTRACAO OPERADOR_MULTIPLICACAO OPERADOR_DIVISAO OPERADOR_MODULO
%token INCREMENTO DECREMENTO
%token LOGICO_AND LOGICO_OR LOGICO_NOT
%token COMENTARIO_BLOCO COMENTARIO_LINHA

%left LOGICO_OR
%left LOGICO_AND
%left EQ NE
%left GE LE MAIOR_QUE MENOR_QUE
%left OPERADOR_SOMA OPERADOR_SUBTRACAO
%left OPERADOR_MULTIPLICACAO OPERADOR_DIVISAO OPERADOR_MODULO
%right OPERADOR_ATRIBUICAO ATRIBUICAO_CONDICIONAL
%right LOGICO_NOT
%right INCREMENTO DECREMENTO

%type <node> programa lista_declaracoes declaracao declaracao_variavel declaracao_funcao estrutura_controle bloco lista_argumentos lista_parametros expressao 

%start programa

%%

expressao
    : IDENTIFICADOR
        { 
            Token* s = buscar_simbolo($1->rotulo);
            $$ = $1;
            if (!s) {
                erro_semantico("Variavel nao declarada", $1->rotulo);
                $$->tipo_dado = T_ERRO;
            } else {
                $$->tipo_dado = s->tipo_dado; 
            }
        }
    | NUMERO_INTEIRO { $$ = $1; $$->tipo_dado = T_INT; }
    | NUMERO_REAL    { $$ = $1; $$->tipo_dado = T_FLOAT; }
    | STRING         { $$ = $1; $$->tipo_dado = T_STRING; }
    | CARACTER       { $$ = $1; $$->tipo_dado = T_CHAR; }
    | expressao OPERADOR_SOMA expressao
        {
            if ($1->tipo_dado == T_STRING || $3->tipo_dado == T_STRING) {
                erro_semantico("Operacao '+' invalida para strings", "");
                // Criamos o nó de erro para manter a árvore crescendo
                no *filhos[3] = { $1, cria_no("+", NULL, 0), $3 };
                $$ = cria_no("OPERADOR_SOMA_EXPR", filhos, 3);
                $$->tipo_dado = T_ERRO;
            } else {
                no *filhos[3] = { $1, cria_no("+", NULL, 0), $3 };
                $$ = cria_no("OPERADOR_SOMA_EXPR", filhos, 3);
                $$->tipo_dado = ($1->tipo_dado == T_FLOAT || $3->tipo_dado == T_FLOAT) ? T_FLOAT : T_INT;
            }
        }
    | expressao OPERADOR_SUBTRACAO expressao
        {
        // 1. Criamos o nó da operação primeiro
        no *filhos[3] = { $1, cria_no("-", NULL, 0), $3 };
        $$ = cria_no("OPERADOR_SUBTRACAO_EXPR", filhos, 3);

        // 2. Definimos o tipo do novo nó com base nos tipos dos filhos
        // Se qualquer um for FLOAT, o resultado da subtração é FLOAT. Caso contrário, INT.
        if ($1->tipo_dado == T_FLOAT || $3->tipo_dado == T_FLOAT) {
            $$->tipo_dado = T_FLOAT;
        } else {
            $$->tipo_dado = T_INT;
        }
    }
    | PARENTESE_E expressao PARENTESE_D
        { 
            $$ = $2; // Apenas repassa o nó da expressão interna
        }
    | expressao ATRIBUICAO_CONDICIONAL expressao
        {
            if ($1->tipo_dado != $3->tipo_dado && !($1->tipo_dado == T_FLOAT && $3->tipo_dado == T_INT)) {
                char buffer[100];
                sprintf(buffer, "Conflito: %s <- %s", nome_tipo($1->tipo_dado), nome_tipo($3->tipo_dado));
                erro_semantico("Tipos incompativeis na atribuicao", buffer);
            }
            no *filhos[3] = { $1, cria_no("<-", NULL, 0), $3 };
            $$ = cria_no("ATRIBUICAO_EXPR", filhos, 3);
            $$->tipo_dado = $1->tipo_dado;
        }
    | expressao ATRIBUICAO_CONDICIONAL error 
        { 
            erro_semantico("Falta o valor ou expressao para a atribuicao", ""); 
            yyerrok; 
        }
    | expressao OPERADOR_ATRIBUICAO error 
        { 
            erro_semantico("Falta o valor ou expressao para a atribuicao", ""); 
            yyerrok; 
        }
      | expressao OPERADOR_ATRIBUICAO expressao
        {
            if ($1->tipo_dado != $3->tipo_dado && !($1->tipo_dado == T_FLOAT && $3->tipo_dado == T_INT)) {
                erro_semantico("Tipos incompativeis na atribuicao", "");
            }
            no *filhos[3] = { $1, cria_no("=", NULL, 0), $3 };
            $$ = cria_no("ATRIBUICAO_SIMPLES", filhos, 3);
            $$->tipo_dado = $1->tipo_dado;
        }
        
        | expressao MAIOR_QUE expressao
        {
            no *filhos[3] = { $1, cria_no(">", NULL, 0), $3 };
            $$ = cria_no("COMP_MAIOR", filhos, 3);
            $$->tipo_dado = T_BOOL; // Ou T_INT se não tiver bool
        }
    | expressao MENOR_QUE expressao
        {
            no *filhos[3] = { $1, cria_no("<", NULL, 0), $3 };
            $$ = cria_no("COMP_MENOR", filhos, 3);
            $$->tipo_dado = T_BOOL;
        }
    | IDENTIFICADOR PARENTESE_E lista_argumentos PARENTESE_D
        {
        Token* s = buscar_simbolo($1->rotulo);
        no *filhos[2] = { $1, $3 };
        $$ = cria_no("CHAMADA_FUNCAO", filhos, 2);
        $$->tipo_dado = s ? s->tipo_dado : T_VOID; // Salva o tipo no nó criado
    }
    ;

programa
    : lista_declaracoes { raiz_arvore = $1; }
    ;

lista_declaracoes
    : lista_declaracoes declaracao
        {
          no *filhos[2] = { $1, $2 };
          $$ = cria_no("lista_declaracoes", filhos, 2);
        }
    | declaracao
        {
          // Simplificando: o primeiro elemento da lista é a própria declaração
          $$ = $1; 
        }
    ;

lista_argumentos
    : expressao 
        { 
          no *f[1] = { $1 }; // Removido $<node>
          $$ = cria_no("argumento", f, 1); 
        }
    | lista_argumentos VIRGULA expressao 
        { 
          no *f[2] = { $1, $3 }; // Removido $<node>
          $$ = cria_no("lista_argumentos", f, 2); 
        }
    | /* vazio */ { $$ = cria_no("sem_argumentos", NULL, 0); }
    ;

declaracao_variavel
    : TIPO_INTEIRO IDENTIFICADOR PONTO_E_VIRGULA
        {
          if (buscar_simbolo($2->rotulo)) erro_semantico("Redeclaracao", $2->rotulo);
          else inserir_simbolo($2->rotulo, "VAR", T_INT, linha);
          no *f[1] = { $2 };
          $$ = cria_no("decl_int", f, 1);
          $$->tipo_dado = T_INT;
        }
    | TIPO_FLOAT IDENTIFICADOR PONTO_E_VIRGULA
        {
          if (buscar_simbolo($2->rotulo)) erro_semantico("Redeclaracao", $2->rotulo);
          else inserir_simbolo($2->rotulo, "VAR", T_FLOAT, linha);
          no *f[1] = { $2 };
          $$ = cria_no("decl_float", f, 1);
          $$->tipo_dado = T_FLOAT;
        }
    | TIPO_STRING IDENTIFICADOR PONTO_E_VIRGULA  /* <--- ADICIONE ESTA LINHA */
        {
          if (buscar_simbolo($2->rotulo)) erro_semantico("Redeclaracao", $2->rotulo);
          else inserir_simbolo($2->rotulo, "VAR", T_STRING, linha);
          no *f[1] = { $2 };
          $$ = cria_no("decl_string", f, 1);
          $$->tipo_dado = T_STRING;
        }
    ;

declaracao_funcao
    : TIPO_INTEIRO IDENTIFICADOR PARENTESE_E lista_parametros PARENTESE_D bloco
        {
            inserir_simbolo($2->rotulo, "FUNC", T_INT, linha);
          no *filhos[3] = { $2, $4, $6 };
          $$ = cria_no("declaracao_funcao", filhos, 3);
        }
    ;

lista_parametros
    : TIPO_INTEIRO IDENTIFICADOR 
        { 
          inserir_simbolo(yytext, "PARAM", T_INT, linha);
          no *f[1] = { $2 };
          $$ = cria_no("parametro", f, 1); 
        }
    | lista_parametros VIRGULA TIPO_INTEIRO IDENTIFICADOR 
        { 
          inserir_simbolo(yytext, "PARAM", T_INT, linha);
          no *f[2] = { $1, $4 };
          $$ = cria_no("lista_parametros", f, 2); 
        }
    | /* vazio */ { $$ = cria_no("sem_parametros", NULL, 0); }
    ;

declaracao
    : declaracao_variavel { $$ = $1; }
    | declaracao_funcao { $$ = $1; }
    | estrutura_controle { $$ = $1; }
    | expressao PONTO_E_VIRGULA { $$ = $1; }
    | RETURN expressao PONTO_E_VIRGULA 
        { 
            no *f[1] = { $2 }; 
            $$ = cria_no("RETURN", f, 1); 
        }
    | error PONTO_E_VIRGULA 
        { 
            yyerrok; // Diz ao Bison que o erro foi tratado e ele pode continuar
            yyclearin;
            $$ = cria_no("ERRO_SINTATICO", NULL, 0); 
        }
    ;

estrutura_controle
    : IF PARENTESE_E expressao PARENTESE_D bloco
        {
          no *filhos[2] = { $3, $5 };
          $$ = cria_no("IF", filhos, 2);
        }
    /* Sincroniza logo no início do bloco */
    | IF error CHAVE_E 
        { 
            printf("Erro sintatico: IF mal formado na linha %d\n", linha);
            yyerrok; 
        }
      lista_declaracoes CHAVE_D
        { 
            $$ = cria_no("IF_ERRO", NULL, 0); 
        }
    ;

bloco
    : CHAVE_E lista_declaracoes CHAVE_D 
        { 
          no *f[1] = { $2 };
          $$ = cria_no("bloco", f, 1); 
        }
    | CHAVE_E error CHAVE_D 
        { 
            yyerrok; 
            $$ = cria_no("bloco_com_erro", NULL, 0); 
        }
    | CHAVE_E CHAVE_D 
        { $$ = cria_no("bloco_vazio", NULL, 0); }
    ;

%%

void erro_semantico(const char *msg, const char *detalhe) {
    if (detalhe != NULL && strlen(detalhe) > 0) {
        fprintf(stderr, "Erro semantico: %s '%s' na linha %d\n", msg, detalhe, linha);
    } else {
        fprintf(stderr, "Erro semantico: %s na linha %d\n", msg, linha);
    }
}

void yyerror(const char *s) {
    //fprintf(stderr, "Erro sintatico: %s na linha %d\n", s, linha);
}

int main(int argc, char **argv) {
    int opcao;
    char arquivo[256];

    do {
        printf("\nMenu Miniclang:\n");
        printf("1. Inserir arquivo de teste\n");
        printf("2. Mostrar arvore sintatica\n");
        printf("3. Mostrar tabela de simbolos\n");
        printf("4. Sair\n");
        printf("Escolha uma opcao: ");
        scanf("%d", &opcao);

        switch (opcao) {
            case 1:
                printf("Digite o caminho do arquivo: ");
                scanf("%s", arquivo);
                yyin = fopen(arquivo, "r");
                if (!yyin) {
                    perror("Erro ao abrir arquivo");
                    break;
                }
                printf("Iniciando analise...\n");
                raiz_arvore = NULL;
                yyparse();
                printf("Analise finalizada.\n");
                fclose(yyin);
                linha = 1; coluna = 1;
                break;

            case 2:
                if (raiz_arvore) {
                    printf("\nArvore Sintatica:\n");
                    imprime_arvore(raiz_arvore);
                } else {
                    printf("Execute a analise primeiro (Opcao 1).\n");
                }
                break;
            case 3:
                imprimir_simbolos();
                break;
            case 4:
                printf("Saindo...\n");
                break;
            default:
                printf("Opcao invalida.\n");
        }
    } while (opcao != 4);

    return 0;
}
