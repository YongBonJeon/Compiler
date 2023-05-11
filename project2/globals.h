/****************************************************/
/* File: globals.h                                  */
/* Global types and vars for TINY compiler          */
/* must come before other include files             */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#ifndef YYPARSER
#include "tiny.tab.h"
#define ENDFILE 0
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

/* MAXRESERVED = the number of reserved words */
#define MAXRESERVED 6

typedef int TokenType;
/* ok */
//typedef enum 
    /* book-keeping tokens */
   //{ENDFILE,ERROR,COMMENTERROR,
    /* reserved words */
    //IF,ELSE,WHILE,RETURN,INT,VOID,
    /* multicharacter tokens */
    //ID,NUM,
    /* special symbols */
    //ASSIGN, EQ, NE, LT, LE, GT, GE, PLUS, MINUS, TIMES, OVER, LPAREN, RPAREN, LBRACE, RBRACE, LCURLY, RCURLY, SEMI, COMMA
   //} TokenType;

extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */

extern int lineno; /* source line number for listing */

/**************************************************/
/***********   Syntax tree for parsing ************/
/**************************************************/

typedef enum {DeclK, StmtK, ExpK} NodeKind;
typedef enum {VarK, FunK, ArrVarK, ParamK, ArrParamK} DeclKind;
typedef enum {CompoundK, IfK, WhileK, ReturnK, AssignK} StmtKind;
typedef enum {simpleK, addK,  mulK, OpK, NumK, IdK, FunCallK, TypeK, ArrK} ExpKind;

/* ExpType is used for type checking */
/* In C-, VOID, INT -> ExpType*/
typedef enum {Void, Integer, IntegerArray} ExpType;

#define MAXCHILDREN 3

typedef struct treeNode
{ 
    struct treeNode * child[MAXCHILDREN];
    struct treeNode * sibling;
    int lineno;
    /* Stmt or Exp*/
    NodeKind nodekind; 
    /* reversed words -> Stmt, Op, Num, ID -> Exp*/
    union { StmtKind stmt; ExpKind exp; DeclKind decl;} kind;
    union {
        /* OP or Value or name */
        TokenType op;
        int val;
        char * name; 
    } attr;
     ExpType type; /* for type checking of exps */
   } TreeNode;

/**************************************************/
/***********   Flags for tracing       ************/
/**************************************************/

/* EchoSource = TRUE causes the source program to
 * be echoed to the listing file with line numbers
 * during parsing
 */
extern int EchoSource;

/* TraceScan = TRUE causes token information to be
 * printed to the listing file as each token is
 * recognized by the scanner
 */
extern int TraceScan;

/* TraceParse = TRUE causes the syntax tree to be
 * printed to the listing file in linearized form
 * (using indents for children)
 */
extern int TraceParse;

/* TraceAnalyze = TRUE causes symbol table inserts
 * and lookups to be reported to the listing file
 */
extern int TraceAnalyze;

/* TraceCode = TRUE causes comments to be written
 * to the TM code file as code is generated
 */
extern int TraceCode;

/* Error = TRUE prevents further passes if an error occurs */
extern int Error; 
#endif
