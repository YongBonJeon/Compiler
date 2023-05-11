/****************************************************/
/* File: tiny.l                                     */
/* Lex specification for TINY                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}

digit               [0-9]
number          {digit}+
letter              [a-zA-Z]
identifier        {letter}+
newline           \n
whitespace     [ \t]+

%%

"if"                    {return IF;}
"else"                {return ELSE;}
"int"                  {return INT;}
"void"               {return VOID;}
"return"            {return RETURN;}
"while"              {return WHILE;}
"="                   {return ASSIGN;}
"=="                    {return EQ;}
"!="                   {return NE;}
"<"                    {return LT;}
"<="                  {return LE;}
">"                     {return GT;}
">="                  {return GE;}
"+"                    {return PLUS;}
"-"                     {return MINUS;}
"*"                     {return TIMES;}
"/"                     {return OVER;}
"("                     {return LPAREN;}
")"                     {return RPAREN;}
"["                     {return LBRACE;}
"]"                     {return RBRACE;}
"{"                     {return LCURLY;}
"}"                     {return RCURLY;}
";"                     {return SEMI;}
","                      {return COMMA;}
{number}          {return NUM;}
{identifier}        {return ID;}
{newline}          {lineno++;}
{whitespace}    {/* skip whitespace */}
"/*"                    { 
                                char c;
                                while(1)
                                { 
                                    c = input();
                                    if (c == EOF) 
                                        return COMMENTERROR;
                                    if(c=='*'){
				                        c=input();
                                        if(c==EOF)
                                            return COMMENTERROR;
				                        if(c=='/') break;
			                        }
                                    if (c == '\n') lineno++;
                                }
                           }
.               {return ERROR;}

%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t%d ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}

