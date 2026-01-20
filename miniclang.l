%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils/tokens.h"
#include "miniclang.tab.h"

extern FILE *yyin;
int linha = 1;
int coluna = 1;
%}

DIGITO              [0-9]
LETRA               [a-zA-Z]
IDENTIFICADOR       {LETRA}({LETRA}|{DIGITO}|"_")*
NUMERO_INTEIRO      [-+]?{DIGITO}+
NUMERO_REAL         {DIGITO}+"."{DIGITO}+
STRING              \"([^\\\"\n]|\\.)*\"
CARACTER            \'.\'
COMENTARIO_LINHA    "#"([^\n]*)
COMENTARIO_BLOCO    "/*"([^*]|[*]+([^*/]|[\r\n]))*"*/"
COMENTARIO_SEM_FECHADOR "/*"([^*]|[*]+([^*/]|[\r\n]))*
ESPACO              [ \t\r]+
QUEBRA_DE_LINHA     \n
NUM_MAL_FORMADO     [-+]?({DIGITO}*\.*{DIGITO}+\.*|{DIGITO}+\.+)
STRING_MAL_FORMADA  \"([^\"\n]*)\n

%%

"import"   { inserir_palavra_reservada(yytext, "IMPORT"); coluna += yyleng; return IMPORT; }
"input"    { inserir_palavra_reservada(yytext, "INPUT"); coluna += yyleng; return INPUT; }
"print"    { inserir_palavra_reservada(yytext, "PRINT"); coluna += yyleng; return PRINT; }
"while"    { inserir_palavra_reservada(yytext, "WHILE"); coluna += yyleng; return WHILE; }
"for"      { inserir_palavra_reservada(yytext, "FOR"); coluna += yyleng; return FOR; }
"if"       { inserir_palavra_reservada(yytext, "IF"); coluna += yyleng; return IF; }
"else"     { inserir_palavra_reservada(yytext, "ELSE"); coluna += yyleng; return ELSE; }
"break"    { inserir_palavra_reservada(yytext, "BREAK"); coluna += yyleng; return BREAK; }
"return"   { inserir_palavra_reservada(yytext, "RETURN"); coluna += yyleng; return RETURN; }
"or"       { inserir_palavra_reservada(yytext, "LOGICO_OR"); coluna += yyleng; return LOGICO_OR; }
"and"      { inserir_palavra_reservada(yytext, "LOGICO_AND"); coluna += yyleng; return LOGICO_AND; }
"int"      { inserir_palavra_reservada(yytext, "TIPO_INTEIRO"); coluna += yyleng; return TIPO_INTEIRO; }
"float"    { inserir_palavra_reservada(yytext, "TIPO_FLOAT"); coluna += yyleng; return TIPO_FLOAT; }
"char"     { inserir_palavra_reservada(yytext, "TIPO_CARACTER"); coluna += yyleng; return TIPO_CARACTER; }
"string"   { inserir_palavra_reservada(yytext, "TIPO_STRING"); coluna += yyleng; return TIPO_STRING; }
"double"   { inserir_palavra_reservada(yytext, "TIPO_DOUBLE"); coluna += yyleng; return TIPO_DOUBLE; }
"bool"     { inserir_palavra_reservada(yytext, "TIPO_BOOL"); coluna += yyleng; return TIPO_BOOL; }
"void"     { inserir_palavra_reservada(yytext, "TIPO_VOID"); coluna += yyleng; return TIPO_VOID; }

"<-"   { inserir_simbolo(yytext, "ATRIBUICAO_CONDICIONAL"); coluna += yyleng; return ATRIBUICAO_CONDICIONAL; }
"!="   { inserir_simbolo(yytext, "NE"); coluna += yyleng; return NE; }
"=="   { inserir_simbolo(yytext, "EQ"); coluna += yyleng; return EQ; }
">="   { inserir_simbolo(yytext, "GE"); coluna += yyleng; return GE; }
"<="   { inserir_simbolo(yytext, "LE"); coluna += yyleng; return LE; }
"<"    { inserir_simbolo(yytext, "MENOR_QUE"); coluna += yyleng; return MENOR_QUE; }
">"    { inserir_simbolo(yytext, "MAIOR_QUE"); coluna += yyleng; return MAIOR_QUE; }
"="    { inserir_simbolo(yytext, "OPERADOR_ATRIBUICAO"); coluna += yyleng; return OPERADOR_ATRIBUICAO; } 
"+="   { inserir_simbolo(yytext, "ACUMULADOR_SOMA"); coluna += yyleng; return ACUMULADOR_SOMA; }
"-="   { inserir_simbolo(yytext, "ACUMULADOR_SUBTRACAO"); coluna += yyleng; return ACUMULADOR_SUBTRACAO; }
"+"    { inserir_simbolo(yytext, "OPERADOR_SOMA"); coluna += yyleng; return OPERADOR_SOMA; }
"-"    { inserir_simbolo(yytext, "OPERADOR_SUBTRACAO"); coluna += yyleng; return '-'; }
"*"    { inserir_simbolo(yytext, "OPERADOR_MULTIPLICACAO"); coluna += yyleng; return '*'; }
"/"    { inserir_simbolo(yytext, "OPERADOR_DIVISAO"); coluna += yyleng; return '/'; }
"%"    { inserir_simbolo(yytext, "OPERADOR_MODULO"); coluna += yyleng; return '%'; }
"++"   { inserir_simbolo(yytext, "INCREMENTO"); coluna += yyleng; return INCREMENTO; }
"--"   { inserir_simbolo(yytext, "DECREMENTO"); coluna += yyleng; return DECREMENTO; }
"{"    { inserir_simbolo(yytext, "CHAVE_E"); coluna += yyleng; return CHAVE_E; }
"}"    { inserir_simbolo(yytext, "CHAVE_D"); coluna += yyleng; return CHAVE_D; }
"("    { inserir_simbolo(yytext, "PARENTESE_E"); coluna += yyleng; return PARENTESE_E; }
")"    { inserir_simbolo(yytext, "PARENTESE_D"); coluna += yyleng; return PARENTESE_D; }
"["    { inserir_simbolo(yytext, "COLCHETE_E"); coluna += yyleng; return COLCHETE_E; }
"]"    { inserir_simbolo(yytext, "COLCHETE_D"); coluna += yyleng; return COLCHETE_D; }
";"    { inserir_simbolo(yytext, "PONTO_E_VIRGULA"); coluna += yyleng; return PONTO_E_VIRGULA; }
","    { inserir_simbolo(yytext, "VIRGULA"); coluna += yyleng; return VIRGULA; }

{IDENTIFICADOR}     { inserir_simbolo(yytext, "IDENTIFICADOR"); coluna += yyleng; return IDENTIFICADOR; }
{NUMERO_INTEIRO}    { inserir_simbolo(yytext, "NUMERO_INTEIRO"); coluna += yyleng; return NUMERO_INTEIRO; }
{NUMERO_REAL}       { inserir_simbolo(yytext, "NUMERO_REAL"); coluna += yyleng; return NUMERO_REAL; }
{STRING}            { inserir_simbolo(yytext, "STRING"); coluna += yyleng; return STRING; }
{CARACTER}          { inserir_simbolo(yytext, "CARACTER"); coluna += yyleng; return CARACTER; }
{COMENTARIO_LINHA}         { return COMENTARIO_LINHA; }
{COMENTARIO_BLOCO}         { return COMENTARIO_BLOCO; }
{ESPACO}          { coluna += yyleng; }
{QUEBRA_DE_LINHA} { linha++; coluna = 1; }


{COMENTARIO_SEM_FECHADOR}  {
    printf("Erro lexico: Comentario não fechado corretamente na linha %d, coluna %d.\n", linha, coluna);
    coluna += yyleng;
}
{NUM_MAL_FORMADO} {
    printf("Erro lexico: Número mal formado '%s' na linha %d, coluna: %d\n", yytext, linha, coluna);
    coluna += yyleng;
}
{STRING_MAL_FORMADA} {
    printf("Erro lexico: String mal formada '%s' na linha %d, coluna %d\n", yytext, linha, coluna);
    coluna += yyleng;
    linha++;
}
. {
    printf("Erro lexico: caractere não reconhecido '%s' na linha %d, coluna %d\n", yytext, linha, coluna);
    coluna += yyleng;
}


%%

int yywrap(void) {
    return 1;
}
