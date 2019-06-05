/* 把讨厌的注释去掉 */

%{


#include <string.h>
#include "ast.h"
#include "exp6.tab.h" /* 该文件中包含了词法分析所需的记号名等 */
#include "errormsg.h"

int charPos=1;

int yywrap(void)
{
  charPos=1;//当词法分析器结束扫描时，单词位置charPos复位。
  return 1;
}

/* 跟踪单词在字符流上的位置charPos。 */
void adjust(void)
{
  EM_tokPos=charPos;
  charPos+=yyleng;
}

%}

 
delim		[ \t \n]
ws			{delim}+
letter 		[A-Za-z]
digit		[0-9]
id			{letter}({letter}|{digit})*
int 		({digit})+
float 		({digit})*(\.{digit})({digit})*



/* 状态（或条件）定义可以定义在这里 
 * INITIAL是一个默认的状态，不需要定义
 */
%s COMMENT

%%

<INITIAL>"/*"						{BEGIN COMMENT;}
<COMMENT>"*/"						{BEGIN INITIAL;}
<COMMENT>.|\n						{;}



 /* ECHO是一个宏，相当于 fprintf(yyout, "%s", yytext)*/

<INITIAL>{ws} 				{adjust(); ;}
<INITIAL>PROGRAM 			{adjust(); adjust(); return (PROGRAM);}
<INITIAL>BEGIN 				{adjust(); return (BEGINN);}
<INITIAL>WHILE 				{adjust(); return (WHILE);}
<INITIAL>DO 				{adjust(); return (DO);}
<INITIAL>IF 				{adjust(); return (IF);}
<INITIAL>THEN 				{adjust(); return (THEN);}
<INITIAL>ELSE 				{adjust(); return (ELSE);}
<INITIAL>VAR 				{adjust(); return (VAR);}
<INITIAL>INTEGER 			{adjust(); return (INTEGER);}
<INITIAL>REAL 				{adjust(); return (REAL);}
<INITIAL>END         {adjust(); return (END);}

<INITIAL>{id} 				{adjust(); yylval.sval = String(yytext);return (ID);}
<INITIAL>{int} 				{adjust(); yylval.ival=atoi(yytext);return (INT);}
<INITIAL>{float} 			{adjust(); yylval.fval=atof(yytext);return (FLOAT);}

<INITIAL>"+" 				{adjust(); return (PLUS);}
<INITIAL>"-" 				{adjust(); return (MINUS);}
<INITIAL>"*" 				{adjust(); return (TIMES);}
<INITIAL>"/" 				{adjust(); return (DIVIDE);}

<INITIAL>"=" 				{adjust(); return (EQ);}
<INITIAL>"<>"         {adjust(); return (NEQ);}
<INITIAL>">" 				{adjust(); return (GT);}
<INITIAL>">="        {adjust(); return (GE);}
<INITIAL>"<" 				{adjust(); return (LT);}
<INITIAL>"<="         {adjust(); return (LE);}

<INITIAL>":=" 				{adjust(); return (ASSIGN);}
<INITIAL>":" 				{adjust(); return (COLON);}
<INITIAL>";" 				{adjust(); return (SEMICOLON);}
<INITIAL>"," 				{adjust(); return (COMMA);}
<INITIAL>"("        {adjust(); return LPAREN;}
<INITIAL>")"        {adjust(); return RPAREN;}
<INITIAL>"."         {adjust(); return (PERIOD);}

<INITIAL>. 				{printf("\nLEX:ERROR! c=%s\n", yytext);}

%%


void resetLexState(){
  BEGIN INITIAL;
}