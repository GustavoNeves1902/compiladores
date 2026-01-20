#ifndef TOKENS_H
#define TOKENS_H

typedef struct Token {
    char* lexema;
    char* tipo;
    struct Token* prox;
} Token;

extern Token* lista_simbolos;
extern Token* lista_palavras_reservadas;

void inserir_simbolo(const char* lexema, const char* tipo);
void inserir_palavra_reservada(const char* lexema, const char* tipo);
void imprimir_simbolos();
void imprimir_palavras_reservadas();
void liberar_listas();

#endif
