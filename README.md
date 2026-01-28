execucao

flex miniclang.l ---
bison -d miniclang.y ---
Gcc utils/arvore.c utils/tokens.c lex.yy.c miniclang.tab.c -o compilador ---
./compilador //verificar para windows
