%option noyywrap

%x MULTILINE_COMMENT
%x SINGLELINE_COMMENT
%x STRING


%{
#include<iostream>
#include<stdio.h>
#include<stdlib.h>
#include "symboltable.cpp"
#include <fstream>
#include<bits/stdc++.h>

SymbolTable st(7);
ofstream tokenFile("1705042_token.txt");


int line_count=1;
int error_count = 0;
int line_offset = 0;
string stringInput = "";
string logFileStringOutput = "";
string commentInput = "";

string getUpper(string input){
	string su = input;
	transform(su.begin(), su.end(), su.begin(), ::toupper);

	return su;
}

%}

digit [0-9]
CHARACTERS [a-zA-Z]
NORMAL_CHARECTERS [^\n\t\r\a\f\'\b\v\0\\]{1}
MULTI_LINE_COMMENT [/][*]+[^\0]*[*]+[/]
KEYWORDS if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue
FLOAT {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]{0,30}
RELOP <|<=|>|>=|==|!=
INCOP ("++"|"--")
ESCAPE_CHAR \\[abfnrtv0]
TOO_MANY_DECIMAL_ERROR {digit}*(\.{digit}+)(\.{digit}+)+
INVALID_PREFIX_ON_IDENTIFIER {digit}+[a-zA-Z_][a-zA-Z0-9_]*
INVALID_SUFFIX_ON_NUMERIC_CONSTANT {digit}+{NORMAL_CHARECTERS}+
MULTI_CHARECTER_CONST_ERROR '({NORMAL_CHARECTERS}+{NORMAL_CHARECTERS}+)'
UNTERMINATED_CHARECTER \'(({ESCAPE_CHAR}|{NORMAL_CHARECTERS})*|\\\')
EMPTY_CHARECTER_CONSTANT ''
NEWLINE (\r\n|\n)
ILL_FORMED_NUMBER_ONE {digit}*(\.{digit}+)*(E[+-]?{digit}+\.{digit}*)+
ILL_FORMED_NUMBER_TWO {digit}*\.{digit}*[eE]+(({digit}+{CHARACTERS}+)|({CHARACTERS}+{digit}+))+
ILL_FORMED_NUMBER_THREE {digit}*\.{CHARACTERS}+{NORMAL_CHARECTERS}*
ILL_FORMED_NUMBER_FOUR {digit}*\.{digit}*({CHARACTERS}+{CHARACTERS}+)+{NORMAL_CHARECTERS}*
ILL_FORMED_NUMBER ({ILL_FORMED_NUMBER_ONE}|{ILL_FORMED_NUMBER_TWO}|{ILL_FORMED_NUMBER_THREE}|{ILL_FORMED_NUMBER_FOUR})

%%
[ \t\v]+ {}
{NEWLINE} {line_count++;}

{KEYWORDS} {
		//cout << "55 :in keywords" << endl;
		tokenFile << "<" << getUpper(yytext) << "> " ;
		logFile << endl <<"Line no. " << line_count << ": Token <" << getUpper(yytext) << "> Lexeme " << yytext << " found" << endl;
	   }

{digit}+ {
	   //cout << "61 " << endl;
	   tokenFile << "<CONST_INT, " << yytext << "> " ;
	   logFile << endl <<"Line no. " << line_count << ": Token <CONST_INT> Lexeme " << yytext << " found" << endl;
	   if(st.Insert(yytext, "CONST_INT")){
	   	st.printAllScopeTable();
	   }
	}

{FLOAT}  {
	    //cout << "70 " << endl;
	    tokenFile << "<CONST_FLOAT, " << yytext << "> " ;
	    logFile << endl <<"Line no. " << line_count << ": Token <CONST_FLOAT> Lexeme " << yytext << " found" << endl;
	    if(st.Insert(yytext, "CONST_FLOAT")){
	    	st.printAllScopeTable();
	    }
	 }

[+-] {
	//cout << "79 " << endl;
     	tokenFile << "<ADDOP, " << yytext << "> " ;
     	logFile << endl <<"Line no. " << line_count << ": Token <ADDOP> Lexeme " << yytext << " found" << endl;
     }
[*/%] {
	//cout << "84 " << endl;
      	tokenFile << "<MULOP, " << yytext << "> " ;
     	logFile << endl <<"Line no. " << line_count << ": Token <MULOP> Lexeme " << yytext << " found" << endl;
      }

{INCOP} {
		//cout << "90 " << endl;
		tokenFile << "<INCOP, " << yytext << "> " ;
		logFile << endl <<"Line no. " << line_count << ": Token <INCOP> Lexeme " << yytext << " found" << endl;
	}


{RELOP} {
		//cout << "97 " << endl;
	    tokenFile << "<RELOP, " << yytext << "> " ;
	    logFile << endl <<"Line no. " << line_count << ": Token <RELOP> Lexeme " << yytext << " found" << endl;
        }

"=" {
	//cout << "103 " << endl;
	tokenFile << "<ASSIGNOP, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <ASSIGNOP> Lexeme " << yytext << " found" << endl;
    }
("&&"|"||") {
		//cout << "108 " << endl;
		tokenFile << "<LOGICOP, " << yytext << "> " ;
		logFile << endl <<"Line no. " << line_count << ": Token <LOGICOP> Lexeme " << yytext << " found" << endl;
	     }

"!" {
	//cout << "114 " << endl;
	tokenFile << "<NOT, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <NOT> Lexeme " << yytext << " found" << endl;
    }

"(" {
	//cout << "120 " << endl;
	tokenFile << "<LPAREN, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <LPAREN> Lexeme " << yytext << " found" << endl;
    }
")" {
	//cout << "125 " << endl;
	tokenFile << "<RPAREN, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <RPAREN> Lexeme " << yytext << " found" << endl;
    }
"{" {
	//cout << "130 " << endl;
	tokenFile << "<LCURL, " << yytext << "> " ;
	logFile << endl << "Line no. " << line_count << ": Token <LCURL> Lexeme " << yytext << " found" << endl;
	st.enterScope();
    }
"}" {
	//cout << "136 " << endl;
	tokenFile << "<RCURL, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <RCURL> Lexeme " << yytext << " found" << endl;
	st.exitScope();
    }
"[" {
	//cout << "142 " << endl;
	tokenFile << "<LTHIRD, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <LTHIRD> Lexeme " << yytext << " found" << endl;
    }
"]" {
	//cout << "147 " << endl;
	tokenFile << "<RTHIRD, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <RTHIRD> Lexeme " << yytext << " found" << endl;
    }
"," {
	//cout << "152 " << endl;
	tokenFile << "<COMMA, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <COMMA> Lexeme " << yytext << " found" << endl;
    }
";" {
	//cout << "157 " << endl;
	tokenFile << "<SEMICOLON, " << yytext << "> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <SEMICOLON> Lexeme " << yytext << " found" << endl;
    }
{IDENTIFIER}   {
			//cout << "162" << endl;
		    tokenFile << "<ID, " << yytext << "> " ;
		    logFile << endl <<"Line no. " << line_count << ": Token <ID> Lexeme " << yytext << " found" << endl;
		    if(st.Insert(yytext, "ID")){
		    	st.printAllScopeTable();
		    }
	       }

'{NORMAL_CHARECTERS}' {
			//cout << "171 " << endl;
		   	tokenFile << "<CONST_CHAR, " << yytext[1] << "> ";
		   	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> " << "<CONST_CHAR, " << yytext[1] << ">"<< endl;
		   	if(st.Insert(yytext, "CONST_CHAR")){
		    		st.printAllScopeTable();
		    	}
		    }
'\\n' {
	//cout << "179 " << endl;
	tokenFile << "<CONST_CHAR," << '\n' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\n' << ">" << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }

'\\t' {
	//cout << "188 " ;
	tokenFile << "<CONST_CHAR," << '\t' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\t' << ">"  << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }

'\\r' {
	//cout << "197 " << endl;
	tokenFile << "<CONST_CHAR," << '\r' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\r' << ">" << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }
'\\a' {
	//cout << "205 " << endl;
	tokenFile << "<CONST_CHAR," << '\a' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\a' << ">" << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }
'\\f' {
	//cout << "213 " << endl;
	tokenFile << "<CONST_CHAR," << '\f' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\f' << ">" << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }

'\\'' {
	//cout << "222 " << endl;
	tokenFile << "<CONST_CHAR," << '\'' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\'' << ">"  << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }

'\\b' {
	//cout << "231 " << endl;
	tokenFile << "<CONST_CHAR," << '\b' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\b' << ">" << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }
'\\v' {
	//cout << "239 " << endl;
	tokenFile << "<CONST_CHAR," << '\v' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\v' << ">"  << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }
'\\0' {
	//cout << "247 " << endl;
	tokenFile << "<CONST_CHAR," << '\n' << "> ";
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\0' << ">"  << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }

'\\\\' {
	//cout << "256 " << endl;
	tokenFile << "<CONST_CHAR, \\> " ;
	logFile << endl <<"Line no. " << line_count << ": Token <CONST_CHAR> Lexeme " << yytext << " found --> <CONST_CHAR, " << '\\' << ">" << endl;
	if(st.Insert(yytext, "CONST_CHAR")){
          st.printAllScopeTable();
	}
      }

 /* multi line comment */

"/*" {commentInput = "/*"; BEGIN MULTILINE_COMMENT; line_offset = 0; }
<MULTILINE_COMMENT>"*/" {
				logFile << endl <<"Line no. " << line_count-line_offset << ": Token <COMMENT> Lexeme " << commentInput << "*/ found" << endl;
				BEGIN INITIAL; 
			 }

<MULTILINE_COMMENT><<EOF>> {
				logFile << endl <<"Error at line no. " << line_count-line_offset << ": Unterminated comment " << commentInput  << endl;
				st.printAllScopeTable();
				error_count++;
				logFile << endl <<"Total lines: " << line_count <<endl << "Total errors: " << error_count << endl;
				return 0; 
			    }
<MULTILINE_COMMENT>{NEWLINE} {line_count++; line_offset++; commentInput = commentInput + '\n';}

<MULTILINE_COMMENT>. {commentInput = commentInput + yytext;}


"//" {commentInput = "//"; line_offset = 0; BEGIN SINGLELINE_COMMENT; }
<SINGLELINE_COMMENT>\\{NEWLINE} {line_count++;line_offset++; commentInput = commentInput + '\\' + '\n';}
<SINGLELINE_COMMENT>{NEWLINE} {
				logFile << endl <<"Line no. " << line_count-line_offset << ": Token <COMMENT> Lexeme " << commentInput << " found" << endl;
				line_count++; 
				BEGIN INITIAL;
			       }
<SINGLELINE_COMMENT>. {commentInput = commentInput + yytext;}

 /*String*/

[\"] { stringInput = ""; logFileStringOutput = ""; line_offset = 0; BEGIN STRING; }
<STRING>[\"] {
		//cout << "281 " << endl;
		//cout << line_count  <<" :hello" << endl;
		tokenFile << "<STRING, \"" << stringInput << "\"> " ;
		logFile << endl <<"Line no. " << line_count-line_offset << ": Token <STRING> Lexeme \"" << logFileStringOutput << "\" found --> <STRING, \"" << stringInput << "\">" << endl;
		BEGIN INITIAL;
	     }

<STRING>\\{NEWLINE} {line_count++; logFileStringOutput = logFileStringOutput + '\\' + '\n'; line_offset++; }
<STRING>{NEWLINE} {logFile << endl <<"Error at line no. " << line_count-line_offset << ": Unterminated string  \"" << logFileStringOutput  << endl; error_count++; line_count++; BEGIN INITIAL; }
<STRING>\\t {stringInput = stringInput + '\t'; logFileStringOutput = logFileStringOutput + "\\t";}
<STRING>\\n {stringInput = stringInput + '\n'; logFileStringOutput = logFileStringOutput + "\\n" ;}
<STRING>\\\" {stringInput = stringInput + '\"'; logFileStringOutput = logFileStringOutput + "\\\"" ;}
<STRING>\\r {stringInput = stringInput + '\r';logFileStringOutput = logFileStringOutput + "\\r"; }
<STRING>\\a {stringInput = stringInput + '\a';logFileStringOutput = logFileStringOutput + "\\a"; }
<STRING>\\f {stringInput = stringInput + '\f';logFileStringOutput = logFileStringOutput + "\\f"; }
<STRING>\\' {stringInput = stringInput + '\'';logFileStringOutput = logFileStringOutput + "\\'"; }
<STRING>\\b {stringInput = stringInput + '\b';logFileStringOutput = logFileStringOutput + "\\b"; }
<STRING>\\v {stringInput = stringInput + '\v';logFileStringOutput = logFileStringOutput + "\\v"; }
<STRING>\\0 {stringInput = stringInput + '\n';logFileStringOutput = logFileStringOutput + "\\0"; }
<STRING>\\\\ {stringInput = stringInput + '\\';logFileStringOutput = logFileStringOutput + "\\\\"; }
 /*<STRING>[^{NEWLINE}(\\")(\\t)] {stringInput = stringInput + yytext; logFileStringOutput = logFileStringOutput + yytext;} */
<STRING>. {stringInput = stringInput + yytext; logFileStringOutput = logFileStringOutput + yytext;}



{TOO_MANY_DECIMAL_ERROR} {logFile << endl <<"Error at line no. " << line_count << ": Too many decimal " << yytext  << endl; error_count++; }

{ILL_FORMED_NUMBER} {logFile << endl <<"Error at line no. " << line_count << ": Ill formed number " << yytext  << endl; error_count++; }

{INVALID_PREFIX_ON_IDENTIFIER} { logFile << endl <<"Error at line no. " << line_count << ": Invalid suffix on number or invalid prifix on ID "  << yytext << endl; error_count++;
				}



{MULTI_CHARECTER_CONST_ERROR} { logFile << endl <<"Error at line no. " << line_count << ": Multi character constant error " << yytext  << endl; error_count++; }

{UNTERMINATED_CHARECTER} { logFile << endl <<"Error at line no. " << line_count << ": Unterminated character " << yytext  << endl; error_count++; }

 /*"\'\\\'" {logFile << "Error at line no. " << line_count << ": Unterminated charecter " << yytext  << endl; error_count++;}*/

{EMPTY_CHARECTER_CONSTANT} { logFile << endl <<"Error at line no. " << line_count << ": Empty character constant error " << yytext  << endl; error_count++; }

<<EOF>> {st.printAllScopeTable(); logFile << endl <<"Total lines: " << line_count <<endl << "Total errors: " << error_count << endl; return 0; }
. { logFile << endl <<"Error at line no. " << line_count << ": Unrecognized character " << yytext << endl; error_count++; }

%%


int main(int argc,char *argv[]){

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}


	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
