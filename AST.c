#include "AST.h"

ASTNode* NewNode_NT(char* type) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = 0;
    node->child_count = 0;
    return node;
}

ASTNode* NewNode_Type(char* type, char* name) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->name = strdup(name);
    node->value = 0;
    node->child_count = 0;
    return node;
}

ASTNode* NewNode_Ident(char* name){
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup("Ident");
    node->name = strdup(name);
    node->value = 0;
    node->child_count = 0;
    return node;    
}

ASTNode* NewNode_Const(int value){
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup("Const");
    node->value = value;
    node->child_count = 0;
    return node;        
}
ASTNode* NewNode_OP(char* name){
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup("OP");
    node->name = strdup(name);
    node->child_count = 0;
    return node;     
}

// 添加子节点到某个节点
ASTNode* addChild(ASTNode* parent, ASTNode* child) {
    if (parent != NULL && child != NULL) {
        // 不使用动态调整
        parent->children[parent->child_count] = child;
        parent->child_count++;
    }
    return (parent);
}

// 遍历 AST 并打印信息 提交时删去！！！
void AST_Traverse(ASTNode* root, int depth){
    for(int i=0;i<depth;i++)
		printf("- ");
	if(root==NULL)
	{
		printf("EMPTY\n");
		return ;
	}
	printf("%s",root->type);

	if(strcmp(root->type,"identifier")==0)
		printf(":%s",root->name);
	else if(strcmp(root->type,"op")==0)
		printf(":%s",root->name);
	else if(strcmp(root->type,"keyword")==0)
		printf(":%s",root->name);
	else if(strcmp(root->type,"constant")==0)
		printf(":%d",root->value);
	printf("\n");
	

	for(int i = 0 ; i < root->child_count ; i++)
        // 自上而下 按深度递归
		printAST(root->children[i],depth+1);
	return ;
}
