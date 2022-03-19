%{
#include<iostream>
#include<fstream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<bits/stdc++.h>
#include "SymbolTable.h"
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable *table = new SymbolTable(30);

FILE *fp;
ofstream logFile("log.txt");
ofstream errorFile("error.txt");
ofstream codeFile("code.asm");



Utilities util;
int line_count = 1;
int error_count = 0;

SymbolInfo* newLineSymbolInfo = new SymbolInfo("\n", "NEWLINE");

vector<SymbolInfo*>* parameterList = new vector<SymbolInfo*>();
bool parameterListInserted = true;

vector<string>* declaredVars = new vector<string>();
vector<pair<string, string>>* declaredArr = new vector<pair<string,string>>();
map<string, bool>* registers = new map<string, bool>();
vector<string>* funcTempVars = new vector<string>();
bool mainFound = false;
bool funcTempVarsInserted = false;
bool funcReturnStatementPrinted = false;
bool insideMain = false;

void yyerror(char *s)
{
	//write your code
}

void codeOptimization1(){

	ifstream inFile("code.asm");
	ofstream optimized("optimized_code.asm");
	string firstLine, secondLine, s1,s2;
	vector<string> line1,line2;

	string code = "";

	if(inFile.is_open() && optimized.is_open()){

		while(getline(inFile, firstLine)){
			if(firstLine.compare(".CODE") == 0){
				break;
			}
		}

		/* getline(inFile, firstLine); */

		int lineCount = 1;
		while(getline(inFile, secondLine)){

			s1 = util.trim(firstLine);
			line1 = util.tokenizer(s1, ' ');

			s2 = util.trim(secondLine);
			line2 = util.tokenizer(s2, ' ');

			if(line1.size() == 0 || line2.size() == 0){
				/* optimized << firstLine << endl; */
				code = code + firstLine + "\n";
				firstLine = secondLine;
				/* s1 = s2;
				line1 = line2; */
			}

			else if(line1.at(0).compare("MOV") != 0  || line2.at(0).compare("MOV") != 0){
				/* optimized << firstLine << endl; */
				code = code + firstLine + "\n";
				firstLine = secondLine;
				/* s1 = s2;
				line1 = line2; */
			}

			else{
				if(line1.at(1).compare(line2.at(3)) == 0 && line1.at(3).compare(line2.at(1)) == 0){
					cout << "Skipped line " << lineCount+1 << endl;

				}
				else if(util.is_number(line1.at(3)) && line1.at(1).compare(line2.at(3)) == 0 ){
					firstLine = "\t" + line2.at(0) + " " + line2.at(1) + " , " + line1.at(3);
					cout << "Skipped line " << lineCount << endl;
					std::vector<string>::iterator it;
					it = std::find (declaredVars->begin(), declaredVars->end(), line1.at(1));
					if(it != declaredVars->end()){
						declaredVars->erase(it);
					}
				}
				else{
					/* optimized << firstLine << endl; */
					code = code + firstLine + "\n";
					firstLine = secondLine;
					/* s1 = s2;
					line1 = line2; */
				}
			}

			lineCount++;
		}

		/* optimized << firstLine << endl; */
		code = code + firstLine + "\n";
	}

	string initCode = ".MODEL SMALL\n.STACK 100h\n.DATA\n";
	if(declaredVars->size() > 0 || declaredArr->size() > 0) initCode += "\t";

	initCode = initCode + "print_var DW ?\n\tret_temp DW ? \n\t";
	initCode = initCode + "newline DB 0Ah, 0Dh, '$'\n\t";
	for(int i=0;i<declaredVars->size();i++){
		initCode = initCode + declaredVars->at(i) + " DW ?\n\t";
	}
	for(int i=0;i<declaredArr->size();i++){
		initCode = initCode + declaredArr->at(i).first + " DW " + declaredArr->at(i).second + " dup(?)\n\t";
	}
	initCode = initCode + "\n";

	code = initCode + code;
	optimized << code ;

	inFile.close();
	optimized.close();

}


void codeOptimization(){
	ifstream inFile("code.asm");
	ofstream optimized("optimized_code.asm");
	string firstLine, secondLine, s1,s2;

	vector<string> line1,line2;


	if(inFile.is_open() && optimized.is_open()){
		getline(inFile, firstLine);
		s1 = util.trim(firstLine);
		line1 = util.tokenizer(s1, ' ');
		/* optimized << firstLine << endl; */
		int lineCount = 0;
		while(getline(inFile, secondLine)){
			/* optimized << secondLine <<  endl; */

			s2 = util.trim(secondLine);
			line2 = util.tokenizer(s2, ' ');
			/* optimized << line2.size() << endl << s2 << endl; */
			if(line1.size() != 0 && line2.size() !=0 && line1.at(0).compare("MOV") == 0 && line2.at(0).compare("MOV") == 0){
				if(line1.at(1).compare(line2.at(3)) == 0 && line1.at(3).compare(line2.at(1)) == 0 ){
					cout << "Skipped line " << lineCount+1 << endl;
				}
				/* else if(util.is_number(line1.at(3)) && line1.at(1).compare(line2.at(3)) == 0){
					cout << "Skipped line " << lineCount << endl;
					optimized << line2.at(0) << " " << line2.at(1) << " , " << line1.at(3) << endl;
				} */
				else{
					optimized << secondLine << endl;
				}
			}
			else{
				optimized << secondLine << endl;
			}

			firstLine = secondLine;
			s1 = s2;
			line1 = line2;
			lineCount++;

		}
	}
	optimized.close();
	inFile.close();

	/* inFile.open("optimized_code.asm");
	vector<string> fileLines;
	while(getline(inFile, firstLine)){
		fileLines.push_back(firstLine);
	}
	bool changeMade = true;
	auto iter = fileLines.begin();
	while(iter != fileLines.end()-1){
		firstLine = *iter;
		secondLine = *(iter+1);

		s1 = util.trim(firstLine);
		line1 = util.tokenizer(s1, ' ');
		s2 = util.trim(secondLine);
		line2 = util.tokenizer(s2, ' ');
		if(line1.size() != 0 && line2.size() != 0){
			else if(util.is_number(line1.at(3)) && line1.at(1).compare(line2.at(3)) == 0){
				cout << "Skipped line " << lineCount << endl;
				optimized << line2.at(0) << " " << line2.at(1) << " , " << line1.at(3) << endl;
			}
		}
		iter++;
	} */

}


%}

%union{
	SymbolInfo* si;
	int ivar;
	double dvar;
	vector<SymbolInfo*>* v;
}

%token  <si> INT FLOAT VOID IF ELSE FOR WHILE PRINTLN RETURN CONTINUE SEMICOLON COMMA ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD INCOP DECOP DO BREAK CHAR SWITCH CASE DEFAULT
%token <si> ID ADDOP MULOP RELOP LOGICOP CONST_INT CONST_FLOAT CONST_CHAR
%token <dvar> DOUBLE

%type <v> start program unit func_definition func_declaration parameter_list compound_statement var_declaration type_specifier
%type <v> declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term
%type <v> unary_expression factor arguments argument_list

/* %left
%right */

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program {
					logFile << "At line no. " << line_count << ": start: program" << endl << endl;
					$$ = new vector<SymbolInfo*>();

					string initCode = ".MODEL SMALL\n.STACK 100h\n.DATA\n";
					if(declaredVars->size() > 0 || declaredArr->size() > 0) initCode += "\t";

					initCode = initCode + "print_var DW ?\n\tret_temp DW ? \n\t";
					initCode = initCode + "newline DB 0Ah, 0Dh, '$'\n\t";
					for(int i=0;i<declaredVars->size();i++){
						initCode = initCode + declaredVars->at(i) + " DW ?\n\t";
					}
					for(int i=0;i<declaredArr->size();i++){
						initCode = initCode + declaredArr->at(i).first + " DW " + declaredArr->at(i).second + " dup(?)\n\t";
					}

					//initCode += ".CODE\n\tMOV AX, @DATA\n\tMOV DS, AX";
					initCode += "\n.CODE\n";
					initCode += util.getPrintProcedure();
					initCode += $1->back()->getCode();
					initCode += "END MAIN";

					if(error_count == 0){
						codeFile << initCode << endl;
						codeFile.close();
						codeOptimization1();
					}
					 table->printAllScopeTable();

					 logFile << "Total lines: " << line_count-1 << endl;
					 logFile << "Total errors: " << error_count << endl;
				}
	;

program : program unit {
						logFile << "At line no. " << line_count << ": program: program unit" << endl << endl;
						$$ = new vector<SymbolInfo*>();
			 			 for(int i=0;i<$1->size();i++){
			 				 logFile << $1->at(i)->getKey() << " ";
			 				 $$->push_back($1->at(i));
			 			 }

						 $$->push_back(newLineSymbolInfo);
						 logFile << newLineSymbolInfo->getKey() ;
						 for(int i=0;i<$2->size();i++){
			 				 logFile << $2->at(i)->getKey() << " ";
			 				 $$->push_back($2->at(i));
			 			 }
		 			 logFile << endl << endl;

					 SymbolInfo* typeInfo = new SymbolInfo();
					 typeInfo->setCode($1->back()->getCode() + $2->back()->getCode());
					 $$->push_back(typeInfo);

					}
	| unit {
		logFile << "At line no. " << line_count << ": program: unit" << endl << endl;
		$$ = new vector<SymbolInfo*>();
		for(int i=0;i<$1->size();i++){
			logFile << $1->at(i)->getKey() << " ";
			$$->push_back($1->at(i));
		}
		logFile << endl << endl;

		SymbolInfo* typeInfo = new SymbolInfo();
		typeInfo->setCode($1->back()->getCode());
		$$->push_back(typeInfo);
	}
	;

unit : var_declaration {
					logFile << "At line no. " << line_count << ": unit: var_declaration" << endl << endl;
					$$ = new vector<SymbolInfo*>();
	 			 for(int i=0;i<$1->size();i++){
	 				 logFile << $1->at(i)->getKey() << " ";
	 				 $$->push_back($1->at(i));
	 			 }
	 			 logFile << endl << endl;

				 SymbolInfo* typeInfo = new SymbolInfo();
				 typeInfo->setCode($1->back()->getCode());
				 $$->push_back(typeInfo);

				}
     | func_declaration {
			 logFile << "At line no. " << line_count << ": unit: func_declaration" << endl << endl;
			 $$ = new vector<SymbolInfo*>();
			 for(int i=0;i<$1->size();i++){
				 logFile << $1->at(i)->getKey() << " ";
				 $$->push_back($1->at(i));
			 }
			 logFile << endl << endl;

			 SymbolInfo* typeInfo = new SymbolInfo();
			 typeInfo->setCode($1->back()->getCode());
			 $$->push_back(typeInfo);

			 /* cout <<  $1->at(1)->getKey() << " " << $1->at(1)->getFunctionInfo()->getParamCount() << endl; */
		 }
     | func_definition {
			 logFile << "At line no. " << line_count << ": unit: func_definition" << endl << endl;
			 $$ = new vector<SymbolInfo*>();
			 for(int i=0;i<$1->size();i++){
				 logFile << $1->at(i)->getKey() << " ";
				 $$->push_back($1->at(i));
			 }
			 logFile << endl << endl;

			 SymbolInfo* typeInfo = new SymbolInfo();
			 typeInfo->setCode($1->back()->getCode());
			 $$->push_back(typeInfo);

			 /* cout <<  $1->at(1)->getKey() << " " << $1->at(1)->getFunctionInfo()->getParamCount() << endl;		 */
			 /* cout << $1->at(1)->getKey() << " :" << endl;
			 for(int i=0;i< $1->at(1)->getFunctionInfo()->getParamCount();i++ ){
				 cout << $1->at(1)->getFunctionInfo()->getParameters()->at(i)->getKey() << endl;
			 } */
		  }
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
										vector<SymbolInfo*>* paramTypes = new vector<SymbolInfo*>();

										logFile << "At line no. " << line_count << ": func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON" << endl << endl;
										$$ = new vector<SymbolInfo*>();
										for(int i=0;i<$1->size();i++){
											logFile << $1->at(i)->getKey() << " ";
											$$->push_back($1->at(i));
										}
										logFile << $2->getKey() << " ";
										$$->push_back($2);

										logFile << $3->getKey() << " ";
										$$->push_back($3);

										for(int i=0;i<$4->size();i++){
											logFile << $4->at(i)->getKey() << " ";
											$$->push_back($4->at(i));

											if($4->at(i)->getKey().compare("int") == 0 || $4->at(i)->getKey().compare("float") == 0){
												paramTypes->push_back($4->at(i));
											}
										}

										logFile << $5->getKey() << " ";
										$$->push_back($5);

										logFile << $6->getKey() << " ";
										$$->push_back($6);

										logFile << endl << endl;

										FunctionInfo* fi = new FunctionInfo();
										fi->setReturnType($1->at(0)->getKey());
										fi->setParamCount(paramTypes->size());
										fi->setParameters(paramTypes);

										$2->setIsFunc(true);
										$2->setFuncDefined(false);
										$2->setFunctionInfo(fi);
										$2->setReturnType($1->at(0)->getKey());

										if(!table->Insert($2)){
											logFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
											errorFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
											error_count++;
										}


										parameterListInserted = true;
										parameterList->clear();
									}
		| type_specifier ID LPAREN RPAREN SEMICOLON  {
				logFile << "At line no. " << line_count << ": func_declaration: type_specifier ID LPAREN RPAREN SEMICOLON" << endl << endl;
				$$ = new vector<SymbolInfo*>();
				for(int i=0;i<$1->size();i++){
					logFile << $1->at(i)->getKey() << " ";
					$$->push_back($1->at(i));
				}
				logFile << $2->getKey() << " ";
				$$->push_back($2);

				logFile << $3->getKey() << " ";
				$$->push_back($3);

				logFile << $4->getKey() << " ";
				$$->push_back($4);

				logFile << $5->getKey() << " ";
				$$->push_back($5);

				logFile << endl << endl;

				FunctionInfo* fi = new FunctionInfo();
				fi->setReturnType($1->at(0)->getKey());
				fi->setParamCount(0);
				fi->setParameters(nullptr);

				$2->setFunctionInfo(fi);
				$2->setIsFunc(true);
				$2->setFuncDefined(false);
				$2->setReturnType($1->at(0)->getKey());

				if(!table->Insert($2)){
					logFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
					errorFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
					error_count++;
				}
			}
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN {
										vector<SymbolInfo*>* paramTypes = new vector<SymbolInfo*>();
										for(int i=0;i<$4->size();i++){
											if($4->at(i)->getKey().compare("int") == 0 || $4->at(i)->getKey().compare("float") == 0){
												paramTypes->push_back($4->at(i));
											}
										}

										SymbolInfo* searchId = table->lookUp($2->getKey());

										if(searchId == nullptr){
											FunctionInfo* fi = new FunctionInfo();
											fi->setReturnType($1->at(0)->getKey());
											fi->setParamCount(paramTypes->size());
											fi->setParameters(paramTypes);

											$2->setFunctionInfo(fi);
											$2->setIsFunc(true);
											$2->setFuncDefined(true);
											$2->setReturnType($1->at(0)->getKey());
											table->Insert($2);
										}
										else{

											if(!searchId->getIsFunc() || searchId->getFuncDefined()){
												logFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
												errorFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
												error_count++;
											}
											else{
												searchId->setFuncDefined(true);

												if(searchId->getFunctionInfo()->getReturnType().compare($1->at(0)->getKey()) != 0){
													logFile << "Error at line no. " << line_count << ": Return type mismatch with function declaration in function " << $2->getKey() << endl << endl;
													errorFile << "Error at line no. " << line_count << ": Return type mismatch with function declaration in function " << $2->getKey() << endl << endl;
													error_count++;
												}
												if(searchId->getFunctionInfo()->getParamCount() != paramTypes->size()){
													logFile << "Error at line no. " << line_count << ": Total number of arguments mismatch with declaration in function " << $2->getKey() << endl << endl;
													errorFile << "Error at line no. " << line_count << ": Total number of arguments mismatch with declaration in function " << $2->getKey() << endl << endl;
													error_count++;
												}
												else{
													vector<SymbolInfo*>* parameters = searchId->getFunctionInfo()->getParameters();
													for(int i=0; i<parameters->size(); i++){
														if(parameters->at(i)->getKey().compare(paramTypes->at(i)->getKey()) != 0){
															logFile << "Error at line no. " << line_count << ": Invalid type of parameters from declaration in " << $2->getKey() << endl << endl;
															errorFile << "Error at line no. " << line_count << ": Invalid type of parameters from declaration in " << $2->getKey() << endl << endl;
															error_count++;
															break;
														}
													}
												}
											}
										}

										if($2->getKey().compare("main") == 0) {
											insideMain = true;
										}
										else{
											insideMain = false;
										}

									}
									compound_statement {
										logFile << "At line no. " << line_count << ": func_definition: type_specifier ID LPAREN parameter_list RPAREN compound_statement" << endl << endl;
										$$ = new vector<SymbolInfo*>();
										for(int i=0;i<$1->size();i++){
											logFile << $1->at(i)->getKey() << " ";
											$$->push_back($1->at(i));
										}
										logFile << $2->getKey() << " ";
										$$->push_back($2);

										/* table->Insert($2); */

										logFile << $3->getKey() << " ";
										$$->push_back($3);

										for(int i=0;i<$4->size();i++){
											logFile << $4->at(i)->getKey() << " ";
											$$->push_back($4->at(i));
										}

										logFile << $5->getKey() << " ";
										$$->push_back($5);

										for(int i=0;i<$7->size();i++){
											logFile << $7->at(i)->getKey() << " ";
											$$->push_back($7->at(i));
										}

										logFile << endl << endl;
										/* cout << $1->at(0)->getKey() << endl; */
										if($1->at(0)->getKey().compare($7->back()->getReturnType()) != 0  && $1->at(0)->getKey().compare("void") != 0){
											if($1->at(0)->getKey().compare("float") == 0 && ($7->back()->getReturnType().compare("float") == 0 || $7->back()->getReturnType().compare("int") == 0)){
												//do nothing
											}
											else{
												if($7->back()->getReturnType().compare("") == 0){
													if($2->getKey().compare("main") != 0){
														logFile << "Error at line no. " << line_count << ": No return value of " << $2->getKey() << endl << endl;
														errorFile << "Error at line no. " << line_count << ": No return value of " << $2->getKey() << endl << endl;
														error_count++;
													}
												}
												else{
													logFile << "Error at line no. " << line_count << ": Return value mismatch " << $2->getKey() << endl << endl;
													errorFile << "Error at line no. " << line_count << ": Return value mismatch " << $2->getKey() << endl << endl;
													error_count++;
												}
											}

										}

										SymbolInfo* searchId = table->lookUp($2->getKey());

										/* for(int i=0;i<funcTempVars->size();i++){cout << funcTempVars->at(i) << endl;} */

										searchId->getFunctionInfo()->setTempVars(funcTempVars);
										funcTempVarsInserted = true;
										/* for(int i=0;i<searchId->getFunctionInfo()->getTempVars()->size();i++){
											cout << searchId->getKey() << searchId->getFunctionInfo()->getTempVars()->at(i) << endl;
										} */


										SymbolInfo* searchId1 = table->lookUp($2->getKey());

										/* for(int i=0;i<searchId1->getFunctionInfo()->getTempVars()->size();i++){
											cout << searchId1->getKey() << searchId1->getFunctionInfo()->getTempVars()->at(i) << endl;
										} */

										SymbolInfo* typeInfo = new SymbolInfo();

										if($2->getKey().compare("main") == 0){
											string code = "MAIN PROC\n\tMOV AX , @DATA\n\tMOV DS , AX\n\n\t";
											code = code + $7->back()->getCode() + "\n\t";
											code = code + "MOV AH , 4CH\n\tINT 21H\nMAIN ENDP\n\n";
											typeInfo->setCode(code);
											$$->push_back(typeInfo);
											mainFound = true;
										}
										else{
											string code = $2->getKey() + " PROC\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tPUSH DI\n\n\t";
											if(!funcReturnStatementPrinted){
												code = code + $7->back()->getCode() + "\n\n\tPOP DI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\n" + $2->getKey() + " ENDP\n\n";
											}
											else{
												code = code + $7->back()->getCode() + "\n\n" + $2->getKey() + " ENDP\n\n";
											}
											/* code = code + $7->back()->getCode() + "\n\tPOP DI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\n" + $2->getKey() + " ENDP\n\n"; */
											typeInfo->setCode(code);
											$$->push_back(typeInfo);
										}

										/* funcTempVars->clear(); */
									}
		| type_specifier ID LPAREN RPAREN {
			SymbolInfo* searchId = table->lookUp($2->getKey());

			if(searchId == nullptr){
				FunctionInfo* fi = new FunctionInfo();
				fi->setReturnType($1->at(0)->getKey());
				fi->setParamCount(0);
				fi->setParameters(nullptr);

				$2->setFunctionInfo(fi);
				$2->setIsFunc(true);
				$2->setFuncDefined(true);
				$2->setReturnType($1->at(0)->getKey());
				table->Insert($2);
			}
			else{
				if(!searchId->getIsFunc() || searchId->getFuncDefined()){
					logFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
					errorFile << "Error at line no. " << line_count << ": Multiple declaration of " << $2->getKey() << endl << endl;
					error_count++;
				}
				else if(searchId->getFunctionInfo()->getReturnType().compare($1->at(0)->getKey()) != 0){
						logFile << "Error at line no. " << line_count << ": Return type mismatch with function declaration in function " << $2->getKey() << endl << endl;
						errorFile << "Error at line no. " << line_count << ": Return type mismatch with function declaration in function" << $2->getKey() << endl << endl;
						error_count++;

						searchId->setFuncDefined(true);
				}
				else if(searchId->getFunctionInfo()->getParamCount() > 0){
					logFile << "Error at line no. " << line_count << ": Total number of arguments mismatch with declaration in function " << $2->getKey() << endl << endl;
					errorFile << "Error at line no. " << line_count << ": Total number of arguments mismatch with declaration in function " << $2->getKey() << endl << endl;
					error_count++;

					searchId->setFuncDefined(true);
				}
				else{
					searchId->setFuncDefined(true);
				}
			}

			if($2->getKey().compare("main") == 0) {
				insideMain = true;
			}
			else{
				insideMain = false;
			}
		}
		compound_statement  {
			logFile << "At line no. " << line_count << ": func_definition: type_specifier ID LPAREN RPAREN compound_statement" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++){
				logFile << $1->at(i)->getKey() << " ";
				$$->push_back($1->at(i));
			}
			logFile << $2->getKey() << " ";
			$$->push_back($2);

			/* table->Insert($2); */

			logFile << $3->getKey() << " ";
			$$->push_back($3);

			logFile << $4->getKey() << " ";
			$$->push_back($4);

			for(int i=0;i<$6->size();i++){
				logFile << $6->at(i)->getKey() << " ";
				$$->push_back($6->at(i));
			}

			logFile << endl << endl;

			if($1->at(0)->getKey().compare($6->back()->getReturnType()) != 0 && $1->at(0)->getKey().compare("void") != 0){
				if($1->at(0)->getKey().compare("float") == 0 && ($6->back()->getReturnType().compare("float") == 0 || $6->back()->getReturnType().compare("int") == 0)){
					//do nothing
				}
				else{
					if($6->back()->getReturnType().compare("") == 0){
						if($2->getKey().compare("main") != 0){
							logFile << "Error at line no. " << line_count << ": No return value of " << $2->getKey() << endl << endl;
							errorFile << "Error at line no. " << line_count << ": No return value of " << $2->getKey() << endl << endl;
							error_count++;
						}
					}
					else{
						logFile << "Error at line no. " << line_count << ": Return value mismatch " << $2->getKey() << endl << endl;
						errorFile << "Error at line no. " << line_count << ": Return value mismatch " << $2->getKey() << endl << endl;
						error_count++;
					}
				}
			}

			SymbolInfo* searchId = table->lookUp($2->getKey());

			searchId->getFunctionInfo()->setTempVars(funcTempVars);
			funcTempVarsInserted = true;
			SymbolInfo* typeInfo = new SymbolInfo();

			if($2->getKey().compare("main") == 0){
				string code = "MAIN PROC\n\tMOV AX , @DATA\n\tMOV DS , AX\n\n\t";
				code = code + $6->back()->getCode() + "\n\t";
				code = code + "MOV AH , 4CH\n\tINT 21H\nMAIN ENDP\n\n";
				typeInfo->setCode(code);
				$$->push_back(typeInfo);
				mainFound = true;
			}
			else{
				string code = $2->getKey() + " PROC\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tPUSH DI\n\n\t";
				if(!funcReturnStatementPrinted){
					code = code + $6->back()->getCode() + "\n\n\tPOP DI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\n" + $2->getKey() + " ENDP\n\n";
				}
				else{
					code = code + $6->back()->getCode() + "\n\n" + $2->getKey() + " ENDP\n\n";
				}
				/* code = code + $6->back()->getCode() + "\n\tPOP DI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n\n" + $2->getKey() + " ENDP\n\n"; */
				typeInfo->setCode(code);
				$$->push_back(typeInfo);
			}

			/* funcTempVars->clear(); */
		}
 		;


parameter_list  : parameter_list COMMA type_specifier ID {

										parameterList->clear();

										logFile << "At line no. " << line_count << ": parameter_list: parameter_list COMMA type_specifier ID" << endl << endl;
										$$ = new vector<SymbolInfo*>();

										for(int i=0;i<$1->size();i++){
											logFile << $1->at(i)->getKey() << " ";
											$$->push_back($1->at(i));

											parameterList->push_back($1->at(i));
										}
										logFile << $2->getKey() << " ";
										$$->push_back($2);

										parameterList->push_back($2);

										for(int i=0;i<$3->size();i++){
											logFile << $3->at(i)->getKey() << " ";
											$$->push_back($3->at(i));

											parameterList->push_back($3->at(i));
										}

										logFile << $4->getKey() << endl << endl;
										$4->setReturnType($3->at(0)->getKey());
										$4->setIsVar(true);
										$$->push_back($4);

										parameterList->push_back($4);

										parameterListInserted = false;

									}
		| parameter_list COMMA type_specifier {

			parameterList->clear();

			logFile << "At line no. " << line_count << ": parameter_list: parameter_list COMMA type_specifier" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++){
				logFile << $1->at(i)->getKey() << " ";
				$$->push_back($1->at(i));

				parameterList->push_back($1->at(i));
			}
			logFile << $2->getKey() << " ";
			$$->push_back($2);

			parameterList->push_back($2);

			for(int i=0;i<$3->size();i++){
				logFile << $3->at(i)->getKey() << " ";
				$$->push_back($3->at(i));

				parameterList->push_back($3->at(i));
			}

			parameterListInserted = false;
		}
 		| type_specifier ID {

			parameterList->clear();

			logFile << "At line no. " << line_count << ": parameter_list: type_specifier ID" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++){
				logFile << $1->at(i)->getKey() << " ";
				$$->push_back($1->at(i));

				parameterList->push_back($1->at(i));
			}
			logFile << $2->getKey() << endl << endl;

			$2->setIsVar(true);
			$2->setReturnType($1->at(0)->getKey());
			$$->push_back($2);

			parameterList->push_back($2);
			parameterListInserted = false;
		}
		| type_specifier  {

			parameterList->clear();

			logFile << "At line no. " << line_count << ": parameter_list: type_specifier" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++){
				logFile << $1->at(i)->getKey() << " ";
				$$->push_back($1->at(i));

				parameterList->push_back($1->at(i));

			}

			logFile << endl << endl;

			parameterListInserted = false;

		}
 		;


compound_statement : LCURL {
										/* cout << "lcurl" << line_count << endl; */
										if(funcTempVarsInserted){
											funcTempVars = new vector<string>();
											funcTempVarsInserted = false;
										}

										table->enterScope();
										logFile << "New scopetable ID: " << table->currentTable->getId() << endl << endl;
										if(!parameterListInserted){
											parameterListInserted = true;

											for(int i=0;i<parameterList->size();i++){
												if(parameterList->at(i)->getType().compare("ID") == 0){

													parameterList->at(i)->setIsVar(true);
													/* table->Insert(parameterList->at(i)); */
													string tempVar = parameterList->at(i)->getKey() + util.getVarPostfix(table->currentTable->getId());
													parameterList->at(i)->setTempVar(tempVar);
													parameterList->at(i)->setReturnType(parameterList->at(i-1)->getKey());
													declaredVars->push_back(tempVar);
													funcTempVars->push_back(tempVar);

													if(!table->Insert(parameterList->at(i))){
				 									 logFile << "Error at line no. " << line_count << ": Multiple declaration of " << parameterList->at(i)->getKey() << " in parameter" << endl << endl;
				 				 					 errorFile << "Error at line no. " << line_count << ": Multiple declaration of " << parameterList->at(i)->getKey() << " in parameter" << endl << endl;
													 error_count++;
				 								 }
												}
											}
											//table->printAllScopeTable();
											parameterList->clear();
										}
									}
 									   statements RCURL  {
											logFile << "At line no. " << line_count << ": compound_statement: LCURL statements RCURL" << endl << endl;
											$$ = new vector<SymbolInfo*>();
											$$->push_back($1);
											logFile << $1->getKey() << " ";

											$$->push_back(newLineSymbolInfo);
											logFile << newLineSymbolInfo->getKey();

											for(int i=0;i<$3->size()-1;i++){
												logFile << $3->at(i)->getKey() << " ";
												$$->push_back($3->at(i));
											}

											$$->push_back(newLineSymbolInfo);
											logFile << newLineSymbolInfo->getKey();

											$$->push_back($4);
											logFile << $4->getKey() << endl << endl ;

											SymbolInfo* typeInfo = new SymbolInfo();
											typeInfo->setReturnType($3->back()->getReturnType());
											typeInfo->setCode($3->back()->getCode());
											$$->push_back(typeInfo);

											table->printAllScopeTable();
											table->exitScope();
										}
 		    | LCURL {
					/* cout << "lcurl" << line_count << endl; */
					if(funcTempVarsInserted){
						funcTempVars = new vector<string>();
						funcTempVarsInserted = false;
					}
					 table->enterScope();
					 logFile << "New scopetable ID: " << table->currentTable->getId() << endl << endl;
					 if(!parameterListInserted){
						 parameterListInserted = true;

						 for(int i=0;i<parameterList->size();i++){
							 if(parameterList->at(i)->getType().compare("ID") == 0){
								 parameterList->at(i)->setIsVar(true);
								 /* table->Insert(parameterList->at(i)); */
								 string tempVar = parameterList->at(i)->getKey() + util.getVarPostfix(table->currentTable->getId());
								 parameterList->at(i)->setTempVar(tempVar);
								 parameterList->at(i)->setReturnType(parameterList->at(i-1)->getKey());
								 declaredVars->push_back(tempVar);
								 funcTempVars->push_back(tempVar);

								 if(!table->Insert(parameterList->at(i))){
									 logFile << "Error at line no. " << line_count << ": Multiple declaration of " << parameterList->at(i)->getKey() << " in parameter" << endl << endl;
				 					 errorFile << "Error at line no. " << line_count << ": Multiple declaration of " << parameterList->at(i)->getKey() << " in parameter" << endl << endl;
									 error_count++;
								 }
							 }
						 }

						 //table->printAllScopeTable();

						 parameterList->clear();
					 }
				 }
				  RCURL {
					logFile << "At line no. " << line_count << ": compound_statement: LCURL RCURL" << endl << endl;
					$$ = new vector<SymbolInfo*>();
					$$->push_back($1);
					logFile << $1->getKey() << " ";
					$$->push_back($3);
					logFile << $3->getKey() << " ";
					logFile << endl << endl;

					table->printAllScopeTable();
					table->exitScope();

					SymbolInfo* typeInfo = new SymbolInfo();
					typeInfo->setReturnType("");
					$$->push_back(typeInfo);
				}
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON {
										vector<SymbolInfo*>* multipleDeclarations = new vector<SymbolInfo*>();
										logFile << "At line no. " << line_count << ": var_declaration: type_specifier declaration_list SEMICOLON" << endl << endl;
										$$ = new vector<SymbolInfo*>();
										for(int i=0;i<$1->size();i++){
											logFile << $1->at(i)->getKey() << " ";
											$$->push_back($1->at(i));
										}
										for(int i=0;i<$2->size();i++){
											logFile << $2->at(i)->getKey() << " ";

											if($2->at(i)->getType().compare("ID") == 0){
												/* cout << $1->at(0)->getKey() << endl; */
												$2->at(i)->setReturnType($1->at(0)->getKey());
												$2->at(i)->setIsVar(true);

												string varName = $2->at(i)->getKey() + util.getVarPostfix(table->currentTable->getId());
												$2->at(i)->setTempVar(varName);
												/* cout << $2->at(i)->getReturnType() << endl; */
												if($1->at(0)->getKey().compare("void") != 0){
													if(!table->Insert($2->at(i))){
														multipleDeclarations->push_back($2->at(i));
													}
												}

												if($2->at(i)->getIsArray()){
													pair<string, string> arr;
													arr.first = varName;
													arr.second = util.intToString($2->at(i)->getArrayLength());
													declaredArr->push_back(arr);
												}
												else{
													declaredVars->push_back(varName);
												}
											}

											$$->push_back($2->at(i));
										}

										logFile << $3->getKey();
										$$->push_back($3);
										logFile << endl << endl;

										if($1->at(0)->getKey().compare("void") == 0){
											logFile << "Error at line no. " << line_count << ": Variable type cannot be void" << endl << endl;
											errorFile << "Error at line no. " << line_count << ": Variable type cannot be void " << endl << endl;
											error_count++;
										}

										if(multipleDeclarations->size() > 0){
											for(int i=0;i<multipleDeclarations->size();i++){
												logFile << "Error at line no. " << line_count << ": Multiple declaration of " << multipleDeclarations->at(i)->getKey() << endl << endl;
												errorFile << "Error at line no. " << line_count << ": Multiple declaration of " << multipleDeclarations->at(i)->getKey() << endl << endl;
												error_count++;
											}
										}
									}
 		 ;

type_specifier	: INT {
												logFile << "At line no. " << line_count << ": type_specifier: INT" << endl << endl;
												$$ = new vector<SymbolInfo*>();
												logFile << $1->getKey();
												$$->push_back($1);
												logFile << endl << endl;
											}
 		| FLOAT {
			logFile << "At line no. " << line_count << ": type_specifier: FLOAT" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			logFile << $1->getKey();
			$$->push_back($1);
			logFile << endl << endl;
		}
 		| VOID  {
			logFile << "At line no. " << line_count << ": type_specifier: VOID" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			logFile << $1->getKey();
			$$->push_back($1);
			logFile << endl << endl;
		}
 		;

declaration_list : declaration_list COMMA ID  {
										logFile << "At line no. " << line_count << ": declaration_list: declaration_list COMMA ID" << endl << endl;
										$$ = new vector<SymbolInfo*>();
										for(int i=0;i<$1->size();i++){
											logFile << $1->at(i)->getKey() << " ";
											$$->push_back($1->at(i));
										}
										$$->push_back($2);
										logFile << $2->getKey() << " ";
										$$->push_back($3);
										logFile << $3->getKey() << " ";
										logFile << endl << endl;

										/* table->Insert($3); */
									}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
				logFile << "At line no. " << line_count << ": declaration_list: declaration_list COMMA ID LTHIRD CONST_INT RTHIRD" << endl << endl;
				$$ = new vector<SymbolInfo*>();
				for(int i=0;i<$1->size();i++){
					logFile << $1->at(i)->getKey() << " ";
					$$->push_back($1->at(i));
				}
				$$->push_back($2);
				logFile << $2->getKey() << " ";

				$3->setIsArray(true);
				$3->setArrayLength(util.stringToInt($5->getKey()));
				$$->push_back($3);
				logFile << $3->getKey() << " ";

				/* table->Insert($3); */

				$$->push_back($4);
				logFile << $4->getKey() << " ";
				$$->push_back($5);
				logFile << $5->getKey() << " ";

				/* table->Insert($5); */

				$$->push_back($6);
				logFile << $6->getKey() << " ";
				logFile << endl << endl;
			}
 		  | ID {
				logFile << "At line no. " << line_count << ": declaration_list: ID" << endl << endl;
				$$ = new vector<SymbolInfo*>();
				logFile << $1->getKey();
				$$->push_back($1);

				/* table->Insert($1); */

				logFile << endl << endl;
			}
 		  | ID LTHIRD CONST_INT RTHIRD  {
				logFile << "At line no. " << line_count << ": declaration_list: ID LTHIRD CONST_INT RTHIRD" << endl << endl;
				$$ = new vector<SymbolInfo*>();
				logFile << $1->getKey();
				$1->setIsArray(true);
				$1->setArrayLength(util.stringToInt($3->getKey()));
				$$->push_back($1);

				/* table->Insert($1); */

				logFile << $2->getKey();
				$$->push_back($2);
				logFile << $3->getKey();
				$$->push_back($3);

				/* table->Insert($3); */

				logFile << $4->getKey();
				$$->push_back($4);
				logFile << endl << endl;
			}
 		  ;

statements : statement {
							logFile << "At line no. " << line_count << ": statements: statement" << endl << endl;
							$$ = new vector<SymbolInfo*>();
							for(int i=0;i<$1->size()-1;i++){
								logFile << $1->at(i)->getKey() << " ";
								$$->push_back($1->at(i));
							}
							logFile << endl << endl;

							SymbolInfo* typeInfo = new SymbolInfo();
							typeInfo->setReturnType($1->back()->getReturnType());

							typeInfo->setCode($1->back()->getCode());

							$$->push_back(typeInfo);
						}
	   | statements statement  {
			 logFile << "At line no. " << line_count << ": statements: statements statement" << endl << endl;
			 $$ = new vector<SymbolInfo*>();
 			for(int i=0;i<$1->size()-1;i++){
 				logFile << $1->at(i)->getKey() << " ";
 				$$->push_back($1->at(i));
 			}

			logFile << newLineSymbolInfo->getKey();
			$$->push_back(newLineSymbolInfo);

			for(int i=0;i<$2->size()-1;i++){
 				logFile << $2->at(i)->getKey() << " ";
 				$$->push_back($2->at(i));
 			}
 			logFile << endl << endl;


				SymbolInfo* typeInfo = new SymbolInfo();

			if($1->back()->getReturnType().compare("") == 0){
				typeInfo->setReturnType($2->back()->getReturnType());
			}
			else{
				typeInfo->setReturnType($1->back()->getReturnType());
			}

			string code = $1->back()->getCode() + $2->back()->getCode();
			typeInfo->setCode(code);

			$$->push_back(typeInfo);
		 }
	   ;

statement : var_declaration  {
							logFile << "At line no. " << line_count << ": statement: var_declaration" << endl << endl;
							$$ = new vector<SymbolInfo*>();
							for(int i=0;i<$1->size();i++){
								logFile << $1->at(i)->getKey() << " ";
								$$->push_back($1->at(i));
							}
							logFile << endl << endl;

							SymbolInfo* typeInfo = new SymbolInfo();
							typeInfo->setReturnType("");
							$$->push_back(typeInfo);
						}
	  | expression_statement {
			logFile << "At line no. " << line_count << ": statement: expression_statement" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "";
			for(int i=0;i<$1->size();i++){
				logFile << $1->at(i)->getKey() << " ";
				stmt = stmt + $1->at(i)->getKey() + " ";
				$$->push_back($1->at(i));
			}
			logFile << endl << endl;
			stmt = stmt+ "\n\t";

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");
			string code = ";LINE NO. " + util.intToString(line_count) + ": " + stmt + $1->back()->getCode();
			typeInfo->setCode(code);
			$$->push_back(typeInfo);
		}
	  | compound_statement {
			logFile << "At line no. " << line_count << ": statement: compound_statement" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "";
			for(int i=0;i<$1->size();i++){
				logFile << $1->at(i)->getKey() << " ";
				stmt = stmt + $1->at(i)->getKey() + " ";
				if($1->at(i)->getKey().compare("\n") == 0){
					stmt = stmt + "; ";
				}
				$$->push_back($1->at(i));
			}
			logFile << endl << endl;
			stmt = stmt+ "\n\t";

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");
			typeInfo->setCode($1->back()->getCode());
			$$->push_back(typeInfo);
		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			logFile << "At line no. " << line_count << ": statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "" ;
			logFile << $1->getKey();
			stmt = stmt+$1->getKey();
			$$->push_back($1);
			logFile << $2->getKey();
			stmt = stmt + $2->getKey();
			$$->push_back($2);

			for(int i=0;i<$3->size();i++){
				logFile << $3->at(i)->getKey() << " ";
				stmt = stmt + $3->at(i)->getKey() + " ";
				$$->push_back($3->at(i));
			}

			for(int i=0;i<$4->size();i++){
				logFile << $4->at(i)->getKey() << " ";
				stmt = stmt + $4->at(i)->getKey() + " ";
				$$->push_back($4->at(i));
			}

			for(int i=0;i<$5->size();i++){
				logFile << $5->at(i)->getKey() << " ";
				stmt = stmt + $5->at(i)->getKey() + " ";
				$$->push_back($5->at(i));
			}
			logFile << $6->getKey();
			stmt = stmt + $6->getKey() + " ";
			$$->push_back($6);

			for(int i=0;i<$7->size();i++){
				logFile << $7->at(i)->getKey() << " ";
				/* stmt = stmt + $7->at(i)->getKey() + " "; */
				$$->push_back($7->at(i));
			}

			logFile << endl << endl;
			stmt = stmt + "\n\t";

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");
			string code = $3->back()->getCode();
			string label_1 = util.newLabel();
			code  = code + "\n" + label_1 + ":\n\t";
			code = code + $4->back()->getCode();
			code = code + "MOV AX , " + $4->back()->getTempVar() + "\n\t";
			code = code + "MOV AX , 0\n\t";
			string label_2 = util.newLabel();
			code = code + "JE " + label_2 + "\n\t";
			code = code + $7->back()->getCode();
			code = code + $5->back()->getCode();
			code = code + "JMP " + label_1 + "\n";
			code = code + label_2 + ":\n\t";
			code = ";LINE NO. " + util.intToString(line_count) + ": " + stmt + code;
			typeInfo->setCode(code);
			$$->push_back(typeInfo);

			funcReturnStatementPrinted = false;
		}
	  | IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE {
			logFile << "At line no. " << line_count << ": statement: IF LPAREN expression RPAREN statement" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "";
			logFile << $1->getKey();
			stmt = stmt + $1->getKey();
			$$->push_back($1);
			logFile << $2->getKey();
			stmt = stmt + $2->getKey();
			$$->push_back($2);

			for(int i=0;i<$3->size();i++){
				logFile << $3->at(i)->getKey() << " ";
				stmt = stmt + $3->at(i)->getKey() + " ";
				$$->push_back($3->at(i));
			}

			logFile << $4->getKey();
			stmt = stmt + $4->getKey() + " ";
			$$->push_back($4);

			for(int i=0;i<$5->size();i++){
				logFile << $5->at(i)->getKey() << " ";
				/* stmt = stmt + $5->at(i)->getKey() + " "; */
				$$->push_back($5->at(i));
			}

			logFile << endl << endl;
			stmt = stmt + "\n\t";

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");

			string code = $3->back()->getCode();
			code = code + "MOV AX , " + $3->back()->getTempVar() + "\n\t";
			code = code + "CMP AX, 0\n\t";
			string label = util.newLabel();
			code = code + "JE " + label + "\n\t";
			code = code + $5->back()->getCode();
			code = code + "\n" + label + ":\n\t";
			code = ";LINE NO. " + util.intToString(line_count) + ": "  + stmt + code;


			typeInfo->setCode(code);
			$$->push_back(typeInfo);

			funcReturnStatementPrinted = false;
		}
	  | IF LPAREN expression RPAREN statement ELSE statement  {
			logFile << "At line no. " << line_count << ": statement: IF LPAREN expression RPAREN statement ELSE statement" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "";
			logFile << $1->getKey();
			stmt = stmt + $1->getKey();
			$$->push_back($1);
			logFile << $2->getKey();
			stmt = stmt + $2->getKey();
			$$->push_back($2);

			for(int i=0;i<$3->size();i++){
				logFile << $3->at(i)->getKey() << " ";
				stmt = stmt + $3->at(i)->getKey() + " ";
				$$->push_back($3->at(i));
			}
			logFile << $4->getKey();
			stmt = stmt + $4->getKey();
			$$->push_back($4);

			for(int i=0;i<$5->size();i++){
				logFile << $5->at(i)->getKey() << " ";
				/* stmt = stmt + $5->at(i)->getKey() + " "; */
				$$->push_back($5->at(i));
			}
			logFile << $6->getKey();
			/* stmt = stmt + $6->getKey(); */
			$$->push_back($6);

			for(int i=0;i<$7->size();i++){
				logFile << $7->at(i)->getKey() << " ";
				/* stmt = stmt + $7->at(i)->getKey() + " "; */
				$$->push_back($7->at(i));
			}

			logFile << endl << endl;
			stmt = stmt + "\n\t";

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");

			string code = $3->back()->getCode();
			code = code + "MOV AX , " +	$3->back()->getTempVar() + "\n\t";
			code = code + "CMP AX, 0\n\t";
			string label = util.newLabel();
			code = code + "JE " + label + "\n\t";
			code = code + $5->back()->getCode();
			string label_1 = util.newLabel();
			code = code + "JMP " + label_1 + "\n";
			code = code + label + ":\n\t";
			code = code + $7->back()->getCode() + "\n";
			code = code + label_1 + ":\n\t";
			code = ";LINE NO. " + util.intToString(line_count) + ": "  + stmt + code;

			typeInfo->setCode(code);
			$$->push_back(typeInfo);

			funcReturnStatementPrinted = false;
		}
	  | WHILE LPAREN expression RPAREN statement {
			logFile << "At line no. " << line_count << ": statement: WHILE LPAREN expression RPAREN statement" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "";
			logFile << $1->getKey();
			stmt = stmt + $1->getKey();
			$$->push_back($1);
			logFile << $2->getKey();
			stmt = stmt + $2->getKey();
			$$->push_back($2);

			for(int i=0;i<$3->size();i++){
				logFile << $3->at(i)->getKey() << " ";
				stmt = stmt + $3->at(i)->getKey()  + " ";
				$$->push_back($3->at(i));
			}
			logFile << $4->getKey();
			stmt = stmt + $4->getKey();
			$$->push_back($4);

			for(int i=0;i<$5->size();i++){
				logFile << $5->at(i)->getKey() << " ";
				/* stmt = stmt + $5->at(i)->getKey()  + " "; */
				$$->push_back($5->at(i));
			}

			logFile << endl << endl;
			stmt = stmt + "\n\t";

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");
			string code = "";
			string label_1 = util.newLabel();
			code = code + "\n" + label_1 + ":\n\t";
			code = code + $3->back()->getCode();
			code = code + "MOV AX , "+ $3->back()->getTempVar() + "\n\t";
			code = code + "CMP AX, 0\n\t";
			string label_2 = util.newLabel();
			code = code + "JE " + label_2 + "\n\t";
			code = code + $5->back()->getCode();
			code = code + "JMP " + label_1 + "\n";
			code = code + label_2 + ":\n\t";
			code = ";LINE NO. " + util.intToString(line_count) + ": "  + stmt + code;
			typeInfo->setCode(code);
			$$->push_back(typeInfo);

			funcReturnStatementPrinted = false;
		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			logFile << "At line no. " << line_count << ": statement: PRINTLN LPAREN ID RPAREN SEMICOLON" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "";
			logFile << $1->getKey();
			stmt = stmt + $1->getKey();
			$$->push_back($1);
			logFile << $2->getKey();
			stmt = stmt + $2->getKey();
			$$->push_back($2);
			logFile << $3->getKey();
			stmt = stmt + $3->getKey();
			$$->push_back($3);

			/* table->Insert($3); */

			logFile << $4->getKey();
			stmt = stmt + $4->getKey();
			$$->push_back($4);
			logFile << $5->getKey();
			stmt = stmt + $5->getKey();
			$$->push_back($5);

			logFile<< endl << endl;
			stmt = stmt + "\n\t";
			SymbolInfo* checker = table->lookUp($3);
			if(checker == nullptr){
				logFile << "Error at line no. " << line_count << ": Undeclared variable " << $3->getKey() << endl << endl;
				errorFile << "Error at line no. " << line_count << ": Undeclared variable " << $3->getKey() << endl << endl;
				error_count++;
			}

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");

			string temp = checker->getTempVar();
			string code = "MOV AX , " + temp + "\n\t";
			code = code + "MOV print_var , AX\n\tcall PRINT\n\t";
			code = ";LINE NO. "  + util.intToString(line_count) + ": "  + stmt + code;
			typeInfo->setCode(code);

			$$->push_back(typeInfo);
		}
	  | RETURN expression SEMICOLON  {
			/* cout << " return " << line_count << endl; */
			logFile << "At line no. " << line_count << ": statement: RETURN expression SEMICOLON" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			string stmt = "";
			logFile << $1->getKey() << " ";
			stmt = stmt + $1->getKey() + " ";
			$$->push_back($1);
			for(int i=0;i<$2->size();i++){
				logFile << $2->at(i)->getKey() << " ";
				stmt = stmt + $2->at(i)->getKey() + " ";
				$$->push_back($2->at(i));
			}

			logFile << $3->getKey() << endl << endl;
			stmt = stmt + $3->getKey() + "\n\t";
			$$->push_back($3);

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType($2->back()->getReturnType());

			string code = $2->back()->getCode();
			code = code + "MOV AX , " + $2->back()->getTempVar() + "\n\t";
			if(!insideMain){
				code = code + "MOV ret_temp , AX\n\n\tPOP DI\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\n";
			}
			else{
				code = code + "MOV ret_temp , AX\n";
			}
			code = ";LINE NO. " + util.intToString(line_count) + ": "  + stmt + code;

			typeInfo->setCode(code);
			$$->push_back(typeInfo);

			funcReturnStatementPrinted = true;
		}
	  ;

expression_statement 	: SEMICOLON  {
													logFile << "At line no. " << line_count << ": expression_statement: SEMICOLON" << endl << endl;
													$$ = new vector<SymbolInfo*>();
													logFile << $1->getKey() << endl << endl;
													$$->push_back($1);
												}
			| expression SEMICOLON  {
				logFile << "At line no. " << line_count << ": expression_statement: expression SEMICOLON" << endl << endl;
				$$ = new vector<SymbolInfo*>();
				for(int i=0;i<$1->size()-1;i++){
					logFile << $1->at(i)->getKey() << " ";
					$$->push_back($1->at(i));
				}

				logFile << $2->getKey() << endl << endl;
				$$->push_back($2);

				/* $$->push_back($1->back()); */
				SymbolInfo* typeInfo = new SymbolInfo();
				typeInfo->setReturnType($1->back()->getReturnType());
				typeInfo->setTempVar($1->back()->getTempVar());
				typeInfo->setCode($1->back()->getCode());

				$$->push_back(typeInfo);
			}
			;

variable : ID {
						logFile << "At line no. " << line_count << ": variable: ID" << endl << endl;
						$$ = new vector<SymbolInfo*>();
				 		 logFile << $1->getKey() << endl << endl;;
				 		 $$->push_back($1);

						 /* table->Insert($1); */

						 SymbolInfo* checker = table->lookUp($1);
						 if(checker != nullptr){
							 if(!checker->getIsvar()){
								 logFile << "Error at line no. " << line_count << ": " << checker->getKey() <<  " is not a variable" << endl << endl;
								 errorFile << "Error at line no. " << line_count << ": " << checker->getKey() <<  " is not a variable" << endl << endl;
								 error_count++;
							 }
							 else if(checker->getIsArray()){
								 logFile << "Error at line no. " << line_count << ": Type mismatch, " << checker->getKey() << " is an array." << endl << endl;
								 errorFile << "Error at line no. " << line_count << ": Type mismatch, " << checker->getKey() << " is an array." << endl << endl;
								 error_count++;
							 }
						 }
						 else{
							 logFile << "Error at line no. " << line_count << ": Undeclared variable " << $1->getKey()  << endl << endl;
							 errorFile << "Error at line no. " << line_count << ": Undelcared variable " << $1->getKey() << endl << endl;
							 error_count++;
						 }

						 SymbolInfo* typeInfo = new SymbolInfo();
						 if(checker!=nullptr){
							 typeInfo->setReturnType(checker->getReturnType());
							 typeInfo->setTempVar(checker->getTempVar());
						 }
						 else{
							 typeInfo->setReturnType("");
						 }
						 typeInfo->setIsVar(true);
						 $$->push_back(typeInfo);
						 /* logFile << $1->getReturnType() << " " << $$->back()->getReturnType() << endl << endl; */
					}
	 | ID LTHIRD expression RTHIRD {
		 logFile << "At line no. " << line_count << ": variable: ID LTHIRD expression RTHIRD" << endl << endl;
		 $$ = new vector<SymbolInfo*>();
		 logFile << $1->getKey();
		 $$->push_back($1);

		 /* table->Insert($1); */

		 logFile << $2->getKey() ;
		 $$->push_back($2);

		 for(int i=0;i<$3->size()-1;i++){
			 logFile << $3->at(i)->getKey() ;
			 $$->push_back($3->at(i));
		 }
		 logFile << $4->getKey() << endl << endl;
		 $$->push_back($4);

		 if($3->back()->getReturnType().compare("int") != 0){
			 logFile << "Error at line no. " << line_count << ": Expression inside third brackets not an integer" << endl << endl;
			 errorFile << "Error at line no. " << line_count << ": Expression inside third brackets not an integer" << endl << endl;
			 error_count++;
		 }

		 SymbolInfo* checker = table->lookUp($1);
		 if(checker != nullptr){
			 if(!checker->getIsvar()){
				 logFile << "Error at line no. " << line_count << ": " << checker->getKey() <<  " is not a variable" << endl << endl;
				 errorFile << "Error at line no. " << line_count << ": " << checker->getKey() <<  " is not a variable" << endl << endl;
				 error_count++;
			 }
			 else if(!checker->getIsArray()){
				 logFile << "Error at line no. " << line_count << ": Type mismatch, " << checker->getKey() << " is not an array." << endl << endl;
				 errorFile << "Error at line no. " << line_count << ": Type mismatch, " << checker->getKey() << " is not an array." << endl << endl;
				 error_count++;
			 }
		 }
		 else{
			 logFile << "Error at line no. " << line_count << ": Unrecognized variable " << $1->getKey()  << endl << endl;
			 errorFile << "Error at line no. " << line_count << ": Unrecognized variable " << $1->getKey()  << endl << endl;
			 error_count++;
		 }

		 SymbolInfo* typeInfo = new SymbolInfo();
		 if(checker!=nullptr){
			 typeInfo->setReturnType(checker->getReturnType());
			 string tempVar = checker->getTempVar() + "[DI]";
			 typeInfo->setTempVar(tempVar);
			 typeInfo->setIsArray(true);
			 typeInfo->setArrayLength(checker->getArrayLength());
		 }
		 else{
			 typeInfo->setReturnType("");
		 }
		 string code = $3->back()->getCode();
		 code = code + "MOV DI , " + $3->back()->getTempVar() + "\n\t";
		 code = code + "ADD DI, DI\n\t";
		 typeInfo->setCode(code);
		 typeInfo->setIsVar(true);
		 $$->push_back(typeInfo);
	 }
	 ;

 expression : logic_expression  {
							 logFile << "At line no. " << line_count << ": expression: logic_expression" << endl << endl;
							 $$ = new vector<SymbolInfo*>();
							 for(int i=0;i<$1->size()-1;i++){
								 logFile << $1->at(i)->getKey() << " ";
								 $$->push_back($1->at(i));
							 }

							 logFile << endl << endl;

							 /* $$->push_back($1->back()); */
							 SymbolInfo* typeInfo = new SymbolInfo();
							 typeInfo->setReturnType($1->back()->getReturnType());
							 typeInfo->setVoidErrorPrinted($1->back()->getVoidErroprinted());

							 typeInfo->setCode($1->back()->getCode());
							 typeInfo->setTempVar($1->back()->getTempVar());

							 $$->push_back(typeInfo);
						 }
	   | variable ASSIGNOP logic_expression  {
				  logFile << "At line no. " << line_count << ": expression: variable ASSIGNOP logic_expression" << endl << endl;
				  $$ = new vector<SymbolInfo*>();
		 			for(int i=0;i<$1->size()-1;i++){
		 				logFile << $1->at(i)->getKey() << " ";
		 				$$->push_back($1->at(i));
		 			}

		 			logFile << $2->getKey() << " ";
		 			$$->push_back($2);

		 			for(int i=0;i<$3->size()-1;i++){
		 				logFile << $3->at(i)->getKey() << " ";
		 				$$->push_back($3->at(i));
		 			}

		 			logFile << endl << endl;

					/* logFile << $1->back()->getReturnType() << " " << $3->back()->getReturnType() << endl << endl; */
					/* if($1->back()->getReturnType().compare($3->back()->getReturnType()) != 0){
						logFile << "Error at line no. " << line_count << ": Type mismatch" << endl << endl;
						errorFile << "Error at line no. " << line_count << ": Type mismatch" << endl << endl;
					} */
					//errorFile << $1->back()->getReturnType() ]<< endl;
					/* SymbolInfo* checker = table->lookUp($1->at(0)->getKey()); */
					//cout << $1->at(0)->getKey() << endl;
					if(!$1->back()->getVoidErroprinted() || !$3->back()->getVoidErroprinted()){
						 logFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
						 errorFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
						 error_count++;
					}
					else if($1->back()->getReturnType().compare("int") == 0 && $3->back()->getReturnType().compare("int") != 0 && $3->back()->getReturnType().compare("") != 0 ){
						logFile << "Error at line no. " << line_count << ": Type mismatch" << endl << endl;
						errorFile << "Error at line no. " << line_count << ": Type mismatch" << endl << endl;
						error_count++;
					}
					else if($1->back()->getReturnType().compare("float") == 0 && $3->back()->getReturnType().compare("void") == 0){
						logFile << "Error at line no. " << line_count << ": Type mismatch" << endl << endl;
						errorFile << "Error at line no. " << line_count << ": Type mismatch" << endl << endl;
						error_count++;
					}
					else if($1->back()->getReturnType().compare("void") == 0){
						logFile << "Error at line no. " << line_count << ": Invalid left operand of Assignment operation" << endl << endl;
						errorFile << "Error at line no. " << line_count << ": Invalid left operand of Assignment operation" << endl << endl;
						error_count++;
					}
					SymbolInfo* typeInfo = new SymbolInfo();
					typeInfo->setReturnType($1->back()->getReturnType());
					typeInfo->setVoidErrorPrinted($1->back()->getVoidErroprinted());

					string code = $3->back()->getCode();
					string tempVar = util.newTemp();
					code = code + "MOV AX , " + $3->back()->getTempVar() + "\n\t";
					code = code + "MOV " + tempVar + " , AX\n\t";
					code = code + $1->back()->getCode();
					code = code + "MOV AX , " + tempVar + "\n\t";
					code = code + "MOV " + $1->back()->getTempVar() + " , AX\n\t";

					declaredVars->push_back(tempVar);
					/* SymbolInfo* temp = table->lookUp($1->at(0)->getKey()); */
					/* string tempV = $1->back()->getTempVar();
					string code = "MOV AX, " + $3->back()->getTempVar() + "\n\t";
					code = code + "MOV " + tempV + ",AX\n\t";
					code = $1->back()->getCode() + $3->back()->getCode() + code; */
					typeInfo->setCode(code);
					typeInfo->setTempVar($1->back()->getTempVar());
					$$->push_back(typeInfo);
				}
	   ;

logic_expression : rel_expression  {
										logFile << "At line no. " << line_count << ": logic_expression: rel_expression" << endl << endl;
										$$ = new vector<SymbolInfo*>();
										for(int i=0;i<$1->size()-1;i++){
											logFile << $1->at(i)->getKey() << " ";
											$$->push_back($1->at(i));
										}

										logFile << endl << endl;

										//$$->push_back($1->back());
									  SymbolInfo* typeInfo = new SymbolInfo();
				  			 	  typeInfo->setReturnType($1->back()->getReturnType());
										typeInfo->setVoidErrorPrinted($1->back()->getVoidErroprinted());
										typeInfo->setValue($1->back()->getValue());
										typeInfo->setAssignedValue(true);

										typeInfo->setCode($1->back()->getCode());
										typeInfo->setTempVar($1->back()->getTempVar());

				  				  $$->push_back(typeInfo);

										/* logFile << $1->back()->getReturnType() << " " << $$->back()->getReturnType() << endl; */
									}
		 | rel_expression LOGICOP rel_expression {
				 logFile << "At line no. " << line_count << ": logic_expression: rel_expression LOGICOP rel_expression" << endl << endl;
				 $$ = new vector<SymbolInfo*>();
		 			for(int i=0;i<$1->size()-1;i++){
		 				logFile << $1->at(i)->getKey() << " ";
		 				$$->push_back($1->at(i));
		 			}

	 			logFile << $2->getKey() << " ";
	 			$$->push_back($2);

	 			for(int i=0;i<$3->size()-1;i++){
	 				logFile << $3->at(i)->getKey() << " ";
	 				$$->push_back($3->at(i));
	 			}

	 			logFile << endl << endl;

				SymbolInfo* typeInfo = new SymbolInfo();
				typeInfo->setReturnType("int");
				typeInfo->setVoidErrorPrinted(true);
				typeInfo->setValue(util.getLogicOpValue($1->back()->getValue(), $3->back()->getValue(), $2->getKey()));
				typeInfo->setAssignedValue(true);


				string code = "";
				string tempV = util.newTemp();
				if($2->getKey().compare("&&") == 0){
					code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
					code = code + "CMP AX, 0\n\t";
					string label = util.newLabel();
					code = code + "JE " + label + " \n\t";

					code = code + "MOV AX , " + $3->back()->getTempVar() + "\n\t";
					code = code + "CMP AX, 0\n\t";
					code = code + "JE " + label + " \n\t";
					code = code + "MOV " + tempV + " , 1\n\t";
					string label_1 = util.newLabel();
					code = code + "JMP " + label_1 + "\n";
					code = code + label + ":\n\t";
					code = code + "MOV " + tempV + " , 0\n";
					code = code + label_1 + ":\n\t";

					declaredVars->push_back(tempV);
				}
				else if($2->getKey().compare("||") == 0){
					code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
					code = code + "CMP AX, 0\n\t";
					string label = util.newLabel();
					code = code + "JNE " + label + " \n\t";

					code = code + "MOV AX , " + $3->back()->getTempVar() + "\n\t";
					code = code + "CMP AX, 0\n\t";
					code = code + "JNE " + label + " \n\t";
					code = code + "MOV " + tempV + " , 0\n\t";
					string label_1 = util.newLabel();
					code = code + "JMP " + label_1 + "\n";
					code = code + label + ":\n\t";
					code = code + "MOV " + tempV + " , 1\n";
					code = code + label_1 + ":\n\t";

					declaredVars->push_back(tempV);
				}

				code = $1->back()->getCode() + $3->back()->getCode() + code;
				typeInfo->setTempVar(tempV);
				typeInfo->setCode(code);
				$$->push_back(typeInfo);

				if(!$1->back()->getVoidErroprinted() || !$3->back()->getVoidErroprinted()){
					 logFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
					 errorFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
					 error_count++;
				}
		 }
		 ;

rel_expression	: simple_expression {
										logFile << "At line no. " << line_count << ": rel_expression: simple_expression" << endl << endl;
										$$ = new vector<SymbolInfo*>();
										for(int i=0;i<$1->size()-1;i++){
											logFile << $1->at(i)->getKey() << " ";
											$$->push_back($1->at(i));
										}

										logFile << endl << endl;

										/* $$->push_back($1->back()); */
										SymbolInfo* typeInfo = new SymbolInfo();
				  			 	  typeInfo->setReturnType($1->back()->getReturnType());
										typeInfo->setVoidErrorPrinted($1->back()->getVoidErroprinted());
										typeInfo->setValue($1->back()->getValue());
										typeInfo->setAssignedValue(true);

										typeInfo->setCode($1->back()->getCode());
										typeInfo->setTempVar($1->back()->getTempVar());

				  				  $$->push_back(typeInfo);

										/* logFile << $$->back()->getReturnType() ; */

										/* logFile << $1->back()->getReturnType() << " " << $$->back()->getReturnType() << endl; */
									}
		| simple_expression RELOP simple_expression {
			logFile << "At line no. " << line_count << ": rel_expression: simple_expression RELOP simple_expression" << endl << endl;
			$$ = new vector<SymbolInfo*>();
			for(int i=0;i<$1->size()-1;i++){
				logFile << $1->at(i)->getKey() << " ";
				$$->push_back($1->at(i));
			}

			logFile << $2->getKey() << " ";
			$$->push_back($2);

			for(int i=0;i<$3->size()-1;i++){
				logFile << $3->at(i)->getKey() << " ";
				$$->push_back($3->at(i));
			}

			logFile << endl << endl;

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("int");
			typeInfo->setVoidErrorPrinted(true);
			typeInfo->setValue(util.getRelopValue($1->back()->getValue(), $3->back()->getValue(), $2->getKey()));
			typeInfo->setAssignedValue(true);



			string code = "";
			string tempV = util.newTemp();
			if($2->getKey().compare("<") == 0){
				code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				code = code + "CMP AX," + $3->back()->getTempVar() + "\n\t";
				string label = util.newLabel();
				code = code + "JGE " + label + "\n\t";
				code = code + "MOV " + tempV + " , 1\n\t";
				string label_1 = util.newLabel();
				code = code + "JMP " + label_1 + "\n";
				code = code + label + ":\n\t";
				code = code + "MOV " + tempV + " , 0\n";
				code = code + label_1 + ":\n\t";

				declaredVars->push_back(tempV);
			}
			else if($2->getKey().compare("<=") == 0){
				code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				code = code + "CMP AX," + $3->back()->getTempVar() + "\n\t";
				string label = util.newLabel();
				code = code + "JG " + label + "\n\t";
				code = code + "MOV " + tempV + " , 1\n\t";
				string label_1 = util.newLabel();
				code = code + "JMP " + label_1 + "\n";
				code = code + label + ":\n\t";
				code = code + "MOV " + tempV + " , 0\n";
				code = code + label_1 + ":\n\t";

				declaredVars->push_back(tempV);
			}
			else if($2->getKey().compare(">=") == 0){
				code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				code = code + "CMP AX," + $3->back()->getTempVar() + "\n\t";
				string label = util.newLabel();
				code = code + "JL " + label + "\n\t";
				code = code + "MOV " + tempV + " , 1\n\t";
				string label_1 = util.newLabel();
				code = code + "JMP " + label_1 + "\n";
				code = code + label + ":\n\t";
				code = code + "MOV " + tempV + " , 0\n";
				code = code + label_1 + ":\n\t";

				declaredVars->push_back(tempV);
			}
			else if($2->getKey().compare(">") == 0){
				code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				code = code + "CMP AX," + $3->back()->getTempVar() + "\n\t";
				string label = util.newLabel();
				code = code + "JLE " + label + "\n\t";
				code = code + "MOV " + tempV + " , 1\n\t";
				string label_1 = util.newLabel();
				code = code + "JMP " + label_1 + "\n";
				code = code + label + ":\n\t";
				code = code + "MOV " + tempV + " , 0\n";
				code = code + label_1 + ":\n\t";

				declaredVars->push_back(tempV);
			}
			else if($2->getKey().compare("==") == 0){
				code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				code = code + "CMP AX," + $3->back()->getTempVar() + "\n\t";
				string label = util.newLabel();
				code = code + "JNE " + label + "\n\t";
				code = code + "MOV " + tempV + " , 1\n\t";
				string label_1 = util.newLabel();
				code = code + "JMP " + label_1 + "\n";
				code = code + label + ":\n\t";
				code = code + "MOV " + tempV + " , 0\n";
				code = code + label_1 + ":\n\t";

				declaredVars->push_back(tempV);
			}
			else if($2->getKey().compare("!=") == 0){
				code = code + "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				code = code + "CMP AX," + $3->back()->getTempVar() + "\n\t";
				string label = util.newLabel();
				code = code + "JE " + label + "\n\t";
				code = code + "MOV " + tempV + " , 1\n\t";
				string label_1 = util.newLabel();
				code = code + "JMP " + label_1 + "\n";
				code = code + label + ":\n\t";
				code = code + "MOV " + tempV + " , 0\n";
				code = code + label_1 + ":\n\t";

				declaredVars->push_back(tempV);
			}


			code = $1->back()->getCode() + $3->back()->getCode() + code;
			typeInfo->setCode(code);
			typeInfo->setTempVar(tempV);
			$$->push_back(typeInfo);

			if(!$1->back()->getVoidErroprinted() || !$3->back()->getVoidErroprinted()){
				 logFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
				 errorFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
				 error_count++;
			}
		}
		;

simple_expression : term {
											logFile << "At line no. " << line_count << ": simple_expression: term" << endl << endl;
											$$ = new vector<SymbolInfo*>();
											for(int i=0;i<$1->size()-1;i++){
												logFile << $1->at(i)->getKey() << " ";
												$$->push_back($1->at(i));
											}

											logFile << endl << endl;

											/* $$->push_back($1->back()); */
											SymbolInfo* typeInfo = new SymbolInfo();
					  			 	  typeInfo->setReturnType($1->back()->getReturnType());
											typeInfo->setVoidErrorPrinted($1->back()->getVoidErroprinted());
											typeInfo->setValue($1->back()->getValue());
											typeInfo->setAssignedValue(true);

											typeInfo->setCode($1->back()->getCode());
											typeInfo->setTempVar($1->back()->getTempVar());

					  				  $$->push_back(typeInfo);

											/* logFile << $1->back()->getReturnType() << " " << $$->back()->getReturnType() << endl; */
										}
		  | simple_expression ADDOP term {
				logFile << "At line no. " << line_count << ": simple_expression: simple_expression ADDOP term" << endl << endl;
				$$ = new vector<SymbolInfo*>();
				for(int i=0;i<$1->size()-1;i++){
					logFile << $1->at(i)->getKey() << " ";
					$$->push_back($1->at(i));
				}

				logFile << $2->getKey() << " ";
				$$->push_back($2);

				for(int i=0;i<$3->size()-1;i++){
					logFile << $3->at(i)->getKey() << " ";
					$$->push_back($3->at(i));
				}

				logFile << endl << endl;

				SymbolInfo* typeInfo = new SymbolInfo();
				if($1->back()->getReturnType().compare("float") == 0  || $3->back()->getReturnType().compare("float") == 0 ){

 				 typeInfo->setReturnType("float");
				 typeInfo->setVoidErrorPrinted(true);

 			 }
 			 else{

 				 typeInfo->setReturnType("int");
				 typeInfo->setVoidErrorPrinted(true);

 			 }

			 string temp = util.newTemp();
			 string code = "MOV AX , " + $1->back()->getTempVar() + "\n\t";
			 if($2->getKey().compare("+") == 0){
				 typeInfo->setValue($1->back()->getValue() + $3->back()->getValue());
				 typeInfo->setAssignedValue(true);
				 code = code + "ADD AX, " + $3->back()->getTempVar() + "\n\t";
			 }
			 else{
				 typeInfo->setValue($1->back()->getValue() - $3->back()->getValue());
				 typeInfo->setAssignedValue(true);
				 code = code + "SUB AX, " + $3->back()->getTempVar() + "\n\t";
			 }

			 code = code + "MOV " + temp + " , AX\n\t";
			 code = $1->back()->getCode() + $3->back()->getCode() + code;
			 typeInfo->setCode(code);
			 typeInfo->setTempVar(temp);
			 declaredVars->push_back(temp);

			 $$->push_back(typeInfo);

			 if(!$1->back()->getVoidErroprinted() || !$3->back()->getVoidErroprinted()){
				  logFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
 					errorFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
					error_count++;
			 }
			}
		  ;

term :	unary_expression {
					logFile << "At line no. " << line_count << ": term: unary_expression" << endl << endl;
					$$ = new vector<SymbolInfo*>();
	 			 for(int i=0;i<$1->size()-1;i++){
	 				 logFile << $1->at(i)->getKey() << " ";
	 				 $$->push_back($1->at(i));
	 			 }
				 logFile << endl << endl;

				 /* $$->push_back($1->back()); */
				 SymbolInfo* typeInfo = new SymbolInfo();
				 typeInfo->setReturnType($1->back()->getReturnType());
				 typeInfo->setVoidErrorPrinted($1->back()->getVoidErroprinted());
				 /* if($1->back()->getAssignedValue()){
					 typeInfo->setAssignedValue(true);
					 typeInfo->setValue($1->back()->getValue());
				 } */

				 typeInfo->setAssignedValue(true);
				 typeInfo->setValue($1->back()->getValue());

				 typeInfo->setCode($1->back()->getCode());
				 typeInfo->setTempVar($1->back()->getTempVar());

				 $$->push_back(typeInfo);

				 /* logFile << $1->back()->getReturnType() << " " << $$->back()->getReturnType() << endl; */
				}
     |  term MULOP unary_expression {
			 logFile << "At line no. " << line_count << ": term: term MULOP unary_expression" << endl << endl;
			 $$ = new vector<SymbolInfo*>();
			 for(int i=0;i<$1->size()-1;i++){
				 logFile << $1->at(i)->getKey() << " ";
				 $$->push_back($1->at(i));
			 }
			 logFile << $2->getKey() << " ";
			 $$->push_back($2);
			 for(int i=0;i<$3->size()-1;i++){
				 logFile << $3->at(i)->getKey() << " ";
				 $$->push_back($3->at(i));
			 }

			 logFile << endl << endl;

			 if($2->getKey().compare("%") == 0){
				 SymbolInfo* typeInfo = new SymbolInfo();

				 if($3->back()->getAssignedValue() && $3->back()->getValue() == 0){
					 logFile << "Error at line no. " << line_count << ": Modulus by zero " <<  endl << endl;
					 errorFile << "Error at line no. " << line_count << ": Modulus by zero " <<  endl << endl;
					 error_count++;
				 }
				 else if($1->back()->getReturnType().compare("int") != 0 || $3->back()->getReturnType().compare("int") != 0){
					 logFile << "Error at line no. " << line_count << ": Non-Integer operand on modulus operator " <<  endl << endl;
					 errorFile << "Error at line no. " << line_count << ": Non-Integer operand on modulus operator " <<  endl << endl;
					 error_count++;
				 }
				 else{
					 typeInfo->setValue((int)$1->back()->getValue() %  (int)$3->back()->getValue());
				 }

				 typeInfo->setReturnType("int");
				 typeInfo->setVoidErrorPrinted(true);

				 string temp = util.newTemp();
				 string code = "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				 code = code + "XOR DX, DX\n\t";
				 code = code + "DIV " +$3->back()->getTempVar() + "\n\t";
				 code = code + "MUL " + $3->back()->getTempVar() + "\n\t";
				 code = code + "SUB AX, " + $1->back()->getTempVar() + "\n\t";
				 code = code + "NEG AX\n\t";
				 code = code + "MOV " + temp + " , AX\n\t";
				 code = $1->back()->getCode() + $3->back()->getCode() + code;

				 typeInfo->setCode(code);
				 typeInfo->setTempVar(temp);
				 $$->push_back(typeInfo);
				 declaredVars->push_back(temp);
			 }
			 else if($2->getKey().compare("/") == 0){
				 SymbolInfo* typeInfo = new SymbolInfo();
				 if($3->back()->getAssignedValue() && $3->back()->getValue() == 0){
					 logFile << "Error at line no. " << line_count << ": Division by zero " <<  endl << endl;
					 errorFile << "Error at line no. " << line_count << ": Division by zero " <<  endl << endl;
					 error_count++;
				 }
				 else{
					 typeInfo->setValue($1->back()->getValue() / $3->back()->getValue());
				 }

				 if($1->back()->getReturnType().compare("float") == 0  || $3->back()->getReturnType().compare("float") == 0){
					 typeInfo->setReturnType("float");
				 }
				 else{
					 typeInfo->setReturnType("int");
				 }
				 typeInfo->setVoidErrorPrinted(true);

				 string code = "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				 code = code + "XOR DX, DX\n\t";
				 code = code + "DIV " + $3->back()->getTempVar() + "\n\t";
				 string temp = util.newTemp();
				 code = code + "MOV " + temp + " , AX\n\t";
				 code = $1->back()->getCode() + $3->back()->getCode() + code;
				 typeInfo->setCode(code);
				 typeInfo->setTempVar(temp);
				 declaredVars->push_back(temp);

				 $$->push_back(typeInfo);
			 }
			 else{
				 SymbolInfo* typeInfo = new SymbolInfo();
				 if($1->back()->getReturnType().compare("float") == 0  || $3->back()->getReturnType().compare("float") == 0){
					 typeInfo->setReturnType("float");
				 }
				 else{
					 typeInfo->setReturnType("int");
				 }

				 typeInfo->setValue($1->back()->getValue() * $3->back()->getValue());
				 typeInfo->setVoidErrorPrinted(true);

				 string code = "MOV AX , " + $1->back()->getTempVar() + "\n\t";
				 code = code + "MUL " + $3->back()->getTempVar() + "\n\t";
				 string temp = util.newTemp();
				 code = code + "MOV " + temp + " , AX\n\t";
				 code = $1->back()->getCode() + $3->back()->getCode() + code;
				 typeInfo->setCode(code);
				 typeInfo->setTempVar(temp);
				 declaredVars->push_back(temp);


				 $$->push_back(typeInfo);
			 }
			 /* else if($1->back()->getReturnType().compare("float") == 0  || $3->back()->getReturnType().compare("float") == 0 ){
				 SymbolInfo* typeInfo = new SymbolInfo();
				 typeInfo->setReturnType("float");
				 typeInfo->setVoidErrorPrinted(true);
				 $$->push_back(typeInfo);
			 }
			 else{
				 SymbolInfo* typeInfo = new SymbolInfo();
				 typeInfo->setReturnType("int");
				 typeInfo->setVoidErrorPrinted(true);
				 $$->push_back(typeInfo);
			 } */

			 if(!$1->back()->getVoidErroprinted() || !$3->back()->getVoidErroprinted()){
				  logFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
 					errorFile << "Error at line no. " << line_count << ": Void value used in expression" << endl << endl;
					error_count++;
			 }
		 }
     ;

unary_expression : ADDOP unary_expression {
										logFile << "At line no. " << line_count << ": unary_expression: ADDOP unary_expression " << endl << endl;
										logFile << $1->getKey() << " ";
										$$ = new vector<SymbolInfo*>();
										$$->push_back($1);
										for(int i=0;i<$2->size();i++){
											logFile << $2->at(i)->getKey() << " ";
											$$->push_back($2->at(i));
										}
										logFile << endl << endl;

										SymbolInfo* typeInfo = new SymbolInfo();
										string code = $2->back()->getCode();
										string tempV = util.newTemp();
										if($1->getKey().compare("-") == 0){
											code = code + "MOV AX , " + $2->back()->getTempVar() + " \n\t";
											code = code + "NEG AX\n\t";
											code = code + "MOV " + tempV + " , AX\n\t";
										}
										else{
											code = code + "MOV AX , " + $2->back()->getTempVar() + " \n\t";
											code = code + "MOV " + tempV + " , AX\n\t";
										}
										typeInfo->setCode(code);
										typeInfo->setTempVar(tempV);
										declaredVars->push_back(tempV);
										$$->push_back(typeInfo);
									}
		 | NOT unary_expression {
			 logFile << "At line no. " << line_count << ": unary_expression: NOT unary_expression" << endl << endl;
			 logFile << $1->getKey() ;
			 $$ = new vector<SymbolInfo*>();
			 $$->push_back($1);
			 for(int i=0;i<$2->size();i++){
				 logFile << $2->at(i)->getKey() << " ";
				 $$->push_back($2->at(i));
			 }

			 logFile << endl << endl;

			 SymbolInfo* typeInfo = new SymbolInfo();
			 typeInfo->setReturnType($2->back()->getReturnType());
			 typeInfo->setVoidErrorPrinted($2->back()->getVoidErroprinted());

			 string code = $2->back()->getCode();
			 code = code + "MOV AX , " + $2->back()->getTempVar() + "\n\t";
			 code = code + "NOT AX\n\t";
			 string tempV = util.newTemp();
			 code = code + "MOV " + tempV + " , AX\n\t";
			 typeInfo->setCode(code);
			 typeInfo->setTempVar(tempV);
			 declaredVars->push_back(tempV);
			 $$->push_back(typeInfo);
		 }
		 | factor {
			 logFile << "At line no. " << line_count << ": unary_expression: factor" << endl << endl;
			 $$ = new vector<SymbolInfo*>();
			 for(int i=0;i<$1->size()-1;i++){
				 logFile << $1->at(i)->getKey() << " ";
				 $$->push_back($1->at(i));
			 }
			 logFile << endl << endl;

			 SymbolInfo* typeInfo = new SymbolInfo();
			 typeInfo->setReturnType($1->back()->getReturnType());
			 typeInfo->setVoidErrorPrinted($1->back()->getVoidErroprinted());
			 if($1->back()->getAssignedValue()){
				 typeInfo->setAssignedValue(true);
				 typeInfo->setValue($1->back()->getValue());
			 }
			 typeInfo->setCode($1->back()->getCode());
			 typeInfo->setTempVar($1->back()->getTempVar());
			 $$->push_back(typeInfo);

			 /* logFile << $1->back()->getReturnType() << " " << $$->back()->getReturnType() << endl; */
		 }
		 ;

factor	: variable {
					logFile << "At line no. " << line_count << ": factor: variable" << endl << endl;
					$$ = new vector<SymbolInfo*>();
					for(int i=0;i<$1->size()-1;i++){
						logFile << $1->at(i)->getKey() << " ";
						$$->push_back($1->at(i));
					}

					logFile << endl << endl;

					SymbolInfo* typeInfo = new SymbolInfo();
					typeInfo->setReturnType($1->back()->getReturnType());

					if($1->back()->getReturnType().compare("void") == 0){
						typeInfo->setVoidErrorPrinted(false);
					}
					typeInfo->setCode($1->back()->getCode());
					typeInfo->setTempVar($1->back()->getTempVar());
					$$->push_back(typeInfo);
				}
	| ID LPAREN argument_list RPAREN {
		logFile << "At line no. " << line_count << ": factor: ID LPAREN argument_list RPAREN" << endl << endl;

		/* logFile << $1->getKey() << " " << $1->getFunctionInfo()->getReturnType() << endl << endl; */
		logFile << $1->getKey() << $2->getKey();
		$$ = new vector<SymbolInfo*>();
		$$->push_back($1);

		/* table->Insert($1); */

		$$->push_back($2);
		for(int i=0;i<$3->size();i++){
			logFile << $3->at(i)->getKey() << " ";
			$$->push_back($3->at(i));
		}
		logFile << $4->getKey() << endl << endl;
		$$->push_back($4);
		/* cout << $1->getKey() << endl; */

		SymbolInfo* checker = table->lookUp($1);
		if(checker == nullptr){
			/* cout << $1->getKey() << endl; */
			logFile << "Error at line no. " << line_count << ": " << $1->getKey() << " is not a function" << endl << endl;
			errorFile << "Error at line no. " << line_count << ": " << $1->getKey() << " is not a function" << endl << endl;
			error_count++;

			SymbolInfo* typeInfo = new SymbolInfo();
			typeInfo->setReturnType("");
			$$->push_back(typeInfo);
		}
		else{
			if(checker->getIsFunc()){
				if(!checker->getFuncDefined()){
					logFile << "Error at line no. " << line_count << ": undefined reference to " << checker->getKey() << endl << endl;
					errorFile << "Error at line no. " << line_count << ": undefined reference to " << checker->getKey() << endl << endl;
					error_count++;
				}
				SymbolInfo* typeInfo = new SymbolInfo();
				typeInfo->setReturnType(checker->getReturnType());
				if(checker->getReturnType().compare("void") == 0){
					typeInfo->setVoidErrorPrinted(false);
				}



				//bool commaFound = false;
				vector<SymbolInfo*>* args = new vector<SymbolInfo*>();

				for(int i=0;i<$3->size();i++){
					if($3->at(i)->getType().compare("COMMA") == 0){
						args->push_back($3->at(i-1));
					}

				}
				if($3->size() > 0){
					args->push_back($3->back());
				}


				bool invalidArgNo = false;
				//cout << args->size() << endl;
				if(checker->getFunctionInfo()->getParamCount() != args->size()){
					logFile << "Error at line no. " << line_count << ": Total number of arguments mismatch in function " << checker->getKey() << endl << endl;
					errorFile << "Error at line no. " << line_count << ": Total number of arguments mismatch in function " << checker->getKey() << endl << endl;
					error_count++;
					invalidArgNo = true;
				}

				if(!invalidArgNo){
					vector<SymbolInfo*>* params = checker->getFunctionInfo()->getParameters();
					if(params != nullptr){
						for(int i=0; i<params->size() ;i++){
							if(params->at(i)->getKey().compare("int") == 0 && args->at(i)->getReturnType().compare("int") != 0){
								logFile << "Error at line no. " << line_count << ": Invalid arguments type in " << checker->getKey() << endl << endl;
								errorFile << "Error at line no. " << line_count << ": Invalid arguments type in " << checker->getKey() << endl << endl;
								error_count++;

								break;
							}
							else if(params->at(i)->getKey().compare("float") == 0 && args->at(i)->getReturnType().compare("void") == 0){
								logFile << "Error at line no. " << line_count << ": Invalid arguments type in " << checker->getKey() << endl << endl;
								errorFile << "Error at line no. " << line_count << ": Invalid arguments type in " << checker->getKey() << endl << endl;
								error_count++;

								break;
							}
						}
					}

				}


				vector<string>* temps = checker->getFunctionInfo()->getTempVars();
				string code = "";

				/* for(int i=0;i<checker->getFunctionInfo()->getParamCount();i++){
					cout << checker->getFunctionInfo()->getParameters()->at(i)->getKey() << endl;
				} */

				/* for(int i=0;i<temps->size();i++){
					cout << "ul" << endl;
					cout << temps->at(i) << endl;
				}

				cout << "ul" << endl; */
				string tempPrevCode = "";
				if(!invalidArgNo){
					/* cout << checker->getKey() << endl; */
					int tempIdx = 0;

					for(int i=0; i<$3->size(); i++){
						if($3->at(i)->getType().compare("COMMA") != 0 && $3->at(i)->getTempVar().compare("") != 0){
							code = code + "MOV AX , " + $3->at(i)->getTempVar() + "\n\t";
							code = code + "MOV " + temps->at(tempIdx++) + " , AX\n\t";
							tempPrevCode = tempPrevCode + $3->at(i)->getCode();
							/* cout << $3->at(i)->getTempVar() <<":" << i << endl; */
						}
					}

					/* for(int i=0;i<checker->getFunctionInfo()->getTempVars()->size();i++){
						cout << checker->getFunctionInfo()->getTempVars()->at(i) << endl;
					} */
				}
				/* cout << tempPrevCode << endl; */
				code = code + "CALL " + checker->getKey() + " \n\t";
				string tempV = util.newTemp();
				code  = code + "MOV AX , " + "ret_temp\n\t";
				code = code + "MOV "  + tempV + " , AX\n\t";
				code = tempPrevCode + code;
				declaredVars->push_back(tempV);
				typeInfo->setTempVar(tempV);
				typeInfo->setCode(code);
				$$->push_back(typeInfo);


			}
			else{
				logFile << "Error at line no. " << line_count << ": " << checker->getKey() << " is not a function" << endl << endl;
				errorFile << "Error at line no. " << line_count << ": " << checker->getKey() << " is not a function" << endl << endl;
				error_count++;

				SymbolInfo* typeInfo = new SymbolInfo();
				typeInfo->setReturnType(checker->getReturnType());
				if(checker->getReturnType().compare("void") == 0){
					typeInfo->setVoidErrorPrinted(false);
				}
				$$->push_back(typeInfo);
			}

			/* if(checker->getReturnType().compare("void") == 0){
				checker->getFunctionInfo()->setVoidErrorPrinted(false);
			} */
		}

		/* cout << $1->getKey()  << endl; */

		/* SymbolInfo* typeInfo = new SymbolInfo();
		//cout << $1->getFunctionInfo()->getReturnType() << endl << endl;
		typeInfo->setReturnType($1->getReturnType());
		$$->push_back(typeInfo); */


	}
	| LPAREN expression RPAREN {
		logFile << "At line no. " << line_count << ": factor: LPAREN expression RPAREN" << endl << endl;
		$$ = new vector<SymbolInfo*>();
		logFile << $1->getKey();
		$$->push_back($1);
		for(int i=0;i<$2->size()-1;i++){
			logFile << $2->at(i)->getKey() << " ";
			$$->push_back($2->at(i));
		}

		logFile << $3->getKey() << endl << endl;
		$$->push_back($3);

		SymbolInfo* typeInfo = new SymbolInfo();
		typeInfo->setReturnType($2->back()->getReturnType());
		if($2->back()->getReturnType().compare("void") == 0){
			typeInfo->setVoidErrorPrinted(false);
		}

		string code = $2->back()->getCode();
		typeInfo->setTempVar($2->back()->getTempVar());
		typeInfo->setCode(code);
		$$->push_back(typeInfo);
	}
	| CONST_INT {
		logFile << "At line no. " << line_count << ": factor: CONST_INT" << endl << endl;
		logFile << $1->getKey() << endl << endl;
		$$ = new vector<SymbolInfo*>();
		$$->push_back($1);

		string temp = util.newTemp();
		string code = "MOV " + temp +  " , " + $1->getKey() + "\n\t";
		declaredVars->push_back(temp);

		SymbolInfo* typeInfo = new SymbolInfo();
		typeInfo->setReturnType("int");
		typeInfo->setAssignedValue(true);
		typeInfo->setValue(atof($1->getKey().c_str()));
		typeInfo->setTempVar(temp);
		typeInfo->setCode(code);
		$$->push_back(typeInfo);
		/* table->Insert($1); */
	}
	| CONST_FLOAT {
		logFile << "At line no. " << line_count << ": factor: CONST_FLOAT" << endl << endl;
		logFile << $1->getKey() << endl << endl;
		$$ = new vector<SymbolInfo*>();
		$$->push_back($1);

		string temp = util.newTemp();
		string code = "MOV " + temp +  " , " + $1->getKey() + "\n\t";
		declaredVars->push_back(temp);

		SymbolInfo* typeInfo = new SymbolInfo();
		typeInfo->setReturnType("float");
		typeInfo->setAssignedValue(true);
		typeInfo->setValue(atof($1->getKey().c_str()));
		typeInfo->setTempVar(temp);
		typeInfo->setCode(code);
		$$->push_back(typeInfo);
		/* table->Insert($1); */
	}
	| variable INCOP {
		logFile << "At line no. " << line_count << ": factor: variable INCOP" << endl << endl;
		$$ = new vector<SymbolInfo*>();
		for(int i=0;i<$1->size()-1;i++){
			logFile << $1->at(i)->getKey() << " ";
			$$->push_back($1->at(i));
		}
		logFile << $2->getKey() << endl;
		$$->push_back($2);

		SymbolInfo* typeInfo = new SymbolInfo();
		typeInfo->setReturnType($1->back()->getReturnType());
		if($1->back()->getReturnType().compare("void") == 0){
			typeInfo->setVoidErrorPrinted(false);
		}

		string tempVar = util.newTemp();
		string code = "MOV AX , " + $1->back()->getTempVar() + "\n\t";
		code = code + "MOV " + tempVar + " , AX\n\t";
		code = code + "INC " + $1->back()->getTempVar() + "\n\t";
		code = $1->back()->getCode() + code;

		typeInfo->setCode(code);
		typeInfo->setTempVar(tempVar);

		declaredVars->push_back(tempVar);


		$$->push_back(typeInfo);
	}
	| variable DECOP  {
		logFile << "At line no. " << line_count << ": factor: variable DECOP" << endl << endl;
		$$ = new vector<SymbolInfo*>();
		for(int i=0;i<$1->size()-1;i++){
			logFile << $1->at(i)->getKey() << " ";
			$$->push_back($1->at(i));
		}
		logFile << $2->getKey() << endl;
		$$->push_back($2);

		SymbolInfo* typeInfo = new SymbolInfo();
		typeInfo->setReturnType($1->back()->getReturnType());
		if($1->back()->getReturnType().compare("void") == 0){
			typeInfo->setVoidErrorPrinted(false);
		}

		string tempVar = util.newTemp();
		string code = "MOV AX , " + $1->back()->getTempVar() + "\n\t";
		code = code + "MOV " + tempVar + " , AX\n\t";
		code = code + "DEC " + $1->back()->getTempVar() + "\n\t";
		code = $1->back()->getCode() + code;

		typeInfo->setCode(code);
		typeInfo->setTempVar(tempVar);

		declaredVars->push_back(tempVar);

		$$->push_back(typeInfo);
	}
	;

argument_list : arguments {
									logFile << "At line no. " << line_count << ": argument_list: arguments" << endl << endl;
									$$ = new vector<SymbolInfo*>();
									for(int i=0;i<$1->size();i++){
										logFile << $1->at(i)->getKey() << " ";
										$$->push_back($1->at(i));
										//cout << i << ") " <<  $1->at(i)->getKey() << endl;
									}
									logFile << endl << endl;
									/* SymbolInfo* typeInfo = new SymbolInfo();
									typeInfo->setCode($1->back()->getCode());
									$$->push_back(typeInfo); */

								}
		|           {logFile << "At line no. " << line_count << ": argument_list: " << endl << endl; $$ = new vector<SymbolInfo*>();}
		;

arguments : arguments COMMA logic_expression {
							logFile << "At line no. " << line_count << ": arguments: arguments COMMA logic_expression" << endl << endl;
							$$ = new vector<SymbolInfo*>();
							for(int i=0;i<$1->size();i++){
								logFile << $1->at(i)->getKey() << " ";
								$$->push_back($1->at(i));
							}

							logFile << $2->getKey() << " ";
							$$->push_back($2);

							for(int i=0;i<$3->size();i++){
								logFile << $3->at(i)->getKey() << " ";
								$$->push_back($3->at(i));
							}
							/* SymbolInfo* typeInfo = new SymbolInfo();
							string code = $1->back()->getCode() + $3->back()->getCode();
							typeInfo->setCode(code);
							$$->push_back(typeInfo); */
							logFile << endl << endl;
						}
	      | logic_expression  {
					logFile << "At line no. " << line_count << ": arguments: logic_expression" << endl << endl;
					$$ = new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++){
						logFile << $1->at(i)->getKey() << " ";
						$$->push_back($1->at(i));
					}
					/* SymbolInfo* typeInfo = new SymbolInfo();
					typeInfo->setCode($1->back()->getCode());
					$$->push_back(typeInfo); */
					logFile << endl << endl;
				}
	      ;


%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	yyin=fp;
	yyparse();


	return 0;
}
