#include <bits/stdc++.h>
#include<fstream>
#include<string>
#include<sstream>

using namespace std;

extern ofstream logFile;
extern ofstream errorFile;
class SymbolInfo;

class Utilities{
public:
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
};



class FunctionInfo{
private:
  string returnType = "";
  int paramCount = 0;
  // bool voidErrorPrinted = true;
  vector<SymbolInfo*>* parameters = nullptr;
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
    // int arrayLength = 0;
    bool assignedValue = false;
    double value;

    bool isFunc = false;
    bool funcDefined = false;
    FunctionInfo* functionInfo = nullptr;
public:
    SymbolInfo *next = nullptr;

    SymbolInfo(){}

    SymbolInfo(string k, string t){
      key = k;
      type = t;
      //cout << util.types.INT << endl;
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

    // void setArrayLength(int v){
    //   arrayLength = v;
    // }
    // int getArrayLength(){
    //   return arrayLength;
    // }

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
