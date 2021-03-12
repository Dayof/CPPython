%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "ast.h"

    int yylex();
    void yyerror(const char *s);
%}

%output  "parser/parser.c"
%defines "parser/parser.h"
%define parse.error verbose
%define lr.type canonical-lr

%start program

%union {
    char op;
    char* str_value;
}

%token <op>             BRACK_LEFT BRACK_RIGHT PARENT_LEFT PARENT_RIGHT
%token <str_value>      READ ID

%%

program : block                                         { ; }
        ;

block   : BRACK_LEFT[L] stmts BRACK_RIGHT[R]            { printf("\n\nSYNTAX - %c stmts %c", $L, $R); }
        ; 

stmts   : stmts stmt                                    { ; }
        | /* empty */                                   { ; }
        ;

stmt    : READ[F] PARENT_LEFT[L] ID[C] PARENT_RIGHT[R]  { printf("\n\nSYNTAX - %s %c %s %c", $F, $L, $C, $R); }
        ;
        

%%

void yyerror(const char *s) {
    printf("\nSyntaxError: %s in line %d, column %d.\n",
           s, parser_line, parser_column);
    syntax_error = 1;
}
