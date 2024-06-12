%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// 引入头文件
#include "AST.h"

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
/* %type <ASTN> Ident_type */
%type <ASTN> Def_list
%type <ASTN> Def_others
%type <ASTN> Statement
%type <ASTN> statement
%type <ASTN> Declaration
%type <ASTN> Ident_dec
%type <ASTN> Ident_list
%type <ASTN> All_expression
%type <ASTN> Else_expression
%type <ASTN> Assignment_expression
%type <ASTN> return_statement
/* %type <ASTN> Function_call */
%type <ASTN> Call_list

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
        addChild($$, $4);
        addChild($$, $7);
    }
    | TOKEN_VOID IDENTIFIER L_PAR Def_list R_PAR L_BRA Statement R_BRA {
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "void"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        addChild($$, $4);
        addChild($$, $7);
    }
    | TOKEN_INT IDENTIFIER L_PAR R_PAR L_BRA Statement R_BRA {
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "int"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        // 函数参数列表为空时
        t = NewNode_NT("empty");
        addChild($$, t);
        addChild($$, $6);
    }
    | TOKEN_VOID IDENTIFIER L_PAR R_PAR L_BRA Statement R_BRA {
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "void"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        // 函数参数列表为空时
        t = NewNode_NT("empty");
        addChild($$, t);
        addChild($$, $6);
    }
    | TOKEN_INT IDENTIFIER L_PAR Def_list R_PAR L_BRA R_BRA {
        // 消除规约冲突！
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "int"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        addChild($$, $4);
        // 大括号内为空时
        t = NewNode_NT("empty");
        addChild($$, t);
    }
    | TOKEN_VOID IDENTIFIER L_PAR Def_list R_PAR L_BRA R_BRA {
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "void"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        addChild($$, $4);
        // 大括号内为空时
        t = NewNode_NT("empty");
        addChild($$, t);
    }
    | TOKEN_INT IDENTIFIER L_PAR R_PAR L_BRA R_BRA {
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "int"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        // 函数参数列表为空时
        t = NewNode_NT("empty");
        addChild($$, t);
        // 大括号内为空时
        t = NewNode_NT("empty");
        addChild($$, t);
    }
    | TOKEN_VOID IDENTIFIER L_PAR R_PAR L_BRA R_BRA {
        $$ = NewNode_NT("function_definition"); 
        ASTNode *t = NewNode_Type("type", "void"); 
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
        // 函数参数列表为空时
        t = NewNode_NT("empty");
        addChild($$, t);
        // 大括号内为空时
        t = NewNode_NT("empty");
        addChild($$, t);
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

/* Ident_type:
    TOKEN_INT {
        // 变量数据类型
        $$ = NewNode_NT("Ident_type");
        ASTNode *t = NewNode_Type("type", "int"); 
        addChild($$, t);
    }
    ; */

Def_list:
    {/* 函数参数列表，可为空 */}
    | Def_list COMMA Def_others {
        $$ = NewNode_NT("Def_list");
        addChild($$, $1);
        addChild($$, $3);
    }
    | Def_others {
        $$ = NewNode_NT("Def_list");
        addChild($$, $1);
    }
    ;

Def_others:
    TOKEN_INT IDENTIFIER {
        $$ = NewNode_NT("Def_others");
        ASTNode *t = NewNode_Type("type","int");
        addChild($$, t);
        t = NewNode_Ident($2);
        addChild($$, t);
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
    | PRINT L_PAR Else_expression R_PAR SEMIC {
        // 调用printf
        $$ = NewNode_NT("statement");
        ASTNode * t = NewNode_Type("keyword","print");
        addChild($$, t);
		addChild($$, $3);
    }
    | L_BRA statement R_BRA
	{
		$$ = NewNode_NT("statement");
		ASTNode * t = NewNode_NT("new_block");
		addChild($$, t);
		addChild($$, $2);
	}
    | SEMIC
	{
		$$ = NewNode_NT("statement");
		ASTNode * t = NewNode_NT("empty");
		addChild($$, t);
	}
    ;

Declaration:
    TOKEN_INT Ident_list SEMIC {
        /* 变量声明语句 */
        $$ = NewNode_NT("Declaration");
        ASTNode *t = NewNode_Type("type","int");
        addChild($$, t);
        addChild($$, $2);
    }
    ;

Ident_list:
    Ident_list COMMA Ident_dec {
        /* 声明列表 */
        $$ = NewNode_NT("Ident_list");
        addChild($$, $1);
        addChild($$, $3);
    }
    | Ident_dec {
        $$ = NewNode_NT("Ident_list");
        addChild($$, $1);       
    }
    ;

Ident_dec:
    IDENTIFIER ASSIGN Else_expression {
        /* 单个标识符声明 */
        $$ = NewNode_NT("Ident_dec");
        ASTNode *t = NewNode_Ident($1);
        addChild($$, t);
        t = NewNode_OP("=");
        addChild($$, t);
        addChild($$, $3);
    }
    | IDENTIFIER {
        $$ = NewNode_NT("Ident_dec");
        ASTNode *t = NewNode_Ident($1);
        addChild($$, t);        
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
    | IDENTIFIER L_PAR Call_list R_PAR {
        // 函数调用
        // 由于不存在能单独使用的函数 将调用移至普通表达式中
        $$ = NewNode_NT("Else_expression");
        ASTNode *t = NewNode_Ident($1);
        addChild($$, t);
        addChild($$, $3);  
    }
    | IDENTIFIER L_PAR R_PAR {
        $$ = NewNode_NT("Else_expression");
        ASTNode *t = NewNode_Ident($1);
        addChild($$, t);
        t = NewNode_NT("empty");
        addChild($$, t);
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

/* Function_call:
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
    ; */

Call_list:
    Call_list COMMA Else_expression {
        $$ = NewNode_NT("Call_list");
        addChild($$, $1);
        addChild($$, $3);
    }
    | Else_expression {
        $$ = NewNode_NT("Call_list");
        addChild($$, $1);
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
	/* 将bison指向文件头 */
    yyrestart(f); 
    /* 生成分析树 */
    yyparse();
	AST_Traverse(Root, 0);
	Main_Core(Root);
    return 0; 
}

void yyerror(char *s) {
	fflush(stdout);
}
