#ifndef ARVORE_H
#define ARVORE_H

#include <stdbool.h>

typedef struct no {
    char *rotulo;
    struct no **filhos;  
    int num_filhos;       
} no;


no* cria_no(const char *rotulo, no **filhos, int num_filhos);
void imprime_arvore(no *raiz);

#endif // ARVORE_H
