%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// 引入头文件
#include "AST.h"
#include "parser.tab.h"
// 调用flex内置函数
int yylex(void);
void yyerror(char *);
void yyrestart(FILE *);
%}

/* 定义 - 数据类型集合 */
%union {
    int Value;
    char *Name;
    ASTNode *ASTN;    
}

%{
// 语法生成树 Root
ASTNode* Root;
// 调用flex的词法分析函数
extern int yylex();
void yyerror(char *s);
%}

/* 定义 - 非终结符数据类型，均为节点 */
%type <ASTN> program
%type <ASTN> function_definition
/* %type <ASTN> Func_type */
%type <ASTN> Ident_type
%type <ASTN> Def_list
%type <ASTN> Def_others
%type <ASTN> Statement
%type <ASTN> statement
%type <ASTN> Declaration
%type <ASTN> Opt_init
%type <ASTN> Ident_list
%type <ASTN> All_expression
%type <ASTN> Else_expression
%type <ASTN> Assignment_expression
%type <ASTN> return_statement
%type <ASTN> Function_call
%type <ASTN> Call_list
%type <ASTN> Call_others

/* 定义 - 终结符数据类型 */
/* 终结符 - 关键字 */
%token TOKEN_INT TOKEN_VOID TOKEN_RETURN PRINT
/* 终结符 - 常量 */
%token <Value> CONSTANT
/* 已有常量：整数序列 */
/* 终结符 - 标识符 */
%token <Name> IDENTIFIER
/* 终结符 - 运算符 */
/* 按优先级从低到高排列 */
%token ASSIGN   "="
%token LOG_OR   "||"
%token LOG_AND  "&&"
%token BIT_OR   "|"
%token BIT_XOR  "^"
%token BIT_AND  "&"
%token LL       "<"
%token LE       "<="
%token GG       ">"
%token GE       ">="
%token EQ       "=="
%token NE       "!="
%token PLUS     "+"
%token MINUS    "-"
%token MUL      "*"
%token DIV      "/"
%token REG      "%"
%token LOG_NOT  "!"
%token BIT_NOT  "~"
/* 负号 仅有优先级作用 */
%token NEG 
/* 终结符 - 标点符号 */
%token SEMIC    ";"
%token COMMA    ","
%token L_PAR    "("
%token R_PAR    ")"
%token L_BRA    "{"
%token R_BRA    "}"
/* 定义 - 运算符优先级 */
%right ASSIGN
/* 二元运算符 */
%left LOG_OR
%left LOG_AND
%left BIT_OR
%left BIT_XOR
%left BIT_AND
%left EQ NE
%left LL LE GG GE
%left PLUS MINUS
%left MUL DIV REG
/* 一元运算符 */
%right NEG LOG_NOT BIT_NOT 

/* 定义 - 开始标志 */
%start program
%%
program:
    function_definition {
        $$ = NewNode_NT("program");
        // test
        printf("function_def\n");        
        addChild($$, $1);
        Root = $$;       
    }
    | program function_definition { 
        $$ = NewNode_NT("program");
        addChild($$, $1); 
        addChild($$, $2);
        Root = $$; 
    }
    ;

function_definition:
    TOKEN_INT IDENTIFIER L_PAR Def_list R_PAR L_BRA Statement R_BRA {
        // 消除规约冲突！
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "int"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        // 对若产生式为空 填入空节点
        if($4 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $4);
        addChild($$, $7);
    }
    | TOKEN_VOID IDENTIFIER L_PAR Def_list R_PAR L_BRA Statement R_BRA {
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "void"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        if($4 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $4);
        addChild($$, $7);
    }
    ;

/* Func_type:
    TOKEN_INT {
        $$ = NewNode_NT("Func_type");
        ASTNode *t = NewNode_Type("type", "int"); 
        addChild($$, t);
    }
    | TOKEN_VOID {
        $$ = NewNode_NT("Func_type");
        ASTNode *t = NewNode_Type("type", "void"); 
        addChild($$, t);        
    }
    ; */

Ident_type:
    TOKEN_INT {
        /* 变量数据类型 */
        $$ = NewNode_NT("Ident_type");
        ASTNode *t = NewNode_Type("type", "int"); 
        addChild($$, t);
    }
    ;

Def_list:
    {/* 函数参数列表，可为空 */}
    | Ident_type IDENTIFIER Def_others {
        $$ = NewNode_NT("Def_list");
        addChild($$, $1);
        ASTNode *t = NewNode_Ident($2);
        addChild($$, t);
        if($3 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $3);
    }
    ;

Def_others:
    {/* 函数其他参数，可为空 */}
    | COMMA Ident_type IDENTIFIER Def_others {
        $$ = NewNode_NT("Def_others");
        addChild($$, $2);
        ASTNode *t = NewNode_Ident($3);
        addChild($$, t);
        if($4 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $4);
    }
    ;

Statement:
    statement {
        $$ = NewNode_NT("Statement");
        addChild($$, $1);
    }
    | Statement statement {
        $$ = NewNode_NT("Statement");
        addChild($$, $1);
        addChild($$, $2);
    }
    ;
statement:
    Declaration {
        // 声明语句
        $$ = NewNode_NT("statement");
        addChild($$, $1);
    }
    | Assignment_expression {
        // 赋值表达式
        $$ = NewNode_NT("statement");
        addChild($$, $1);
    }
    | return_statement {
        // 返回语句
        $$ = NewNode_NT("statement");
        addChild($$, $1);
    }
    | Function_call {
        // 函数调用
        $$ = NewNode_NT("statement");
        addChild($$, $1);
    }
    | PRINT L_PAR Else_expression R_PAR SEMIC {
        $$ = NewNode_NT("statement");
        ASTNode * t = NewNode_Type("keyword","print");
        addChild($$, t);
		addChild($$, $3);
    }
    ;

Declaration:
    Ident_type IDENTIFIER Opt_init Ident_list SEMIC {
        /* 变量声明语句 */
        $$ = NewNode_NT("Declaration");
        addChild($$, $1);
        ASTNode *t = NewNode_Ident($2);
        addChild($$, t);
        if($3 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $3);
        if($4 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $4);                
    }
    ;

Opt_init:
    {/* 初始化赋值，可为空 */}
    | ASSIGN Else_expression {
        $$ = NewNode_NT("Opt_init");
        ASTNode *t = NewNode_OP("=");
        addChild($$, t);
        addChild($$, $2);
    }
    ;

Ident_list:
    {/* 标识符列表，可为空 */}
    | COMMA IDENTIFIER Opt_init Ident_list {
        $$ = NewNode_NT("Ident_list");
        ASTNode *t = NewNode_Ident($2);
        addChild($$, t);
        if($3 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $3);
        if($4 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $4);        
    }
    ;

All_expression:
    Else_expression {
        $$ = NewNode_NT("All_expression");
        addChild($$, $1);
    }
    | Assignment_expression {
        /* 分离赋值表达式 避免规约冲突 */
        $$ = NewNode_NT("All_expression");
        addChild($$, $1);
    }
    ;

Assignment_expression:
    IDENTIFIER ASSIGN All_expression SEMIC {
        $$ = NewNode_NT("Assignment_expression");
        ASTNode *t = NewNode_Ident($1);
        addChild($$, t);
        t = NewNode_OP("=");
        addChild($$, t);
        addChild($$, $3);
    }
    ;

Else_expression:
    Else_expression LOG_OR Else_expression {
        // 由于形式一样，之后操作都一样！
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("||");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression LOG_AND Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("&&");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression BIT_OR Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("|");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression BIT_XOR Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("^");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression BIT_AND Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("&");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression LL Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("<");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression LE Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("<=");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression GG Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP(">");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression GE Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP(">=");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression EQ Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("==");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression NE Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("!=");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression PLUS Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("+");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression MINUS Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("-");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression MUL Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("*");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression DIV Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("/");
        addChild($$, t);
        addChild($$, $3);
    }
    | Else_expression REG Else_expression {
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
        ASTNode *t = NewNode_OP("%");
        addChild($$, t);
        addChild($$, $3);
    }
    | LOG_NOT Else_expression {
        $$ = NewNode_NT("Else_expression");
        ASTNode *t = NewNode_OP("!");
        addChild($$, t);
        addChild($$, $2);
    }
    | BIT_NOT Else_expression {
        $$ = NewNode_NT("Else_expression");
        ASTNode *t = NewNode_OP("~");
        addChild($$, t);
        addChild($$, $2);
    }
    | MINUS Else_expression %prec NEG {
        // 使用%prec 指定此时优先使用负号
        $$ = NewNode_NT("Else_expression");
        ASTNode *t = NewNode_OP("-");
        addChild($$, t);
        addChild($$, $2);
    }     
    | L_PAR All_expression R_PAR {
        // 括号中可为任意表达式！
        $$ = NewNode_NT("Else_expression");
        addChild($$, $2);
    }
    | IDENTIFIER {
        $$ = NewNode_NT("Else_expression");
        ASTNode *t = NewNode_Ident($1);
        addChild($$, t);
    }
    | CONSTANT {
        $$ = NewNode_NT("Else_expression");
        ASTNode *t = NewNode_Const($1);
        addChild($$, t);
    }
    | Function_call {
        // 函数调用
        $$ = NewNode_NT("Else_expression");
        addChild($$, $1);
    }
    ;

return_statement:
    TOKEN_RETURN All_expression SEMIC {
        // 其他返回语句
        $$ = NewNode_NT("return_statement");
        ASTNode *t = NewNode_Type("keyword","return");
        addChild($$, t);
        addChild($$, $2);
    }
    | TOKEN_RETURN SEMIC{
        // void返回语句
        $$ = NewNode_NT("return_statement");
        ASTNode *t = NewNode_Type("keyword","return");
        addChild($$, t);
    }
    ;

Function_call:
    IDENTIFIER L_PAR Call_list R_PAR {
        $$ = NewNode_NT("Function_call");
        ASTNode *t = NewNode_Ident($1);
        addChild($$, t);
        if($3 == NULL) {
            t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $3);  
    }
    ;

Call_list:
    {/* 调用参数列表，可为空 */}
    | All_expression Call_others {
        $$ = NewNode_NT("Call_list");
        addChild($$, $1);
        if($2 == NULL) {
            ASTNode *t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $2);
    }
    ;

Call_others:
    {/* 调用其他参数，可为空 */}
    | COMMA All_expression Call_others {
        $$ = NewNode_NT("Call_others");
        addChild($$, $2);
        if($3 == NULL) {
            ASTNode *t = NewNode_NT("empty");
            addChild($$, t);
        }
        else addChild($$, $3);        
    }
    ;

%%
/* main函数 */
int main(int argc, char** argv)
{	
	Root = NewNode_NT("Root");
	if (argc <= 1) return 1; 
    /* 读取文件 */
    FILE* f = fopen(argv[1], "r");
     
    if (!f) return 1; 
	/* 将bison指向文件头 */
    yyrestart(f); 
    yyparse();
    printf("root_child = %d\n",Root->child_count);
	AST_Traverse(Root, 0);
	printf(".intel_syntax noprefix\n");
	printf("\n.data\nformat_str:\n.asciz \"%%d\\n\"\n.extern printf\n");
	/* if(strcmp(Root->type,"program")==0)
		if(main_exsist(Root)==1)
		{	
			printGlobalName(Root);
			printf(".text\n\n");
			func_define_list(Root);
		}
		else printf(".global main\n.text\n\n#ASTerror\nmain:\npush ebp\nmov ebp, esp\nsub esp, 4\nleave\nret\n");
	else printf(".global main\n.text\n\n#ASTerror\nmain:\npush ebp\nmov ebp, esp\nsub esp, 4\nleave\nret\n"); */
    return 0; 
}

void yyerror(char *s) {
	fflush(stdout);
}
