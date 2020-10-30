#ifndef __SYM_TAB_H__
#define __SYM_TAB_H__

#include "uthash.h"

typedef struct word_pos {
    int key;
    char name[50];
    UT_hash_handle hh; /* makes this structure hashable */
} word;

word* symbol_table;

void print_st();

void add_word(int key, char *name);
word* find_word(int word_key);
void delete_word(word* s);
void delete_all();

#endif // __SYM_TAB_H__