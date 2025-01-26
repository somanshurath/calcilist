# Calcilist

Submission (Jan 26)
So I added [a-zA-Z_][a-zA-Z0-9_]* int calcilist.l which recognized at returns token var.
Created a struct called Symbol which will be beneficial to store the variable name and value of the list in the future.

Symbol table is a linked list of Symbol structs. I added helper functions to add and find a symbol in the symbol table.
Storing of variables and retrieving them is now possible.