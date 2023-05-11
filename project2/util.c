/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"

/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */
void printToken(TokenType token, const char* tokenString )
{ 
    switch (token)
    { 
        case IF: fprintf(listing,"\t\t\tIF\t\t\t%s\n",tokenString); break;
        case WHILE: fprintf(listing,"\t\t\tWHILE\t\t\t%s\n",tokenString); break;
        case RETURN: fprintf(listing,"\t\t\tRETURN\t\t\t%s\n",tokenString); break;
        case INT: fprintf(listing,"\t\t\tINT\t\t\t%s\n",tokenString); break;
        case VOID: fprintf(listing,"\t\t\tVOID\t\t\t%s\n",tokenString); break;
        case ELSE: fprintf(listing,"\t\t\tELSE\t\t\t%s\n",tokenString); break;
        case ASSIGN: fprintf(listing, "\t\t\t=\t\t\t=\n"); break;
	    case EQ: fprintf(listing, "==\n"); break;
	    case NE: fprintf(listing, "!=\n"); break;
	    case LT: fprintf(listing, "<\n"); break;
	    case LE: fprintf(listing, "<=\n"); break;
	    case GT: fprintf(listing, ">\n"); break;
	    case GE: fprintf(listing, ">=\n"); break;
	    case LPAREN: fprintf(listing, "\t\t\t(\t\t\t(\n"); break;
	    case RPAREN: fprintf(listing, "\t\t\t)\t\t\t)\n"); break;
	    case LBRACE: fprintf(listing, "\t\t\t[\t\t\t[\n"); break;
	    case RBRACE: fprintf(listing, "\t\t\t]\t\t\t]\n"); break;
	    case LCURLY: fprintf(listing, "\t\t\t{\t\t\t{\n"); break;
	    case RCURLY: fprintf(listing, "\t\t\t}\t\t\t}\n"); break;
	    case SEMI: fprintf(listing, "\t\t\t;\t\t\t;\n"); break;
	    case COMMA: fprintf(listing, "\t\t\t,\t\t\t,\n"); break;
	    case PLUS: fprintf(listing, "+\n"); break;
	    case MINUS: fprintf(listing, "-\n"); break;
	    case TIMES: fprintf(listing, "*\n"); break;
	    case OVER: fprintf(listing, "/\n"); break;
        case NUM: fprintf(listing, "\t\t\tNUM\t\t\t%s\n",tokenString); break;
        case ID: fprintf(listing, "\t\t\tID\t\t\t%s\n",tokenString); break;
        //case ENDFILE: fprintf(listing, "\t\t\t1EOF\n"); break;
        case ERROR: fprintf(listing, "\t\t\tERROR\t\t\t%s\n",tokenString); break;
        case COMMENTERROR: fprintf(listing, "\t\t\tERROR\t\t\tComment Error\n"); break;
        default: break; fprintf(listing,"Unknown token: %d\n",token);
    }
}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind)
{ 
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t==NULL)
        fprintf(listing,"Out of memory error at line %d\n",lineno);
    else {
        for (i=0;i<MAXCHILDREN;i++)
            t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = StmtK;
        t->kind.stmt = kind;
        t->lineno = lineno;
    }
    return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind)
{
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t==NULL)
        fprintf(listing,"Out of memory error at line %d\n",lineno);
    else {
        for (i=0;i<MAXCHILDREN;i++) 
            t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = ExpK;
        t->kind.exp = kind;
        t->lineno = lineno;
        t->type = Void;
    }
    return t;
}

/* Function newDeclNode creates a new declaration
 * node for syntax tree construction
 */
TreeNode * newDeclNode(DeclKind kind)
{
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t==NULL)
        fprintf(listing,"Out of memory error at line %d\n",lineno);
    else {
        for (i=0;i<MAXCHILDREN;i++) 
            t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = DeclK;
        t->kind.exp = kind;
        t->lineno = lineno;
        t->type = Void;
    }
    return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else strcpy(t,s);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{ int i;
    //fprintf(listing,"%d",indentno);
  for (i=0;i<indentno;i++){
    fprintf(listing,"  ");
  }
}

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree( TreeNode * tree )
{   
    int i;
    INDENT;
    while (tree != NULL) {       
        printSpaces();
        /* IfK, WhileK, CompoundK, ReturnK, AssignK */
        if (tree->nodekind==StmtK)
        { 
            switch (tree->kind.stmt) {
                case IfK:
                    fprintf(listing,"If\n");
                    break;
                case WhileK:
                    fprintf(listing,"While\n");
                    break;
                case CompoundK:
                    fprintf(listing,"Compound Statement\n");
                    break;
                case ReturnK:
                    fprintf(listing,"Return\n");
                    break;
                case AssignK:
                    fprintf(listing,"Assign := \n");
                    break;
                default:
                    fprintf(listing,"Unknown Statement\n");
                    break;
            }
        }
        /* OpK, NumK, IdK, FunCallK, TypeK, ArrK */
        else if (tree->nodekind==ExpK)
        { 
            switch (tree->kind.exp) {
                case simpleK:
                    fprintf(listing,"Simple expression\n");
                    break;
                case addK:
                    fprintf(listing, "Additive expression\n");
                    break;
                case mulK:
                    fprintf(listing, "Multiple expression\n");
                    break;
                case OpK:
                    switch(tree->attr.op){
                        	    case EQ: fprintf(listing,"Operator : ");fprintf(listing, "==\n"); break;
	                            case NE: fprintf(listing,"Operator : ");fprintf(listing, "!=\n"); break;
	                            case LT: fprintf(listing,"Operator : ");fprintf(listing, "<\n"); break;
	                            case LE: fprintf(listing,"Operator : ");fprintf(listing, "<=\n"); break;
	                            case GT: fprintf(listing,"Operator : ");fprintf(listing, ">\n"); break;
	                            case GE: fprintf(listing,"Operator : ");fprintf(listing, ">=\n"); break;
                                case PLUS: fprintf(listing,"Operator : ");fprintf(listing, "+\n"); break;
	                            case MINUS: fprintf(listing,"Operator : ");fprintf(listing, "-\n"); break;
	                            case TIMES: fprintf(listing,"Operator : ");fprintf(listing, "*\n"); break;
	                            case OVER: fprintf(listing,"Operator : ");fprintf(listing, "/\n"); break;
                    }
                    break;
                case NumK:
                    fprintf(listing,"Constant : %d\n",tree->attr.val);
                    break;
                case IdK:
                    fprintf(listing,"Variable : %s\n",tree->attr.name);
                    break;
                case FunCallK:
                    fprintf(listing, "Call Function : %s\n", tree->attr.name);
                    break;
                case TypeK:
                    fprintf(listing, "Type : ");
                    if(tree->type == Integer)
                        fprintf(listing, "int\n");
                    else if(tree->type == Void)
                        fprintf(listing, "void\n");
                    else if(tree->type == IntegerArray)
                        fprintf(listing, "integer array\n");
                    break;
                case ArrK:
                    fprintf(listing,"Array Variable : %s\n", tree->attr.name);
                    break;
                 default:
                    fprintf(listing,"Unknown Expression\n");
                    break;
                }
        }
        else if (tree->nodekind==DeclK) 
        {
            switch (tree->kind.decl) {
                case FunK :
                    fprintf(listing, "Function Declare : ");
                    fprintf(listing, "%s\n", tree->attr.name);
                    break;
                case VarK :
                    fprintf(listing, "Variable Declare : ");
                    fprintf(listing, "%s\n", tree->attr.name);
                    break;
                case ArrVarK :
                    fprintf(listing, "Array Variable Declaration : ");
                    fprintf(listing,"%s\n", tree->attr.name);
                    break;
                case ArrParamK :
                    fprintf(listing, "Array Parameter : %s\n", tree->attr.name);
                    break;
                case ParamK :
                    fprintf(listing, "Parameter : ");
                    if (tree->attr.name != NULL) {
                        fprintf(listing, "%s\n", tree->attr.name);
                    } 
                    else {
                        fprintf(listing, "void\n");
                    }
                    break;
                default:
                    fprintf(listing, "Unknown Declaration\n");
                    break;
            }
        }
        else 
            fprintf(listing,"Unknown Node\n");
        for (i=0;i<MAXCHILDREN;i++)
            printTree(tree->child[i]);
        tree = tree->sibling;
    }
    UNINDENT;
}
