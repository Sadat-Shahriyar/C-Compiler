#include <bits/stdc++.h>
#include<fstream>
#include<string>
#include<sstream>

using namespace std;

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



class SymbolInfo
{
private:
    string name = "";
    string type = "";
public:
    SymbolInfo *next = nullptr;

    void setName(string n)
    {
        name = n;
    }
    string getName()
    {
        return name;
    }

    void setType(string t)
    {
        type = t;
    }
    string getType()
    {
        return type;
    }
    ~SymbolInfo()
    {
        if(next) delete next;
    }
};


class ScopeTable
{
private:
    int totalBuckets;
    SymbolInfo **buckets;
    string id;
    int childrenCount = 0;
    int hashFunc(string name)
    {
        int sum = 0;
        for(int i=0; i<name.size(); i++)
        {
            sum += (int)name[i];
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

        cout << endl << "New ScopeTable with id " << id << " created" << endl;
    }

    bool insert(string name, string type)
    {
        int idx = hashFunc(name);
        SymbolInfo *si = lookUp(name);
        if(si != nullptr)
        {
            cout << endl << "<" << name << ", " << type << ">" <<" already exists in current scopeTable" << endl;
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
                itr->next->setName(name);
                itr->next->setType(type);
                cout << endl << "Inserted in ScopeTable #" << id << " at position " << idx << ", " << itrIdx+1 << endl;;
                return true;
            }
            else{
                buckets[idx] = new SymbolInfo();
                buckets[idx]->setName(name);
                buckets[idx]->setType(type);
                cout << endl << "Inserted in ScopeTable #" << id << " at position " << idx << ", " << 0 << endl;;
                return true;
            }

        }

    }

    SymbolInfo *lookUp(string name)
    {
        int idx = hashFunc(name);
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
                if(si->getName().compare(name) == 0)
                {
                    cout << endl << "Found at ScopeTable #" << id << " at position " << idx <<  ", " << itrIdx << endl;
                    return si;
                }
                si = si->next;
                itrIdx++;
            }
            return nullptr;
        }
    }

    bool Delete(string name){
        int idx = hashFunc(name);
        SymbolInfo *si = buckets[idx];
        if(si == nullptr){
            return false;
        }
        else{
            if(si->getName().compare(name) == 0){
                buckets[idx] = buckets[idx]->next;
                si->next = nullptr;
                delete si;
                cout << endl << "Found in ScopeTable #" << id << " at position " << idx << "," << 0 << endl;
                cout << endl << "Deleted entry " << idx << "," << 0 << " from current scope table" << endl;
                return true;
            }
            else{
                int itrIdx = 1;
                SymbolInfo *currentSymbol;
                while(si->next != nullptr){
                    if(si->next->getName().compare(name) == 0){
                        currentSymbol = si->next;
                        si->next = si->next->next;
                        currentSymbol->next = nullptr;
                        delete currentSymbol;
                        cout << endl << "Found in ScopeTable #" << id << " at position " << idx << "," << itrIdx << endl;
                        cout << endl << "Deleted entry " << idx << "," << itrIdx << " from current scope table" << endl;
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
        cout << endl << "ScopeTable: #" << id << endl;
        SymbolInfo *curr;
        for(int i=0;i<totalBuckets;i++){
            cout << i << " --> ";
            curr = buckets[i];
            while(curr != nullptr){
                cout << " <" << curr->getName() << ":" << curr->getType() << "> ";
                curr = curr->next;
            }
            cout << endl;
        }
    }

    ~ScopeTable(){
        delete[] buckets;
        if(parentScope) delete parentScope;
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
        if(currentTable != nullptr){
            string currentId = currentTable->getId();
            int childrenCount = currentTable->getChildrenCount();
            if(childrenCount == 0){
                return currentId + ".1";
            }
            else{
                return currentId + "." + intToString(childrenCount+1);
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
            cout << endl << "Scope table removed with id #" << removedScopeId << endl;
        }
    }


    bool Insert(string name, string type){
        if(currentTable != nullptr){
            return currentTable->insert(name,type);

        }
        return false;
    }


    bool Remove(string name){
        if(currentTable != nullptr){
            return currentTable->Delete(name);
        }
        return false;
    }


    SymbolInfo *lookUp(string name){
        ScopeTable *temp = currentTable;
        SymbolInfo *symbolPointer = nullptr;
        while(temp != nullptr){
            symbolPointer = temp->lookUp(name);
            if(symbolPointer != nullptr){
                return symbolPointer;
            }
            temp = temp->parentScope;
        }
        cout << "Not found" << endl;
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
        }
    }


    ~SymbolTable(){
        if(currentTable) delete currentTable;
    }
};

int main(){
    ifstream file;
    file.open("input.txt");

    int noOfBuckets;
    file>>noOfBuckets;
    SymbolTable st(noOfBuckets);

    char choice;
    string name,type;
    SymbolInfo *si;
    bool result;

    while(file >> choice){

        if(choice == 'I'){
            file >> name >> type;
            cout << endl << choice << " " << name << " " << type << endl;
            st.Insert(name,type);
        }
        else if(choice == 'L'){
            file >> name;
            cout  << endl << choice << " " << name << endl;
            si = st.lookUp(name);
        }
        else if(choice == 'D'){
            file >> name;
            cout  << endl << choice << " " << name << endl;
            result = st.Remove(name);
            if(!result) cout << endl << "Not found" << endl;
        }
        else if(choice == 'P'){
            file >> type;
            cout  << endl << choice << " " << type << endl;
            if(type.compare("A") == 0){
                st.printAllScopeTable();
            }
            else if(type.compare("C") == 0){
                st.printCurrentScopeTable();
            }
        }
        else if(choice == 'S'){
            cout << endl << choice << endl;
            st.enterScope();
        }
        else if(choice == 'E'){
            cout << endl << choice << endl;
            st.exitScope();
        }
    }

    file.close();
    if(si) delete si;
    return 0;
}


