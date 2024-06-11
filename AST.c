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
    // // test
    // printf("addChild! parent_type: %s, child_type: %s\n", parent->type, child->type);
    // if(!Str_isEqual(child->name, "")) printf("child_name: %s\n", child->name);
    // if(Str_isEqual(child->type, "Const")) printf("Const child_value: %d\n", child->value);
    return (parent);
}

// 遍历 AST 并打印信息 提交时删去！！！
void AST_Traverse(ASTNode* root, int depth){
    for(int i=0;i<depth;i++)
		printf("- ");
	if(root == NULL)
	{
		printf("EMPTY!\n");
		return ;
	}
	printf("%s",root->type);

	if(Str_isEqual(root->type,"identifier"))
		printf(":%s",root->name);
	else if(Str_isEqual(root->type,"op"))
		printf(":%s",root->name);
	else if(Str_isEqual(root->type,"keyword"))
		printf(":%s",root->name);
	else if(Str_isEqual(root->type,"constant"))
		printf(":%d",root->value);
	printf("\n");
	

	for(int i = 0 ; i < root->child_count ; i++)
        // 自上而下 按深度递归
		AST_Traverse(root->children[i],depth+1);
	return ;
}

int Ident_Count(ASTNode * statements_node)
{
	int var_num=0;
	ASTNode * statement=statements_node->children[0];
	if(Str_isEqual(statement->type,"statements"))
	{
		var_num=Ident_Count(statements_node->children[0]);
		statement=statements_node->children[1];
	}
	ASTNode * p=statement->children[0];
	if(Str_isEqual(p->type,"type"))
		return var_num+Ident_Init(statement->children[1]);
	else if(Str_isEqual(p->type,"new_block"))
	{
		return var_num+Ident_Count(statement->children[1]);
	}	
	else
		return var_num;
	
}
int Ident_Init(ASTNode * var_declare_list_node)
{
	int var_num=0;
	ASTNode * var_declare_node=var_declare_list_node->children[0];
	if(Str_isEqual(var_declare_node->type,"var_declare_list"))
	{
		var_num=Ident_Init(var_declare_list_node->children[0]);
		var_declare_node=var_declare_list_node->children[1];
	}
	Map_Ident temp;
	ASTNode * p=var_declare_node->children[0];
	temp.identifier_name=strdup(p->name);
	temp.stackorder=Map_Order;
	varmap[Map_Top]=temp;
	Map_Order++;
	Map_Top++;
	return var_num+1;

}
void Deal_Func_Def(ASTNode * program_node)
{
	ASTNode * func_define_node=program_node->children[0];
	if(Str_isEqual(func_define_node->type,"program"))
	{
		Deal_Func_Def(func_define_node);
		func_define_node=program_node->children[1];
	}
	Map_Order=1;
	Map_Top=0;
	int num=0;
	if(Str_isEqual(func_define_node->children[3]->type,"empty"))
		num=Ident_Count(func_define_node->children[3]);
	ASTNode * identifier=func_define_node->children[1];
	printf("#localvar_num: %d\n",num);
	if(Str_isEqual(func_define_node->children[2]->type,"empty"))
	{

		int arg_num=Args_Init(func_define_node->children[2]);
		printf("#args_num:%d \n",arg_num-2);
	}
	for(int i=0;i<Map_Top;i++)
		printf("#%s %d\n",varmap[i].identifier_name,varmap[i].stackorder);
	ASTNode * namenode =func_define_node->children[1];	
	printf("%s:\n",namenode->name);
	printf("push ebp\nmov ebp, esp\nsub esp, %d\n",num*4+4);
	if(Str_isEqual(func_define_node->children[3]->type,"empty"))
		Deal_Statement(func_define_node->children[3]);
	printf("leave\nret\n");
	printf("\n\n");
	
}
int main_exsist(ASTNode * program_node)
{
	ASTNode * func_define_node=program_node->children[0];
	int exsist=0;
	if(Str_isEqual(func_define_node->type,"program"))
	{
		exsist=main_exsist(func_define_node);
		func_define_node=program_node->children[1];
	}
	if(Str_isEqual(func_define_node->children[1]->name,"main"))
		return 1;
	else
		return exsist;
	
	
}
int Args_Init(ASTNode * arg_define_list)
{
	int arg_num=2;
	ASTNode * arg_define_node=arg_define_list->children[0];
	if(Str_isEqual(arg_define_node->type,"arg_define_list"))
	{
		arg_num=Args_Init(arg_define_node);
		arg_define_node=arg_define_list->children[1];	
	}
	Map_Ident temp;
	ASTNode * p=arg_define_node->children[1];
	temp.identifier_name=strdup(p->name);
	temp.stackorder=-arg_num;
	varmap[Map_Top]=temp;
	Map_Top++;
	return ++arg_num;
}
void Deal_Statement(ASTNode * statements)
{
	ASTNode * statement_node=statements->children[0];
	if(Str_isEqual(statement_node->type,"statements"))
	{
		Deal_Statement(statement_node);
		statement_node=statements->children[1];
	}
	ASTNode * temp=statement_node->children[0];
	if(Str_isEqual(temp->type,"type"))
	{
		Var_Assign(statement_node->children[1]);
	}
	else if(Str_isEqual(temp->type,"new_block"))
	{
		Deal_Statement(statement_node->children[1]);
	}
	else if (Str_isEqual(temp->type,"keyword"))
	{
		if(Str_isEqual(temp->name,"return"))
		{
			if(!Str_isEqual(statement_node->children[1]->type,"empty"))
			{
				Deal_Expression(statement_node->children[1]);
				printf("pop eax\n");
			}
		}
		else if(Str_isEqual(temp->name,"print"))
		{
			Deal_Expression(statement_node->children[1]);
			printf("push offset format_str\ncall printf\nadd esp, 8\n");
		}
	}
	else if (Str_isEqual(temp->type,"identifier"))
	{
		ASTNode * temp2=statement_node->children[1];
		if(Str_isEqual(temp2->type,"op"))
		{
			Deal_Expression(statement_node->children[2]);
			printf("pop eax\n");
			int _stack_order=Ident_Lookup(temp->name);
			if(_stack_order >=0 )
				printf("mov DWORD PTR [ ebp - %d ] , eax\n",4*_stack_order);
			else
				printf("mov DWORD PTR [ ebp + %d ] , eax\n",-4*_stack_order);
		}
		else
		{
			Call_Func(statement_node);
		}
	}
}
int Ident_Lookup(char * name)
{
	for(int i=0;i<Map_Top;i++)
	{
		if(Str_isEqual(name,varmap[i].identifier_name))
			return varmap[i].stackorder;
	}
	return 1;
}
void Deal_Expression(ASTNode * expression)
{
    // 二元运算式
	if(expression->child_count==3)
	{
		Deal_Expression(expression->children[0]);
		Deal_Expression(expression->children[2]);
		ASTNode * opnode=expression->children[1];
		printf("pop ebx\npop eax\n");
		
		if(Str_isEqual(opnode->name,"&"))
		{
			printf("and eax , ebx\n");		
		}
		else if(Str_isEqual(opnode->name,"|"))
		{
			printf("or eax , ebx\n");		
		}
		else if(Str_isEqual(opnode->name,"^"))
		{
			printf("xor eax , ebx\n");		
		}
		else if(Str_isEqual(opnode->name,"=="))
		{
			printf("cmp eax , ebx\nsete cl\nmovzx eax , cl\n");		
		}
		else if(Str_isEqual(opnode->name,"!="))
		{
			printf("cmp eax , ebx\nsetne cl\nmovzx eax , cl\n");		
		}
		else if(Str_isEqual(opnode->name,"<="))
		{
			printf("cmp eax , ebx\nsetle cl\nmovzx eax , cl\n");		
		}
		else if(Str_isEqual(opnode->name,">="))
		{
			printf("cmp eax , ebx\nsetge cl\nmovzx eax , cl\n");		
		}
		else if(Str_isEqual(opnode->name,"<"))
		{
			printf("cmp eax , ebx\nsetl cl\nmovzx eax , cl\n");		
		}
		else if(Str_isEqual(opnode->name,">"))
		{
			printf("cmp eax , ebx\nsetg cl\nmovzx eax , cl\n");		
		}
		else if(Str_isEqual(opnode->name,"&&"))
		{
			printf("test eax, eax\nsetnz al\ntest ebx, ebx\nsetnz bl\nand al, bl\nmovzx eax, al\n"); 		
		}
		else if(Str_isEqual(opnode->name,"||"))
		{
			printf("test eax, eax\nsetnz al\ntest ebx, ebx\nsetnz bl\nor al, bl\nmovzx eax, al\n"); 
		}
        // 111
        else if(Str_isEqual(opnode->name,"+"))
		{
			printf("add eax , ebx\n");		
		}
		else if(Str_isEqual(opnode->name,"-"))
		{
			printf("sub eax , ebx\n");		
		}
		else if(Str_isEqual(opnode->name,"*"))
		{
			printf("imul eax , ebx\n");		
		}
		else if(Str_isEqual(opnode->name,"/"))
		{
			printf("cdq\nidiv ebx\n");		
		}
		else if(Str_isEqual(opnode->name,"%"))
		{
			printf("cdq\nidiv ebx\nmov eax , edx\n");		
		}
		printf("push eax\n");
	}
	else if(expression->child_count==2)
	{
		ASTNode * temp=expression->children[0];
		if(Str_isEqual(temp->type,"op")) //op exp
		{
			Deal_Expression(expression->children[1]);
			printf("pop eax\n");
			if(Str_isEqual(temp->name,"!"))
			{
				printf("cmp eax , 0\nsete cl\nmovzx eax , cl\n");
			}
			else if(Str_isEqual(temp->name,"-"))
			{
				printf("neg eax\n");
			}
			else if(Str_isEqual(temp->name,"~"))
			{
				printf("not eax\n");
			}
			printf("push eax\n");
		}
		else //call func
		{
			Call_Func(expression);
			printf("push eax\n");
		}
	}
	else
	{
		ASTNode * temp=expression->children[0];
		if(Str_isEqual(temp->type,"constant"))
		{
			printf("push %d\n",temp->value);
		}
		else if(Str_isEqual(temp->type,"expression"))
		{
			Deal_Expression(temp);	
		}
		else
		{
			int _stack_order=Ident_Lookup(temp->name);
			if(_stack_order >=0 )
				printf("mov eax , DWORD PTR [ ebp - %d ]\n",4*_stack_order);
			else
				printf("mov eax , DWORD PTR [ ebp + %d ]\n",-4*_stack_order);
			printf("push eax\n");
		}
	}
}
void Call_Func(ASTNode * expression)
{
	if(Str_isEqual(expression->children[1]->type,"empty"))
	{
		ASTNode * temp=expression->children[0];
		printf("call %s\n",temp->name);
		return ;
	}
	int arg_num=Args_Push(expression->children[1]);
	ASTNode * temp=expression->children[0];
	printf("call %s\n",temp->name);
	printf("add esp , %d\n",4*arg_num);
}
int Args_Push(ASTNode* arg_call_list)
{
	int arg_num=0;
	ASTNode * p=arg_call_list;
	while(1)
	{
		if(Str_isEqual(p->children[0]->type,"arg_call_list"))
		{

			ASTNode * arg_call_node=p->children[1];
			Deal_Expression(arg_call_node);
			p=p->children[0];
			arg_num++;
		}
		else
		{
			ASTNode * arg_call_node=p->children[0];
			Deal_Expression(arg_call_node);
			arg_num++;
			break;
		}
	}
	
	return arg_num;
}
void Var_Assign(ASTNode * var_declare_list)
{
	ASTNode * var_declare_node=var_declare_list->children[0];
	if(Str_isEqual(var_declare_node->type,"var_declare_list"))
	{
		Var_Assign(var_declare_node);
		var_declare_node=var_declare_list->children[1];
	}
	ASTNode * identifier=var_declare_node->children[0];
	int _stack_order=Ident_Lookup(identifier->name);
	
	if(var_declare_node->child_count==1)
	{	
		if(_stack_order >=0 )
		printf("mov DWORD PTR [ ebp - %d ] , 0\n",4*_stack_order);
		else
		printf("mov DWORD PTR [ ebp + %d ] , 0\n",-4*_stack_order);
	}	
	else
	{
		Deal_Expression(var_declare_node->children[2]);
		printf("pop eax\n");
		if(_stack_order>=0 )
		printf("mov DWORD PTR [ ebp - %d ] , eax\n",4*_stack_order);
		else
		printf("mov DWORD PTR [ ebp + %d ] , eax\n",-4*_stack_order);
	}
}

int Str_isEqual(char *str1, char *str2){
    return (!strcmp(str1, str2));
}

void Pt_Global(ASTNode * program_node)
{
	ASTNode * func_define_node=program_node->children[0];
	if(strcmp(func_define_node->type,"program")==0)
	{
		Pt_Global(func_define_node);
		func_define_node=program_node->children[1];
	}
	printf(".global %s\n",func_define_node->children[1]->name);
}