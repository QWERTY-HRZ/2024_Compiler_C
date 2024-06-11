/* AST.h */
#ifndef AST_H
#define AST_H
#define MAX_NUM 10

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 定义 AST 节点结构体
typedef struct astNode {
    char* type;
    char * name;
    int value;      
    struct astNode* children[MAX_NUM];
    // 子节点数
    int child_count;  
} ASTNode;

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

#endif // AST_H
