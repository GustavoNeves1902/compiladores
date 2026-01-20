%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils/arvore.h"
#include "utils/tokens.h"

extern int linha;
extern int coluna;
extern int yychar;       // Token atual
extern char *yytext;     // Texto do token atual

no *raiz_arvore = NULL;

void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;

%}

%union {
    int atributo;
    struct no *node;
}

%token IMPORT IDENTIFICADOR INPUT PRINT
%token NUMERO_INTEIRO NUMERO_REAL
%token TIPO_INTEIRO TIPO_CARACTER TIPO_BOOL TIPO_STRING TIPO_FLOAT TIPO_DOUBLE TIPO_VOID
%token OPERADOR_ATRIBUICAO ATRIBUICAO_CONDICIONAL
%token ACUMULADOR_SOMA ACUMULADOR_SUBTRACAO
%token PONTO_E_VIRGULA
%token VIRGULA
%token CARACTER
%token STRING
%token CHAVE_E CHAVE_D
%token PARENTESE_E PARENTESE_D
%token WHILE FOR
%token RETURN
%token BREAK
%token COLCHETE_E COLCHETE_D
%token IF ELSE
%token STRING_MAL_FORMADA COMENTARIO_SEM_FECHADOR NUM_MAL_FORMADO
%token NE EQ GE LE MENOR_QUE MAIOR_QUE
%token OPERADOR_SOMA OPERADOR_SUBTRACAO OPERADOR_MULTIPLICACAO OPERADOR_DIVISAO OPERADOR_MODULO
%token INCREMENTO DECREMENTO
%token LOGICO_AND LOGICO_OR LOGICO_NOT
%left GE LE EQ NE MAIOR_QUE MENOR_QUE
%right LOGICO_NOT
%left LOGICO_AND
%left LOGICO_OR
%token COMENTARIO_BLOCO COMENTARIO_LINHA

%type <node> programa lista_declaracoes declaracao declaracao_variavel declaracao_funcao estrutura_controle bloco expressao lista_argumentos lista_parametros 

%start programa

%%

expressao
    : IDENTIFICADOR
        { $$ = cria_no("IDENTIFICADOR", NULL, 0); }
    | NUMERO_INTEIRO
        { $$ = cria_no("NUMERO_INTEIRO", NULL, 0); }
    | NUMERO_REAL
        { $$ = cria_no("NUMERO_REAL", NULL, 0); }
    | STRING
        { $$ = cria_no("STRING", NULL, 0); }
    | CARACTER
        { $$ = cria_no("CARACTER", NULL, 0); }
    | expressao OPERADOR_SOMA expressao
        {
          no *filhos[3] = { $1, cria_no("OPERADOR_SOMA", NULL, 0), $3 };
          $$ = cria_no("OPERADOR_SOMA_EXPR", filhos, 3);
        }
    | expressao OPERADOR_SUBTRACAO expressao
        {
          no *filhos[3] = { $1, cria_no("OPERADOR_SUBTRACAO", NULL, 0), $3 };
          $$ = cria_no("OPERADOR_SUBTRACAO_EXPR", filhos, 3);
        }
    | expressao OPERADOR_MULTIPLICACAO expressao
        {
          no *filhos[3] = { $1, cria_no("OPERADOR_MULTIPLICACAO", NULL, 0), $3 };
          $$ = cria_no("OPERADOR_MULTIPLICACAO_EXPR", filhos, 3);
        }
    | expressao OPERADOR_DIVISAO expressao
        {
          no *filhos[3] = { $1, cria_no("OPERADOR_DIVISAO", NULL, 0), $3 };
          $$ = cria_no("OPERADOR_DIVISAO_EXPR", filhos, 3);
        }
    | expressao OPERADOR_MODULO expressao
        {
          no *filhos[3] = { $1, cria_no("OPERADOR_MODULO", NULL, 0), $3 };
          $$ = cria_no("OPERADOR_MODULO_EXPR", filhos, 3);
        }
    | expressao ACUMULADOR_SOMA expressao
        {
          no *filhos[3] = { $1, cria_no("ACUMULADOR_SOMA", NULL, 0), $3 };
          $$ = cria_no("ACUMULADOR_SOMA_EXPR", filhos, 3);
        }
    | expressao ACUMULADOR_SUBTRACAO expressao
        {
          no *filhos[3] = { $1, cria_no("ACUMULADOR_SUBTRACAO", NULL, 0), $3 };
          $$ = cria_no("ACUMULADOR_SUBTRACAO_EXPR", filhos, 3);
        }
    | expressao INCREMENTO
        {
          no *filhos[2] = { $1, cria_no("INCREMENTO", NULL, 0) };
          $$ = cria_no("INCREMENTO_EXPR", filhos, 2);
        }
    | expressao DECREMENTO
        {
          no *filhos[2] = { $1, cria_no("DECREMENTO", NULL, 0) };
          $$ = cria_no("DECREMENTO_EXPR", filhos, 2);
        }
    | expressao GE expressao
        {
          no *filhos[3] = { $1, cria_no("GE", NULL, 0), $3 };
          $$ = cria_no("GE_EXPR", filhos, 3);
        }
    | expressao LE expressao
        {
          no *filhos[3] = { $1, cria_no("LE", NULL, 0), $3 };
          $$ = cria_no("LE_EXPR", filhos, 3);
        }
    | expressao EQ expressao
        {
          no *filhos[3] = { $1, cria_no("EQ", NULL, 0), $3 };
          $$ = cria_no("EQ_EXPR", filhos, 3);
        }
    | expressao NE expressao
        {
          no *filhos[3] = { $1, cria_no("NE", NULL, 0), $3 };
          $$ = cria_no("NE_EXPR", filhos, 3);
        }
    | expressao MAIOR_QUE expressao
        {
          no *filhos[3] = { $1, cria_no("MAIOR_QUE", NULL, 0), $3 };
          $$ = cria_no("MAIOR_QUE_EXPR", filhos, 3);
        }
    | expressao MENOR_QUE expressao
        {
          no *filhos[3] = { $1, cria_no("MENOR_QUE", NULL, 0), $3 };
          $$ = cria_no("MENOR_QUE_EXPR", filhos, 3);
        }
    | expressao LOGICO_AND expressao
        {
          no *filhos[3] = { $1, cria_no("LOGICO_AND", NULL, 0), $3 };
          $$ = cria_no("LOGICO_AND_EXPR", filhos, 3);
        }
    | expressao LOGICO_OR expressao
        {
          no *filhos[3] = { $1, cria_no("LOGICO_OR", NULL, 0), $3 };
          $$ = cria_no("LOGICO_OR_EXPR", filhos, 3);
        }
    | LOGICO_NOT expressao
        {
          no *filhos[2] = { cria_no("LOGICO_NOT", NULL, 0), $2 };
          $$ = cria_no("LOGICO_NOT_EXPR", filhos, 2);
        }
    | '(' expressao ')'
        { $$ = $2; }
    | expressao ATRIBUICAO_CONDICIONAL expressao
        {
          no *filhos[3] = { $1, cria_no("ATRIBUICAO_CONDICIONAL", NULL, 0), $3 };
          $$ = cria_no("ATRIBUICAO_CONDICIONAL_EXPR", filhos, 3);
        }
    | IDENTIFICADOR PARENTESE_E PARENTESE_D
        {
          no *filhos[2] = { cria_no("IDENTIFICADOR", NULL, 0), cria_no("PARAMETROS_VAZIOS", NULL, 0) };
          $$ = cria_no("CHAMADA_FUNC_SIMPLES", filhos, 2);
        }
    | IDENTIFICADOR PARENTESE_E lista_argumentos PARENTESE_D
        {
          no *filhos[2] = { cria_no("IDENTIFICADOR", NULL, 0), $3 };
          $$ = cria_no("CHAMADA_FUNC_ARGS", filhos, 2);
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
          no *filhos[1] = { $1 };
          $$ = cria_no("declaracao", filhos, 1);
        }
    ;

lista_argumentos
    : expressao
        {
          no *filhos[1] = { $1 };
          $$ = cria_no("argumento", filhos, 1);
        }
    | lista_argumentos VIRGULA expressao
        {
          no *filhos[2] = { $1, $3 };
          $$ = cria_no("argumento_lista", filhos, 2);
        }
    ;

declaracao
    : declaracao_variavel { $$ = $1; }
    | declaracao_funcao { $$ = $1; }
    | estrutura_controle { $$ = $1; }
    | IMPORT IDENTIFICADOR PONTO_E_VIRGULA
        {
          no *filhos[2] = { cria_no("IMPORT", NULL, 0), cria_no("IDENTIFICADOR", NULL, 0) };
          $$ = cria_no("declaracao_import", filhos, 2);
        }
    | RETURN expressao PONTO_E_VIRGULA
        {
          no *filhos[1] = { $2 };
          $$ = cria_no("RETURN", filhos, 1);
        }
    ;

declaracao_variavel
    : TIPO_INTEIRO IDENTIFICADOR PONTO_E_VIRGULA
        {
          no *filhos[2] = { cria_no("TIPO_INTEIRO", NULL, 0), cria_no("IDENTIFICADOR", NULL, 0) };
          $$ = cria_no("declaracao_variavel", filhos, 2);
        }
    | TIPO_INTEIRO IDENTIFICADOR OPERADOR_ATRIBUICAO expressao PONTO_E_VIRGULA
        {
          no *filhos[3] = { cria_no("TIPO_INTEIRO", NULL, 0), cria_no("IDENTIFICADOR", NULL, 0), cria_no("ATRIBUICAO", NULL, 0) };
          no *atribuicao_filho[2] = { filhos[2], $4 };
          no *atribuicao = cria_no("atribuicao", atribuicao_filho, 2);
          no *filhos_com_atribuicao[2] = { filhos[0], atribuicao };
          $$ = cria_no("declaracao_variavel", filhos_com_atribuicao, 2);
        }
    /* Repita para outros tipos e casos seguindo a mesma lógica */
    ;

declaracao_funcao
    : TIPO_INTEIRO IDENTIFICADOR PARENTESE_E PARENTESE_D bloco
        {
          no *filhos[3] = {
            cria_no("TIPO_INTEIRO", NULL, 0),
            cria_no("IDENTIFICADOR", NULL, 0),
            $5
          };
          $$ = cria_no("declaracao_funcao", filhos, 3);
        }
    | TIPO_INTEIRO IDENTIFICADOR PARENTESE_E lista_parametros PARENTESE_D bloco
        {
          no *filhos[4] = {
            cria_no("TIPO_INTEIRO", NULL, 0),
            cria_no("IDENTIFICADOR", NULL, 0),
            $4,
            $6
          };
          $$ = cria_no("declaracao_funcao", filhos, 4);
        }
    /* Repita para outros tipos */
    ;

lista_parametros
    : TIPO_INTEIRO IDENTIFICADOR
        {
          no *filhos[2] = { cria_no("TIPO_INTEIRO", NULL, 0), cria_no("IDENTIFICADOR", NULL, 0) };
          $$ = cria_no("parametro", filhos, 2);
        }
    | lista_parametros VIRGULA TIPO_INTEIRO IDENTIFICADOR
        {
          no *param = cria_no("parametro", (no*[]){ cria_no("TIPO_INTEIRO", NULL, 0), cria_no("IDENTIFICADOR", NULL, 0) }, 2);
          no *filhos[2] = { $1, param };
          $$ = cria_no("lista_parametros", filhos, 2);
        }
    ;

estrutura_controle
    : IF PARENTESE_E expressao PARENTESE_D bloco ELSE bloco
        {
          no *filhos[3] = { $3, $5, $7 };
          $$ = cria_no("IF_ELSE", filhos, 3);
        }
    | IF PARENTESE_E expressao PARENTESE_D bloco
        {
          no *filhos[2] = { $3, $5 };
          $$ = cria_no("IF", filhos, 2);
        }
    | WHILE PARENTESE_E expressao PARENTESE_D bloco
        {
          no *filhos[2] = { $3, $5 };
          $$ = cria_no("WHILE", filhos, 2);
        }
    | FOR PARENTESE_E declaracao_variavel expressao PONTO_E_VIRGULA expressao PARENTESE_D bloco
        {
        no *condicao_iteracao = cria_no("condicao_iteracao", (no*[]){ $4, $6 }, 2);
        no *variavel = cria_no("variavel", (no*[]){ $3 }, 1);
        no *filhos[3] = { variavel, condicao_iteracao, $8 };
        $$ = cria_no("FOR", filhos, 3);
        }
    ;

bloco
    : CHAVE_E lista_declaracoes CHAVE_D
        {
          no *filhos[1] = { $2 };
          $$ = cria_no("bloco", filhos, 1);
        }
    | CHAVE_E CHAVE_D
        {
          $$ = cria_no("bloco_vazio", NULL, 0);
        }
    ;

%%

void yyerror(const char *s) {
    if (yychar == YYEMPTY) {
        fprintf(stderr, "Erro sintatico: %s na linha %d, coluna %d\n", s, linha, coluna);
    } else {
        fprintf(stderr, "Erro sintatico: %s proximo do token '%s' na linha %d, coluna %d\n", s, yytext, linha, coluna);
    }
}

int main(int argc, char **argv) {
    int opcao;
    char arquivo[256];

    do {
        printf("\nMenu:\n");
        printf("1. Inserir arquivo de teste\n");
        printf("2. Mostrar arvore sintatica\n");
        printf("3. Mostrar tabela de simbolos\n");
        printf("4. Palavras reservadas\n");
        printf("5. Sair\n");
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
                printf("Iniciando analise do arquivo '%s'...\n", arquivo);
                raiz_arvore = NULL;
                yyparse();
                printf("Analise finalizada.\n");
                fclose(yyin);
                linha = 1; coluna = 1;
                break;

            case 2:
                if (raiz_arvore) {
                    printf("\narvore sintatica:\n");
                    imprime_arvore(raiz_arvore);
                } else {
                    printf("Nenhuma arvore para mostrar. Execute a analise primeiro.\n");
                }
                break;
            case 3:
                imprimir_simbolos();
                break;
            case 4:
                imprimir_palavras_reservadas();
                break;
            case 5:
                printf("Saindo...\n");
                break;

            default:
                printf("Opcao invalida. Tente novamente.\n");
        }
    } while (opcao != 5);

    return 0;
}
