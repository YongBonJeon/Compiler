#
# Introduction to Compiler Construction
# makefile for C minus
# Jeon Yong Bon
#

CC = gcc

hw1_binary: main.o globals.h util.o lex.yy.o
	$(CC) $(CFLAGS)  main.o util.o lex.yy.o -o hw1_binary -ll

main.o: main.c globals.h util.h
	$(CC) $(CFLAGS) -c main.c

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) -c util.c

lex.yy.o: tiny.l util.h globals.h
	flex tiny.l
	$(CC) $(CFLAGS) -c lex.yy.c

clean:
	-rm hw1_binary
	-rm main.o
	-rm util.o
	-rm lex.yy.o
	-rm lex.yy.c

all: hw1_binary

