#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arvore.h"

no* cria_no(const char *rotulo, no **filhos, int num_filhos) {
    no *novo = (no*) malloc(sizeof(no));
    novo->rotulo = strdup(rotulo);
    novo->num_filhos = num_filhos;

    if (num_filhos > 0) {
        novo->filhos = (no**) malloc(sizeof(no*) * num_filhos);
        for (int i = 0; i < num_filhos; i++)
            novo->filhos[i] = filhos[i];
    } else {
        novo->filhos = NULL;
    }

    return novo;
}


void imprime_arvore_formatado_ascii(no *raiz, int nivel, bool tem_irmao[]) {
    if (!raiz) return;

    // Imprime indentação e linhas verticais
    for (int i = 0; i < nivel; i++) {
        if (tem_irmao[i]) {
            printf("|   ");
        } else {
            printf("    ");
        }
    }

    if (nivel > 0) {  // Para o root (nivel 0) não imprime conector
        if (tem_irmao[nivel - 1]) {
            printf("|-- ");
        } else {
            printf("\\-- ");
        }
    }

    // Imprime o rótulo do nó
    printf("%s\n", raiz->rotulo);

    // Para filhos, marcar se são irmãos para níveis inferiores
    for (int i = 0; i < raiz->num_filhos; i++) {
        tem_irmao[nivel] = (i < raiz->num_filhos - 1);  // true se não último filho
        imprime_arvore_formatado_ascii(raiz->filhos[i], nivel + 1, tem_irmao);
    }
}

void imprime_arvore(no *raiz) {
    bool tem_irmao[256] = { false };
    imprime_arvore_formatado_ascii(raiz, 0, tem_irmao);
}