#
# Introduction to Compiler Construction
# makefile for C minus
# Jeon Yong Bon
#

CC = gcc

hw2_binary: main.o globals.h util.o lex.yy.o tiny.tab.o
	$(CC) $(CFLAGS)  main.o util.o lex.yy.o tiny.tab.o -o hw2_binary

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) -c util.c

lex.yy.o: tiny.l scan.h util.h globals.h
	flex tiny.l
	$(CC) $(CFLAGS) -c lex.yy.c

tiny.tab.o : tiny.y globals.h
	bison -d tiny.y
	$(CC) $(CFLAGS) -c tiny.tab.c

main.o: main.c globals.h util.h
	$(CC) $(CFLAGS) -c main.c

clean:
	-rm hw2_binary
	-rm main.o
	-rm util.o
	-rm lex.yy.o
	-rm lex.yy.c
	-rm tiny.tab.o

all: hw2_binary

