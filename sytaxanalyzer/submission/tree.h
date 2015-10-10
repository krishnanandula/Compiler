#include <iostream>
#include <stdlib.h>
#include <string>
#include <map>
#include <list>
#include <deque>

using namespace std;

#define YYLTYPE yyltype
extern struct yyltype yylloc;

typedef struct yyltype { 
  int timestamp;
  int first_line;
  int first_column;
  int last_line;
  int last_column;
  char *text;
} yyltype;


class Node {
 public:
  Node(yyltype loc);
  Node();
  virtual ~Node() {}

  yyltype* location() { return location_; }
  Node* parent() { return parent_; }

  void set_parent(Node* parent) { parent_ = parent; }

  virtual const char* GetPrintNameForNode() = 0;

  // Print() is deliberately _not_ virtual
  // subclasses should override PrintChildren() instead
  void Print(int indentLevel, const char* label = NULL);
  virtual void PrintChildren(int indentLevel) {}

 protected:
  yyltype* location_;
  Node* parent_;
};


template<class Element>
class List {
 private:
  std::deque<Element> elems;
 public:
  // Create a new empty list
  List() {}
  // Returns count of elements currently in list
  int NumElements() const {
    return elems.size();
  }
  // Returns element at index in list. Indexing is 0-based.
  // Raises an assert if index is out of range.
  Element Nth(int index) const {   
    return elems[index];
  }
  // Inserts element at index, shuffling over others
  // Raises assert if index out of range
  void InsertAt(const Element &elem, int index) {
    elems.insert(elems.begin() + index, elem);
  }
  // Adds element to list end
  void Append(const Element &elem) {
    elems.push_back(elem);
  }
  // Removes element at index, shuffling down others
  // Raises assert if index out of range
  void RemoveAt(int index) {
    elems.erase(elems.begin() + index);
  }

  // These are some specific methods useful for lists of ast nodes
  // They will only work on lists of elements that respond to the
  // messages, but since C++ only instantiates the template if you use
  // you can still have Lists of ints, chars*, as long as you
  // don't try to SetParentAll on that list.
  void SetParentAll(Node *p) {
    for (int i = 0; i < NumElements(); i++) {
      Nth(i)->set_parent(p);
    }
  }

  void PrintAll(int indentLevel, const char *label = NULL) {
  for (int i = 0; i < NumElements(); i++) {
      Nth(i)->Print(indentLevel, label);
    }
  }
};

class Decl : public Node {
 public:
  Decl() {};

};

class Error : public Node {
 public:
  Error() : Node() {}
  const char* GetPrintNameForNode() { return "Error"; } 
};



class Program {
 public:
  Program(List<Decl*> *declList){};
  const char *GetPrintNameForNode() { return "Program"; }
  void PrintChildren(int indent_level);


 protected:
  List<Decl*> *decls_;
};
