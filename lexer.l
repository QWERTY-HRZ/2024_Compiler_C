%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// 包含头文件
#include "AST.h"
#include "parser.tab.h"  

%}

%%

"int"               { return TOKEN_INT; }
"void"              { return TOKEN_VOID; }
"return"            { return TOKEN_RETURN; }
[0-9]+              { /* 此处用parser.y union中的数据类型 */yylval.Value = atoi(yytext); return CONSTANT; }
[A-Za-z_][A-Za-z0-9_]*   { yylval.Name=strdup(yytext); return IDENTIFIER; }

"="                 { return ASSIGN; }

"||"                { return LOG_OR; }
"&&"                { return LOG_AND; }
"|"                 { return BIT_OR; }
"^"                 { return BIT_XOR; }
"&"                 { return BIT_AND; }
"<"                 { return LL; }
"<="                { return LE; }
">"                 { return GG; }
">="                { return GE; }
"=="                { return EQ; }
"!="                { return NE; }
"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return MUL; }
"/"                 { return DIV; }
"%"                 { return REG; }

"!"                 { return LOG_NOT; }
"~"                 { return BIT_NOT; }

";"                 { return SEMIC; }
","                 { return COMMA; }
"("                 { return L_PAR; }
")"                 { return R_PAR; }
"{"                 { return L_BRA; }
"}"                 { return R_BRA; }

"println_int"       { return PRINT; }

[ \t\n]+            { /* 忽略空白符 */ }
.                   { printf("Unmatched Characters: %s\n", yytext); }

%%
int yywrap()    {
    return 1;
}
