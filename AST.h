/* AST.h */
#ifndef AST_H
#define AST_H
#define MAX_CHILD 16
#define MAX_IDENT 255

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 定义 AST 节点结构体
typedef struct astNode {
    char* type;
    char * name;
    int value;      
    struct astNode* children[MAX_CHILD];
    // 子节点数
    int child_count;  
} ASTNode;

typedef struct map_ident
{
	char * identifier_name;
	int stackorder;
}Map_Ident ;
Map_Ident varmap[100];

int Map_Order = 1;
int Map_Top = 0;

// 新节点 - 非终结符
ASTNode* NewNode_NT(char* type);
// 新节点 - 数据类型
ASTNode* NewNode_Type(char* type, char* name);
// 新节点 - 标识符
ASTNode* NewNode_Ident(char* name);
// 新节点 - 常量
ASTNode* NewNode_Const(int value);
// 新节点 - 运算符
ASTNode* NewNode_OP(char* name);
// 添加子节点，返回父节点
ASTNode* addChild(ASTNode* parent, ASTNode* child);
// test - 打印AST
void AST_Traverse(ASTNode* root, int depth);
// 判断两字符串是否相等 相等返回1 否则返回0
int Cmp_STR(char *str1, char *str2);

void printAST(ASTNode * root,int depth);
int Ident_Count(ASTNode * statements_node);
int Ident_Init(ASTNode * var_declare_list_node);
int Ident_Lookup(char * name);
void Pt_Global(ASTNode * program_node);
int Args_Init(ASTNode * arg_define_list);
void Deal_Func_Def(ASTNode * program_node);
void Deal_Statement(ASTNode * statements);
void Deal_Expression(ASTNode * expression);
void Call_Func(ASTNode * expression);
int Args_Push(ASTNode* arg_call_list);
void Var_Assign(ASTNode * var_declare_list);
#endif // AST_H
