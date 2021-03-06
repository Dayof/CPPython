%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "sym_tab.h"
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
    char char_value;
    char* str_value;
    int int_value;
    float float_value;
}

%token <char_value>     BRACK_LEFT BRACK_RIGHT PARENT_LEFT PARENT_RIGHT SEMICOLON
%token <char_value>     ADD SUB MULT DIV COMMA ASSIGN NOT_OP L_OP G_OP
%token <str_value>      READ WRITE WRITELN TYPE EMPTY STRING RETURN FORALL FOR
%token <str_value>      IN IS_SET ADD_SET REMOVE EXISTS IF ELSE CHAR
%token <str_value>      EQ_OP NE_OP LE_OP GE_OP OR_OP AND_OP
%token <int_value>      INTEGER ID
%token <float_value>    FLOAT

%left                   L_OP G_OP EQ_OP NE_OP LE_OP GE_OP
%left                   ADD SUB
%left                   MULT DIV
%left                   UMINUS

%nonassoc THEN
%nonassoc ELSE

%%

program : stmts
        ;

stmts   : stmts stmt
        | stmt
        ;

stmt    : func_stmt
        | var_decl_stmt
        ;

func_stmt   : TYPE ID PARENT_LEFT param_list PARENT_RIGHT compound_block_stmt
            ;

var_decl_stmt   : TYPE ID SEMICOLON
                ; 

param_list  : param_list COMMA TYPE ID
            | TYPE ID
            | /* empty */
            ;

simple_param_list   : simple_param_list COMMA simple_expr
                    | simple_expr
                    | /* empty */
                    ;

compound_block_stmt : BRACK_LEFT block_stmts BRACK_RIGHT
                    | BRACK_LEFT BRACK_RIGHT
                    ;

block_stmts : block_stmts block_item
            | block_item
            ;

block_item  : var_decl_stmt
            | block_stmt
            ;
    
block_stmt  : compound_block_stmt
            | func_call SEMICOLON
            | set_func_call SEMICOLON
            | flow_control
            | READ PARENT_LEFT ID PARENT_RIGHT SEMICOLON
            | WRITE PARENT_LEFT simple_expr PARENT_RIGHT SEMICOLON
            | WRITELN PARENT_LEFT simple_expr PARENT_RIGHT SEMICOLON
            | ID ASSIGN simple_expr SEMICOLON
            | RETURN simple_expr SEMICOLON
            ;

flow_control_if : IF PARENT_LEFT
                ;

flow_control    : flow_control_if or_cond_expr PARENT_RIGHT block_item %prec THEN
                | flow_control_if or_cond_expr PARENT_RIGHT block_item ELSE block_item
                | FORALL PARENT_LEFT set_expr PARENT_RIGHT block_item
                | FOR PARENT_LEFT opt_param opt_param PARENT_RIGHT block_item
                | FOR PARENT_LEFT opt_param opt_param for_expression PARENT_RIGHT block_item
                ;

opt_param   : SEMICOLON
            | for_expression SEMICOLON
            ;

for_expression  : decl_or_cond_expr
                | for_expression COMMA decl_or_cond_expr
                ; 

decl_or_cond_expr   : or_cond_expr
                    | TYPE ID ASSIGN simple_expr
                    | ID ASSIGN simple_expr
                    ;

or_cond_expr    : or_cond_expr OR_OP and_cond_expr
                | and_cond_expr
                ;

and_cond_expr   : and_cond_expr AND_OP unary_cond_expr
                | unary_cond_expr
                ;

unary_cond_expr : NOT_OP unary_cond_expr
                | eq_cond_expr
                ;

eq_cond_expr    : eq_cond_expr equal_ops rel_cond_expr
                | rel_cond_expr
                ;

equal_ops   : EQ_OP
            | NE_OP
            ;

rel_cond_expr   : rel_cond_expr rel_ops rel_cond_stmt
                | rel_cond_stmt
                ;

rel_cond_stmt   : arith_expr
                | EMPTY
                ;

rel_ops : L_OP
        | G_OP
        | LE_OP
        | GE_OP
        | IN
        ;           
    
set_expr    : simple_expr IN simple_expr
            ;   

func_call   : ID PARENT_LEFT simple_param_list PARENT_RIGHT
            ;

set_func_call   : IS_SET PARENT_LEFT ID PARENT_RIGHT
                | ADD_SET PARENT_LEFT set_expr PARENT_RIGHT
                | REMOVE PARENT_LEFT set_expr PARENT_RIGHT
                | EXISTS PARENT_LEFT set_expr PARENT_RIGHT
                ;

simple_expr : arith_expr
            | func_cte_expr
            ;

func_cte_expr   : EMPTY
                | STRING
                | CHAR
                ;

func_expr       : func_call
                | set_func_call
                | PARENT_LEFT func_cte_expr PARENT_RIGHT
                ;

arith_expr  : arith_expr ADD term
            | arith_expr SUB term
            | term
            ;

term    : term MULT mid_factor
        | term DIV mid_factor
        | mid_factor
        ;

mid_factor  : SUB factor %prec UMINUS
            | factor
            ;

factor  : INTEGER
        | FLOAT
        | ID
        | PARENT_LEFT arith_expr PARENT_RIGHT
        | func_expr
        ;

%%

void yyerror(const char *s) {
    printf("\nSyntaxError: %s in line %d, column %d.\n",
           s, parser_line, parser_column);
    syntax_error += 1;
}
