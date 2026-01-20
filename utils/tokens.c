#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"

Token* lista_simbolos = NULL;
Token* lista_palavras_reservadas = NULL;

int existe(Token* lista, const char* lexema) {
    while (lista) {
        if (strcmp(lista->lexema, lexema) == 0)
            return 1;
        lista = lista->prox;
    }
    return 0;
}

void inserir_simbolo(const char* lexema, const char* tipo) {
    if (existe(lista_simbolos, lexema))
        return;

    Token* novo = malloc(sizeof(Token));
    if (!novo) {
        fprintf(stderr, "Erro de alocação de memória (simbolo)\n");
        exit(EXIT_FAILURE);
    }
    novo->lexema = strdup(lexema);
    novo->tipo = strdup(tipo);
    novo->prox = lista_simbolos;
    lista_simbolos = novo;
}

void inserir_palavra_reservada(const char* lexema, const char* tipo) {
    if (existe(lista_palavras_reservadas, lexema))
        return;

    Token* novo = malloc(sizeof(Token));
    if (!novo) {
        fprintf(stderr, "Erro de alocação de memória (palavra reservada)\n");
        exit(EXIT_FAILURE);
    }
    novo->lexema = strdup(lexema);
    novo->tipo = strdup(tipo);
    novo->prox = lista_palavras_reservadas;
    lista_palavras_reservadas = novo;
}


void imprimir_simbolos() {
    Token* atual;

    printf("\nSimbolos:\n");
    for (atual = lista_simbolos; atual; atual = atual->prox)
        printf("  - %s (%s)\n", atual->lexema, atual->tipo);
}

void imprimir_palavras_reservadas() {
    Token* atual;

    printf("\nPalavras Reservadas:\n");
    for (atual = lista_palavras_reservadas; atual; atual = atual->prox)
        printf("  - %s\n", atual->lexema);
}

void liberar_lista(Token* lista) {
    while (lista) {
        Token* temp = lista;
        lista = lista->prox;
        free(temp->lexema);
        free(temp->tipo);
        free(temp);
    }
}

void liberar_listas() {
    liberar_lista(lista_simbolos);
    liberar_lista(lista_palavras_reservadas);
}
