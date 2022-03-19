#include <bits/stdc++.h>
#include<fstream>
#include<string>
#include<sstream>
#include <iostream>
#include <algorithm>

using namespace std;

extern ofstream logFile;
extern ofstream errorFile;
class SymbolInfo;

class Utilities{
private:
  int tempVarCount = 0;
  int labelCount = 0;
  int arrTempVarCount = 0;
public:

  bool is_number(const std::string& s)
  {
    std::string::const_iterator it = s.begin();
    while (it != s.end() && std::isdigit(*it)) ++it;
    return !s.empty() && it == s.end();
  }
  
  vector<string> tokenizer(string line, char delimeter){
      vector <string> tokens;

      stringstream str(line);

      string temp;

      while(getline(str, temp, delimeter))
      {
          tokens.push_back(temp);
      }

      return tokens;
  }

  string trim(const string &s)
  {
    auto start = s.begin();
    while (start != s.end() && isspace(*start)) {
        start++;
    }

    auto end = s.end();
    do {
        end--;
    } while (distance(start, end) > 0 && isspace(*end));

    return string(start, end + 1);
  }

  string intToString(int value){
      stringstream ss;
      ss << value;
      string stringValue;
      ss>>stringValue;
      return stringValue;
  }

  int stringToInt(string s){
    stringstream sti(s);
    int intVal;
    sti >> intVal;
    return intVal;
  }


  string getPrintProcedure(){
  	string printProc = "";
  	printProc += "PRINT PROC\n\t";
  	printProc += "; this procedure will display a decimal number\n\t";
  	printProc += "; input : AX\n\t";
    printProc += "PUSH AX                        ; push AX onto the STACK\n\t";
  	printProc += "PUSH BX                        ; push BX onto the STACK\n\t";
  	printProc += "PUSH CX                        ; push CX onto the STACK\n\t";
  	printProc += "PUSH DX                        ; push DX onto the STACK\n\t";
    printProc += "MOV AX, print_var              ; move the print value into AX\n\t";
  	printProc += "CMP AX, 0                      ; compare AX with 0\n\t";
  	printProc += "JGE @START                     ; jump to label @START if AX>=0\n\t";
  	printProc += "PUSH AX                        ; push AX onto the STACK\n\n\t";
  	printProc += "MOV AH, 2                      ; set output function\n\t";
  	printProc += "MOV DL, '-'                    ; set DL='-'\n\t";
  	printProc += "INT 21H                        ; print the character\n\n\t";
  	printProc += "POP AX                         ; pop a value from STACK into AX\n\n\t";
  	printProc += "NEG AX                         ; take 2's complement of AX\n\n\t";
  	printProc += "@START:                        ; jump label\n\n\t";
  	printProc += "XOR CX, CX                     ; clear CX\n\n\t";
  	printProc += "MOV BX, 10                     ; set BX=10\n\n\t";
  	printProc += "@OUTPUT:                       ; loop label\n\t";
  	printProc += "XOR DX, DX                   ; clear DX\n\t";
  	printProc += "DIV BX                       ; divide AX by BX\n\t";
  	printProc += "PUSH DX                      ; push DX onto the STACK\n\t";
  	printProc += "INC CX                       ; increment CX\n\t";
  	printProc += "OR AX, AX                    ; take OR of Ax with AX\n\t";
  	printProc += "JNE @OUTPUT                    ; jump to label @OUTPUT if ZF=0\n\n\t";
  	printProc += "MOV AH, 2                      ; set output function\n\n\t";
  	printProc += "@DISPLAY:                      ; loop label\n\t";
  	printProc += "POP DX                       ; pop a value from STACK to DX\n\t";
  	printProc += "OR DL, 30H                   ; convert decimal to ascii code\n\t";
  	printProc += "INT 21H                      ; print a character\n\t";
  	printProc += "LOOP @DISPLAY                  ; jump to label @DISPLAY if CX!=0\n\t";
  	printProc += "POP DX                         ; pop a value from STACK into DX\n\t";
  	printProc += "POP CX                         ; pop a value from STACK into CX\n\t";
  	printProc += "POP BX                         ; pop a value from STACK into BX\n\t";
    printProc += "POP AX                         ; pop a value from STACK into AX\n\t";
    printProc += "LEA DX, newline               ;print newline\n\t";
    printProc += "MOV AH,9\n\t" ;
    printProc += "INT 21h\n\t";
  	printProc += "RET\nPRINT ENDP\n\n";

  	return printProc;
  }

  string getVarPostfix(string scopeId){
    vector<string> values = tokenizer(scopeId, '.');
    string postfix = "";
    for(int i=0;i<values.size();i++){
      postfix = postfix + "_" + values.at(i);
    }
    return postfix;
  }

  int getRelopValue(double val1, double val2, string relop){
    if(relop.compare("<") == 0){
      return val1 < val2;
    }
    else if(relop.compare("<=") == 0){
      return val1 <= val2;
    }
    else if(relop.compare(">") == 0){
      return val1>val2;
    }
    else if(relop.compare(">=") == 0){
      return val1 >= val2;
    }
    else if(relop.compare("==") == 0){
      return val1 == val2;
    }
    else if(relop.compare("!=") == 0){
      return val1 != val2;
    }
    else return 0;
  }


  int getLogicOpValue(double val1, double val2, string relop){
    if(relop.compare("&&") == 0){
      return val1 && val2;
    }
    else if(relop.compare("||") == 0){
      return val1 || val2;
    }
    else return 0;
  }

  string newTemp(){
    string tempVar = "t" + intToString(tempVarCount);
    tempVarCount++;
    return tempVar;
  }

  string newArrayTemp(){
    string tempVar = "a" + intToString(arrTempVarCount);
    arrTempVarCount++;
    return tempVar;
  }

  string newLabel(){
    string tempLabel = "L" + intToString(labelCount);
    labelCount++;
    return tempLabel;
  }

};



class FunctionInfo{
private:
  string returnType = "";
  int paramCount = 0;
  // bool voidErrorPrinted = true;
  vector<SymbolInfo*>* parameters = nullptr;
  vector<string>* tempVars = nullptr;
public:
  void setReturnType(string v){
    returnType = v;
  }

  string getReturnType(){
    return returnType;
  }

  void setParamCount(int v){paramCount=v;}
  int getParamCount(){return paramCount;}

  void setParameters(vector<SymbolInfo*>* v){
    parameters = v;
  }
  vector<SymbolInfo*>* getParameters(){
    return parameters;
  }

  void setTempVars(vector<string>* v){
    tempVars = v;
  }
  vector<string>* getTempVars(){
    return tempVars;
  }


};


class SymbolInfo
{
private:
    string key = "";
    string type = "";
    string returnType = "";
    bool voidErrorPrinted = true;

    bool isVar = false;
    bool isArray = false;
    int arrayLength = 0;
    bool assignedValue = false;
    double value;

    bool isFunc = false;
    bool funcDefined = false;
    FunctionInfo* functionInfo = nullptr;
    string tempVar = "";  //temporary variable used in assembly code


    string code = "";
public:
    SymbolInfo *next = nullptr;

    SymbolInfo(){}

    SymbolInfo(string k, string t){
      key = k;
      type = t;
      //cout << util.types.INT << endl;
    }

    void setTempVar(string v){
      tempVar = v;
    }
    string getTempVar(){
      return tempVar;
    }

    void setKey(string n)
    {
        key = n;
    }
    string getKey()
    {
        return key;
    }

    void setType(string t)
    {
        type = t;
    }
    string getType()
    {
        return type;
    }
    bool getIsvar(){
      return isVar;
    }
    void setIsVar(bool v){
      isVar = v;
    }

    bool getAssignedValue(){
      return assignedValue;
    }

    void setAssignedValue(bool v){
      assignedValue = v;
    }

    void setValue(double v){
      value = v;
    }
    double getValue(){return value;}

    bool getIsFunc(){
      return isFunc;
    }

    void setIsFunc(bool v){
      isFunc = v;
    }

    void setFunctionInfo(FunctionInfo* func){
      functionInfo = func;
    }

    FunctionInfo* getFunctionInfo(){
      return functionInfo;
    }

    void setFuncDefined(bool v){
      funcDefined = v;
    }

    bool getFuncDefined(){
      return funcDefined;
    }

    void setReturnType(string v){
      returnType = v;
    }
    string getReturnType(){
      return returnType;
    }

    void setIsArray(bool v) {
      isArray = v;
    }
    bool getIsArray(){
      return isArray;
    }

    void setArrayLength(int v){
      arrayLength = v;
    }
    int getArrayLength(){
      return arrayLength;
    }

    void setVoidErrorPrinted(bool v){
      voidErrorPrinted = v;
    }
    bool getVoidErroprinted(){
      return voidErrorPrinted;
    }

    ~SymbolInfo()
    {
        if(next) next = nullptr;
    }

    void setCode(string c){
      code = c;
    }

    string getCode(){
      return code;
    }
};


class ScopeTable
{
private:
    int totalBuckets;
    SymbolInfo **buckets;
    string id;
    int childrenCount = 0;
    int hashFunc(string key)
    {
        int sum = 0;
        for(int i=0; i<key.size(); i++)
        {
            sum += (int)key[i];
        }
        return sum%totalBuckets;
    }

public:
    ScopeTable *parentScope = nullptr;

    void setId(string i){
        id = i;
    }
    string getId(){return id;}

    void setChelidrenCount(int cnt){
        childrenCount = cnt;
    }
    int getChildrenCount(){
        return childrenCount;
    }

    ScopeTable(int bucketsNo, string i)
    {
        totalBuckets = bucketsNo;
        buckets = new SymbolInfo*[bucketsNo];
        for(int i=0; i<bucketsNo; i++)
        {
            buckets[i] = nullptr;
        }

        id = i;

        //cout << endl << "New ScopeTable with id " << id << " created" << endl;
    }

    bool insert(SymbolInfo* input){
      int idx = hashFunc(input->getKey());
      SymbolInfo *si = lookUp(input->getKey());
      if(si != nullptr)
      {
          //logFile << endl << key <<" already exists in current scopeTable" << endl;
          return false;
      }

      else
      {
          int itrIdx = 0;
          SymbolInfo *itr = buckets[idx];
          if(itr != nullptr)
          {
              while(itr->next != nullptr)
              {
                  itr = itr->next;
                  itrIdx++;
              }
              itr->next = input;
              //cout << endl << "Inserted in ScopeTable #" << id << " at position " << idx << ", " << itrIdx+1 << endl;;
              return true;
          }
          else{
              buckets[idx] = input;
              //cout << endl << "Inserted in ScopeTable #" << id << " at position " << idx << ", " << 0 << endl;;
              return true;
          }

      }
    }

    bool insert(string key, string type)
    {
        int idx = hashFunc(key);
        SymbolInfo *si = lookUp(key);
        if(si != nullptr)
        {
            //logFile << endl << key <<" already exists in current scopeTable" << endl;
            return false;
        }
        else
        {
            int itrIdx = 0;
            SymbolInfo *itr = buckets[idx];
            if(itr != nullptr)
            {
                while(itr->next != nullptr)
                {
                    itr = itr->next;
                    itrIdx++;
                }
                itr->next = new SymbolInfo();
                itr->next->setKey(key);
                itr->next->setType(type);
                //cout << endl << "Inserted in ScopeTable #" << id << " at position " << idx << ", " << itrIdx+1 << endl;;
                return true;
            }
            else{
                buckets[idx] = new SymbolInfo();
                buckets[idx]->setKey(key);
                buckets[idx]->setType(type);
                //cout << endl << "Inserted in ScopeTable #" << id << " at position " << idx << ", " << 0 << endl;;
                return true;
            }

        }

    }

    SymbolInfo *lookUp(string key)
    {
        int idx = hashFunc(key);
        if(buckets[idx] == nullptr)
        {
            return nullptr;
        }
        else
        {
            int itrIdx = 0;
            SymbolInfo *si;
            si = buckets[idx];
            while(si != nullptr)
            {
                if(si->getKey().compare(key) == 0)
                {
                    //cout << endl << "Found at ScopeTable #" << id << " at position " << idx <<  ", " << itrIdx << endl;
                    return si;
                }
                si = si->next;
                itrIdx++;
            }
            return nullptr;
        }
    }

    bool Delete(string key){
        int idx = hashFunc(key);
        SymbolInfo *si = buckets[idx];
        if(si == nullptr){
            return false;
        }
        else{
            if(si->getKey().compare(key) == 0){
                buckets[idx] = buckets[idx]->next;
                si->next = nullptr;
                delete si;
                //cout << endl << "Found in ScopeTable #" << id << " at position " << idx << "," << 0 << endl;
                //cout << endl << "Deleted entry " << idx << "," << 0 << " from current scope table" << endl;
                return true;
            }
            else{
                int itrIdx = 1;
                SymbolInfo *currentSymbol;
                while(si->next != nullptr){
                    if(si->next->getKey().compare(key) == 0){
                        currentSymbol = si->next;
                        si->next = si->next->next;
                        currentSymbol->next = nullptr;
                        delete currentSymbol;
                        //cout << endl << "Found in ScopeTable #" << id << " at position " << idx << "," << itrIdx << endl;
                        //cout << endl << "Deleted entry " << idx << "," << itrIdx << " from current scope table" << endl;
                        return true;
                    }
                    si = si->next;
                    itrIdx++;
                }
                return false;
            }
        }
    }

    void print(){
        logFile << endl << "ScopeTable: #" << id << endl;
        SymbolInfo *curr;
        for(int i=0;i<totalBuckets;i++){
            if(buckets[i]){
            logFile << i << " --> ";
	        curr = buckets[i];
	        while(curr != nullptr){
	            logFile << " <" << curr->getKey() << ":" << curr->getType() << "> ";
	            curr = curr->next;
	        }
	        logFile << endl;
            }

        }
        //logFile << endl;
    }

    ~ScopeTable(){
        delete[] buckets;
        if(parentScope) parentScope = nullptr;
        logFile << "Scopetable with id " << id << " removed." << endl << endl;
    }
};

class SymbolTable{
private:
    int bucketNo;
public:
    ScopeTable *currentTable;


    SymbolTable(int n){
        currentTable = new ScopeTable(n,"1");
        bucketNo = n;
    }

    string getNewScopeId(){
        Utilities util;
        if(currentTable != nullptr){
            string currentId = currentTable->getId();
            int childrenCount = currentTable->getChildrenCount();
            if(childrenCount == 0){
                return currentId + ".1";
            }
            else{
                return currentId + "." + util.intToString(childrenCount+1);
            }
        }
        else{
            return "1";
        }
    }

    void enterScope(){
        if(currentTable == nullptr){
            string id = getNewScopeId();
            currentTable = new ScopeTable(bucketNo,id);
        }

        else{
            ScopeTable *st;
            string id = getNewScopeId();
            st = new ScopeTable(bucketNo,id);
            st->parentScope = currentTable;
            currentTable->setChelidrenCount(currentTable->getChildrenCount()+1);
            currentTable = st;
        }
    }

    void exitScope(){
        if(currentTable != nullptr){
            ScopeTable *temp = currentTable;
            string removedScopeId = currentTable->getId();
            currentTable = currentTable->parentScope;
            temp->parentScope = nullptr;
            delete temp;
            //cout << endl << "Scope table removed with id #" << removedScopeId << endl;
        }
    }


    bool Insert(SymbolInfo* si){
      if(currentTable != nullptr){
        return currentTable->insert(si);
      }
      return false;
    }

    bool Insert(string key, string type){
        if(currentTable != nullptr){
            return currentTable->insert(key,type);
        }
        return false;
    }


    bool Remove(string key){
        if(currentTable != nullptr){
            return currentTable->Delete(key);
        }
        return false;
    }

    SymbolInfo* lookUp(SymbolInfo* si){
      string key = si->getKey();
        ScopeTable *temp = currentTable;
        SymbolInfo *symbolPointer = nullptr;
        while(temp != nullptr){
            symbolPointer = temp->lookUp(key);
            if(symbolPointer != nullptr){
                return symbolPointer;
            }
            temp = temp->parentScope;
        }
        //cout << "Not found" << endl;
        return nullptr;
    }


    SymbolInfo* lookUp(string key){
        ScopeTable *temp = currentTable;
        SymbolInfo *symbolPointer = nullptr;
        while(temp != nullptr){
            symbolPointer = temp->lookUp(key);
            if(symbolPointer != nullptr){
                return symbolPointer;
            }
            temp = temp->parentScope;
        }
        //cout << "Not found" << endl;
        return nullptr;
    }


    void printCurrentScopeTable(){
        if(currentTable != nullptr){
            currentTable->print();
        }
    }


    void printAllScopeTable(){
        if(currentTable != nullptr){
            ScopeTable *temp = currentTable;
            while(temp != nullptr){
                temp->print();
                temp = temp->parentScope;
            }

            logFile << endl << endl;
        }
    }


    ~SymbolTable(){
        if(currentTable) delete currentTable;
    }
};
