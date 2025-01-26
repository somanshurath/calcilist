#ifndef CALCILIST_H
#define CALCILIST_H

#define YYSTYPE list*
typedef struct _list {
    struct _list *first, *rest;
    double value;
    char *name;
} list;
extern char *yytext;

list *NewNode(void);

typedef struct symbol {
    char *name;
    list *value;
    struct symbol *next;
} symbol;
#endif
