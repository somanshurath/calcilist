YACC:=bison -d
LEX:=flex
CFLAGS:=-Wall -lm -DYYERROR_VERBOSE
CC:=gcc
all : Makefile a.out
a.out: lex.yy.c calcilist.tab.c calcilist.h calcilist.tab.h Makefile
	$(CC) $(CFLAGS) lex.yy.c calcilist.tab.c

lex.yy.c: calcilist.l
	$(LEX) calcilist.l

calcilist.tab.c: calcilist.y
y.tab.c: calcilist.y
	$(YACC) calcilist.y

