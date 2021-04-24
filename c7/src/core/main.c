#include <stdio.h>
#include "scope.h"
#include "sym_tab.h"
#include "main.h"
#include "ast.h"
#include "lexer.h"
#include "parser.h"

void init_vars() {
    int verbose = 0;
    LEX_VERBOSE = verbose;
    PARSER_VERBOSE = verbose;
    MAIN_VERBOSE = verbose;
    SEMANTIC_VERBOSE = 1;
    newline_counter = -1;
    parser_error = lex_error = semantic_error = 0;

    global_symbol_table = NULL;
    scope_stack = NULL;
}

int main (int argc, char* argv[]) {
	printf("Welcome to C7 interpreter:\n");
    init_vars();

    // init lexer and parser
    printf("Lexer/parser:\n");
    lex_line = lex_column = parser_line = parser_column = 1;
    create_empy_ast();
    start_root_scope();
    yyin = fopen(argv[1], "r");
    if (MAIN_VERBOSE) printf("\nline %d. ", lex_line);
    do {
        yyparse();
    } while (!feof(yyin));
    fclose(yyin);
    printf("\nLexer and parser finished.\n\n");

    printf("\n## Symbol Table ##\n");
    print_aux_st();

    if (!(parser_error || lex_error)) {
        printf("\n\n## Abstract Syntax Tree ##");
        print_asts(ast_root);
    }

    // clean memory
    delete_all_st();
    if (MAIN_VERBOSE) printf("symbol table cleaned\n");
    delete_all_ast();
    if (MAIN_VERBOSE) printf("asts cleaned\n");
    yylex_destroy();
    if (MAIN_VERBOSE) printf("yylex cleaned\n");
	
    return 0;
}
