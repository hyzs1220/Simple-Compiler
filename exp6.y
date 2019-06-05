%{

#include <stdio.h>
#include "ast.h"
#include "errormsg.h"


int yylex(void);


/* 该函数显示错误信息s，显示时包含了错误发生的位置。*/
void yyerror(char *s)
{
 EM_error(EM_tokPos, "%s", s);
}

/* 存放抽象语法树中 "程序" 数据结构的变量 */
a_prog program = NULL;

%}


 /* 定义属性值栈的类型，后续实验中如果需要存储不同类型的属性值，则需要修改此处 */
%union {
	int ival;
	double fval;
	string sval;

	a_prog program;


	a_dec_list var_explain_list;
	a_var_list var_list;
	a_stm_list sentence_list;
	a_stm sentence, assign_sentence, if_sentence, while_sentence, com_sentence;

	a_bexp relational_expr;
	a_exp term, factor, arithmetic_expr,number;
	a_bop RELOP;

	ttype ttype1;
}

 /* 定义各个终结符，以及他们的属性值的类型，后续实验中如果需要存储不同类型的属性值，则需要修改此处 */
%token <sval> ID /* id */
%token <ival> INT  /*整型数*/
%token <fval> FLOAT /*浮点数*/
%token INTEGER REAL  /*两种类型名：整型、实型*/
%token 
  COMMA COLON SEMICOLON LPAREN RPAREN PERIOD /* 符号 , : ; ( ) . */
  PROGRAM BEGINN END VAR IF WHILE DO   /* 关键字：PROGRAM BEGIN END VAR IF WHILE DO */
  THEN ELSE /* 关键字：THEN ELSE */
  ASSIGN EQ NEQ LT LE GT GE /* 符号 :=	 =  <>  <  <=  >  >= */
  PLUS MINUS TIMES DIVIDE /* 符号 + = * / */
%start program /* 开始符号为program */

  /* 定义各个非终结符的属性值类型，最后一个实验可能需要修改此处  */
%type <program> program
// %type <var_explain> var_explain 
%type <var_explain_list> var_explain_list var_explain
%type <var_list> var_list
%type <sentence_list> sentence_list
%type <sentence> sentence
%type <assign_sentence> assign_sentence
%type <if_sentence> if_sentence
%type <while_sentence> while_sentence
%type <com_sentence> com_sentence
%type <relational_expr> relational_expr
%type <term> term
%type <factor> factor
%type <number> number
%type <RELOP> RELOP
%type <arithmetic_expr> arithmetic_expr
%type <ttype1> ttype1


%left PLUS MINUS
%left TIMES DIVIDE




%debug /* 允许跟踪错误 */

%%


program : PROGRAM ID SEMICOLON var_explain BEGINN sentence_list END PERIOD
			{program = A_Prog(EM_tokPos, $2, $4, $6);}
	 ;

var_explain : VAR var_explain_list
				{$$ = $2;}

var_explain_list : var_list COLON ttype1 SEMICOLON
					{$$ = A_DecList(A_VarDec(EM_tokPos, $1, $3), NULL);}
				 | var_list COLON ttype1 SEMICOLON var_explain_list
				 	{$$ = A_DecList(A_VarDec(EM_tokPos, $1, $3), $5);}
				 ;

ttype1 : INTEGER {$$ = T_int;}
	 | REAL {$$ = T_real;}
	 ;

var_list : ID	{$$ = A_VarList(A_Id(EM_tokPos, $1), NULL);}
		 | ID COMMA var_list	{$$ = A_VarList(A_Id(EM_tokPos, $1), $3);}
		 ;

sentence_list : sentence {$$ = A_StmList( $1, NULL );}
			 | sentence SEMICOLON sentence_list {$$ = A_StmList( $1, $3 );}
			 ;

sentence : assign_sentence { $$ = $1;}
		 | if_sentence { $$ = $1;}
		 | while_sentence { $$ = $1;}
		 | com_sentence { $$ = $1;}
		 ;

assign_sentence : ID ASSIGN arithmetic_expr
					{$$ = A_Assign(EM_tokPos, A_Id(EM_tokPos, $1),  $3);}
		 ;

if_sentence : IF relational_expr THEN sentence ELSE sentence
				{$$ = A_If(EM_tokPos, $2, $4, $6);}
		 ;

while_sentence : WHILE relational_expr DO sentence
				{$$ = A_While(EM_tokPos, $2, $4);}
		 ;

com_sentence : BEGINN sentence_list END
				{$$ = A_Seq(EM_tokPos, $2);}
		 ;

arithmetic_expr : term
					{$$ = $1;}
		 | arithmetic_expr PLUS term
		 	{$$ = A_OpExp(EM_tokPos, A_plusOp, $1, $3);}
		 | arithmetic_expr MINUS term
		 	{$$ = A_OpExp(EM_tokPos, A_minusOp, $1, $3);}
		 ;

term : factor
			{$$ = $1;}
		 | term TIMES factor
		 	{$$ = A_OpExp(EM_tokPos, A_timesOp, $1, $3);}
		 | term DIVIDE factor
		 	{$$ = A_OpExp(EM_tokPos, A_divideOp, $1, $3);}
		 ;

factor : ID
			{$$ = A_VarExp(EM_tokPos, A_Id(EM_tokPos, $1));}
		 | number
		 	{$$ = $1;}
		 | LPAREN arithmetic_expr RPAREN
		 	{$$ = $2;}
		 ;

relational_expr : arithmetic_expr RELOP arithmetic_expr
			{$$ = A_BExp(EM_tokPos, $2, $1, $3);}
		 ;

number : INT
			{$$ = A_IntExp(EM_tokPos, $1);}
		| FLOAT
			{$$ = A_RealExp(EM_tokPos, $1);}
		;

RELOP : EQ {$$ = A_eqOp;}
		| NEQ {$$ = A_neqOp;}
		| LT {$$ = A_ltOp;}
		| LE {$$ = A_leOp;}
		| GT {$$ = A_gtOp;}
		| GE {$$ = A_geOp;}
		;

