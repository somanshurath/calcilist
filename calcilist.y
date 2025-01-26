%debug
%{
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <error.h>
#include <errno.h>

#include "calcilist.h"
#include "calcilist.tab.h"

void yyerror(char *s)
{
fprintf(stderr,"%s\n",s);
return;
}

int yywrap()
{
    return 1;
}

#define printob printf("[")
#define printcb printf("]")
#define println printf("\n")
#define printlist(l) PrintList(l); println

void PrintList(list *l) {
    if(l) {
        if(l->first) {
            printob;
            PrintList(l->first);
            PrintList(l->rest);
            printcb;
        }
        else printf("%g",l->value);
    }
}

int nodecount = 0;
list *NewNode(void) {
    list *temp = (list*)malloc(sizeof(list));
    if(temp) {
        nodecount++;
        temp->first = NULL;
        temp->rest = NULL;
        temp->value = M_E;
    }
    else error(-1,errno,"Allocation failed at %dth new node.", nodecount+1);
    return temp;
}

void FreeRecursive(list *l) {
    if(l) {
        FreeRecursive(l->first);
        FreeRecursive(l->rest);
        free(l);
        nodecount--;
    }
}

void AddAtomToList(double num, list *l) {
    if(l) {
        if(l->first) {
            AddAtomToList(num, l->first);
            AddAtomToList(num, l->rest);
        }
        else l->value += num;
    }
}

list *Add(list *one, list *two) {
    if(!(one || two)) return NULL;
    if(one && !two) return one;
    if(!one && two) return two;
    if(one->first) {
        if(two->first) {
            one->first = Add(one->first, two->first);
            one->rest = Add(one->rest, two->rest);
            return one;
        }
        else {
            AddAtomToList(two->value, one->first);
            free(two);
            return one;
        }
    }
    else {
        AddAtomToList(one->value, two);
        free(one);
        return two;
    }
}

void MultiplyAtomToList(double num, list *l) {
    if(l) {
        if(l->first) {
            MultiplyAtomToList(num, l->first);
            MultiplyAtomToList(num, l->rest);
        }
        else l->value *= num;
    }
}

list *Multiply(list *one, list *two) {
    if(!(one || two)) return NULL;
    if(one && !two) return one;
    if(!one && two) return two;
    if(one->first) {
        if(two->first) {
            one->first = Multiply(one->first, two->first);
            one->rest = Multiply(one->rest, two->rest);
            return one;
        }
        else {
            MultiplyAtomToList(two->value, one->first);
            free(two);
            return one;
        }
    }
    else {
        MultiplyAtomToList(one->value, two);
        free(one);
        return two;
    }
}

symbol *symbol_table = NULL;

symbol *FindSymbol(char *name) {
    symbol *current = symbol_table;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void AddSymbol(char *name, list *value) {
    symbol *existing = FindSymbol(name);
    if (existing) {
        FreeRecursive(existing->value);
        existing->value = value;
    } else {
        symbol *new_symbol = (symbol *)malloc(sizeof(symbol));
        if (!new_symbol) {
            error(-1, errno, "Allocation failed for new symbol.");
            return;
        }
        new_symbol->name = strdup(name);
        new_symbol->value = value;
        new_symbol->next = symbol_table;
        symbol_table = new_symbol;
    }
}

void FreeSymbolTable() {
    symbol *current = symbol_table;
    while (current) {
        symbol *next = current->next;
        free(current->name);
        FreeRecursive(current->value);
        free(current);
        current = next;
    }
    symbol_table = NULL;
}

list *lst; /* for debugging. temp. */

%}

%token NUM VAR

%%
LINES       :   LINES LINE
            |
            ;

LINE        :   VAR '\n'                        { printf("="); printlist(FindSymbol($1->name)->value); }
            |   EXPR '\n'                       { printlist($1); }
            |   VAR '=' EXPR '\n'               { AddSymbol($1->name,$3); }
            |   '\n'
            ;

EXPR        :   EXPR    '+'     TERM            { PrintList($1); printf("+"); PrintList($3); printf("="); $$ = Add($1,$3); printlist($$); }
            |   TERM                            { $$ = $1; }
            ;
TERM        :   TERM    '*'     FACTOR          { PrintList($1); printf("*"); PrintList($3); printf("="); $$ = Multiply($1,$3); printlist($$); }
            |   FACTOR                          { $$ = $1; }
            ;
FACTOR      :   '('     EXPR    ')'             { $$ = $2; }
            |   NUM                             { $$ = yylval; }
            |   VAR                             { $$ = NewNode(); $$ = FindSymbol($1->name)->value; }
            |   '['     LIST    ']'             { $$ = $2; }
            ;
LIST        :   NUM     EXTEND                  { $$ = NewNode(); $$->first = $1; $$->rest = $2; }
            |   '['     LIST    ']'     EXTEND  { $$ = NewNode(); $$->first = $2; $$->rest = $4; }
            ;
EXTEND      :   LIST                            { $$ = $1; }
            |                                   { $$ = NULL; }
            ;
%%

int main(int argc, char *argv[])
{
    yyparse();
    return 0;
}