/****************************************************/
/* File: tiny.y                                                                   */
/* The C - Yacc/Bison specification file                    */
/* Compiler Construction: Principles and Practice     */
/* Kenneth C. Louden                                                    */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "scan.h"
#include "globals.h"
#include "util.h"
#include "parse.h"

#define YYSTYPE TreeNode *

static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void);
int yyerror(char *);

%}
/* reversed words */
%token IF ELSE INT RETURN VOID WHILE
/* multicharactor tokens */
%token ID NUM 
/* special symbols */
%token ASSIGN EQ NE LT LE GT GE PLUS MINUS TIMES OVER LPAREN RPAREN LBRACE RBRACE LCURLY RCURLY SEMI COMMA
/* book - keeping tokens */
%token ERROR COMMENTERROR

%% 
/* Grammar for C minus */
/* user difined action codes는 reduce될 때 수행된다 */

program     : declaration-list
                    {
                        savedTree = $1;
                    }
                    ;

id : ID
    {
        savedName = copyString(tokenString); 
    }
    ;
num : NUM
        {
            $$ = newExpNode(NumK);
            $$->attr.val = atoi(tokenString);
        }
        ;

declaration-list : declaration-list declaration
                            {
                                YYSTYPE t = $1;
                                if (t != NULL){
                                    while (t->sibling != NULL){
                                        t = t->sibling;
                                    }
                                    t->sibling = $2;
                                    $$ = $1; 
                                }
                                else $$ = $2;
                            }
                            | declaration
                            {
                                $$ = $1;
                            }
                            ;

declaration : var-declaration
                    {
                        $$ = $1;
                    }
                    | fun-declaration
                    {
                        $$ = $1;
                    }
                    ;

var-declaration : type-specifier id SEMI
                            {
                                $$ = newDeclNode(VarK);
                                $$->child[0] = $1;
                                $$->attr.name = savedName;
                            }
                            | type-specifier id LBRACE 
                            {
                                $$ = newDeclNode(ArrVarK);
                                $$->child[0] = newExpNode(TypeK);
                                $$->child[0]->type = IntegerArray;
                                $$->attr.name = savedName;
                            }
                            num RBRACE SEMI
                            {
                                $$ = $4;
                                $$->child[1] = $5;
                            }
                            ;

type-specifier  : INT
                        {
                            $$ = newExpNode(TypeK);
                            $$->type = Integer;
                        }
                        | VOID
                        {
                            $$ = newExpNode(TypeK);
                            $$->type = Void;
                        }
                        ;

fun-declaration : type-specifier id LPAREN 
                            {
                                $$ = newDeclNode(FunK);
                                $$->child[0] = $1;
                                $$->attr.name = savedName;
                            }
                            params RPAREN compound-stmt
                            {
                                $$ = $4;
                                $$->child[1] = $5;
                                $$->child[2] = $7;
                            }
                            ;

params : params-list
            {
                $$ = $1;
            }
            | VOID
            {
                $$ = NULL;
            }
            ;

params-list : params-list COMMA param
            {
                YYSTYPE t = $1;
                if (t != NULL){
                    while (t->sibling != NULL){
                        t = t->sibling;
                    }
                    t->sibling = $3;
                    $$ = $1; 
                }
                else $$ = $1;
            }
            | param
            {
                $$ = $1;
            }
            ;

param : type-specifier id
            {
                $$ = newDeclNode(ParamK);
                $$->child[0] = $1;
                $$->attr.name = savedName;
            }
            | type-specifier id LBRACE RBRACE
            {
                $$ = newDeclNode(ArrParamK);
                $$->child[0] = $1;
                $$->attr.name = savedName;
            }
            ;

compound-stmt : LCURLY local-declarations statement-list RCURLY
                            {
                                $$ = newStmtNode(CompoundK);
                                $$->child[0] = $2;
                                $$->child[1] = $3;
                            }
                            | /* empty */
                            {
                                $$ = NULL;
                            }
                            ;

local-declarations : local-declarations var-declaration
                                {
                                    YYSTYPE t = $1;
                                    if (t != NULL){
                                        while (t->sibling != NULL)
                                            t = t->sibling;
                                        t->sibling = $2;
                                        $$ = $1; }
                                    else $$ = $2;
                                }
                                | /* empty */
                                {
                                    $$ = NULL;
                                }
                                ;

statement-list : statement-list statement
                        {
                            YYSTYPE t = $1;
                            if (t != NULL){
                                while (t->sibling != NULL)
                                    t = t->sibling;
                                t->sibling = $2;
                                $$ = $1; }
                            else $$ = $2;
                        }
                        | /* empty */
                        {
                            $$ = NULL;
                        }
                        ;

statement : expression-stmt
                    {
                        $$ = $1;
                    }
                    | compound-stmt
                    {
                        $$ = $1;
                    }
                    | selection-stmt
                    {
                        $$ = $1;
                    }
                    | iteration-stmt
                    {
                        $$ = $1;
                    }
                    | return-stmt
                    {
                        $$ = $1;
                    }
                    ;

expression-stmt : expression SEMI
                            {
                                $$ = $1;
                            }
                            | SEMI
                            {
                                $$ = NULL;
                            }
                            ;

selection-stmt : IF LPAREN expression RPAREN statement
                            {
                                $$ = newStmtNode(IfK);
                                $$->child[0] = $3;
                                $$->child[1] = $5;
                            }
                            | IF LPAREN expression RPAREN statement ELSE statement
                            {
                                $$ = newStmtNode(IfK);
                                $$->child[0] = $3;
                                $$->child[1] = $5;
                                $$->child[2] = $7;
                            }
                            ;

iteration-stmt : WHILE LPAREN expression RPAREN statement
                        {
                            $$ = newStmtNode(WhileK);
                            $$->child[0] = $3;
                            $$->child[1] = $5;
                        }
                        ;

return-stmt : RETURN SEMI
                    {
                        $$ = newStmtNode(ReturnK);
                        $$->attr.name = NULL;
                    }
                    | RETURN expression SEMI
                    {
                        $$ = newStmtNode(ReturnK);
                        $$->child[0] = $2;
                    }
                    ;

expression : var ASSIGN expression
                    {
                        $$ = newStmtNode(AssignK);
                        $$->child[0] = $1;
                        $$->child[1] = $3;
                    }
                    | simple-expression
                    {
                        $$ = $1;
                    }
                    ;

var : id
        {
            $$ = newExpNode(IdK);
            $$->attr.name = savedName;
        }
        | id 
        {
            $$ = newExpNode(ArrK);
            $$->attr.name = savedName;
        }
            LBRACE expression RBRACE
        {
            $$ = $2;
            $$->child[0] = $4;
        }
        ;

simple-expression : | additive-expression LE additive-expression
                                {
                                    $$ = newExpNode(simpleK);
                                    $$->child[0] = $1;
                                    $$->child[1] = newExpNode(OpK);
                                    $$->child[1]->attr.op = LE;
                                    $$->child[2] = $3;
                                }
                                | additive-expression LT additive-expression
                                {
                                    $$ = newExpNode(simpleK);
                                    $$->child[0] = $1;
                                    $$->child[1] = newExpNode(OpK);
                                    $$->child[1]->attr.op = LT;
                                    $$->child[2] = $3;
                                }
                                | additive-expression GT additive-expression
                                {
                                    $$ = newExpNode(simpleK);
                                    $$->child[0] = $1;
                                    $$->child[1] = newExpNode(OpK);
                                    $$->child[1]->attr.op = GT;
                                    $$->child[2] = $3;
                                }
                                | additive-expression GE additive-expression
                                {
                                    $$ = newExpNode(simpleK);
                                    $$->child[0] = $1;
                                    $$->child[1] = newExpNode(OpK);
                                    $$->child[1]->attr.op = GE;
                                    $$->child[2] = $3;
                                }
                                | additive-expression EQ additive-expression
                                {
                                    $$ = newExpNode(simpleK);
                                    $$->child[0] = $1;
                                    $$->child[1] = newExpNode(OpK);
                                    $$->child[1]->attr.op = EQ;
                                    $$->child[2] = $3;
                                }
                                | additive-expression NE additive-expression
                                {
                                    $$ = newExpNode(simpleK);
                                    $$->child[0] = $1;
                                    $$->child[1] = newExpNode(OpK);
                                    $$->child[1]->attr.op = NE;
                                    $$->child[2] = $3;
                                }
                                | additive-expression
                                {
                                    $$ = $1;
                                }
                                ;

additive-expression : additive-expression PLUS term
                                    {
                                        $$ = newExpNode(addK);
                                        YYSTYPE t = $1;
                                        if (t != NULL){
                                            while (t->sibling != NULL)
                                                t = t->sibling;
                                            t->sibling = newExpNode(OpK);
                                            t->sibling-> attr.op = PLUS;
                                            t->sibling->sibling = $3;
                                            $$->child[0] = $1; }
                                        //else $$ = $2;
                                    }
                                    | additive-expression MINUS term
                                    {
                                        $$ = newExpNode(addK);
                                        YYSTYPE t = $1;
                                        if (t != NULL){
                                            while (t->sibling != NULL)
                                                t = t->sibling;
                                            t->sibling = newExpNode(OpK);
                                            t->sibling-> attr.op = MINUS;
                                            t->sibling->sibling = $3;
                                            $$->child[0] = $1; }
                                        //else $$ = $2;
                                    }
                                    | term
                                    {
                                        $$ = $1;
                                    }
                                    ;

term : term TIMES factor
        {
            $$ = newExpNode(mulK);
            YYSTYPE t = $1;
            if (t != NULL){
            while (t->sibling != NULL)
                t = t->sibling;
            t->sibling = newExpNode(OpK);
            t->sibling-> attr.op = TIMES;
            t->sibling->sibling = $3;
            $$->child[0] = $1; }
            //else $$ = $2;
        }
        | term OVER factor
        {
            $$ = newExpNode(mulK);
            YYSTYPE t = $1;
            if (t != NULL){
            while (t->sibling != NULL)
                t = t->sibling;
            t->sibling = newExpNode(OpK);
            t->sibling-> attr.op = OVER;
            t->sibling->sibling = $3;
            $$->child[0] = $1; }
            //else $$ = $2;
        }
        | factor
        {
            $$ = $1;
        }
        ;

factor : LPAREN expression RPAREN
            {
                $$ = $2;
            }
            | var
            {
                $$ = $1;
            }
            | call
            {
                $$ = $1;
            }
            | num
            {
                $$ = newExpNode(NumK);
                $$->attr.val = atoi(tokenString);
                $$->type = Integer;
            }
            ;

call : id 
        {
            $$ = newExpNode(FunCallK);
            $$->attr.name = savedName;
        } 
            LPAREN args RPAREN
        {
            $$ = $2;
            $$->child[0] = $4;
        }
        ;

args : arg-list
        {
            $$ = $1;
        }
        | /* empty */
        {
            $$ = NULL;
        }
        ;

arg-list : arg-list COMMA expression
            {
                YYSTYPE t = $1;
                if (t != NULL) {
                    while (t->sibling != NULL)
                        t = t->sibling;
                    t->sibling = $3;
                    $$ = $1;}
                else 
                    $$ = $3;
            }
            | expression
            {
                $$ = $1;
            }
            ;


%%

int yyerror(char * message)
{ 
    fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
    fprintf(listing,"Current token: ");
    printToken(yychar,tokenString);
    Error = TRUE;
    return 0;
}

/* 
 * yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */

static int yylex(void)
{ 
    return getToken();
}

TreeNode * parse(void)
{ 
    yyparse();
    return savedTree;
}

