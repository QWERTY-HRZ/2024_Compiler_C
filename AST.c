#include "AST.h"

ASTNode* NewNode_NT(char* type) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->name = "";
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
    node->name = "";
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
    parent->children[parent->child_count] = child;
    parent->child_count++;
    // test
    printf("addChild! parent_type: %s, child_type: %s\n", parent->type, child->type);
    if(strcmp(child->name, "")) printf("child_name: %s\n", child->name);

    return (parent);
}

// 遍历 AST 并打印信息 提交时删去！！！
void AST_Traverse(ASTNode* root, int depth){
    for(int i=0;i<depth;i++)
		printf("- ");
	if(root == NULL)
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
		AST_Traverse(root->children[i],depth+1);
	return ;
}
// 判断两字符串是否相等
int Cmp_STR(char *str1, char *str2){
    return (strcmp(str1, str2));
}
