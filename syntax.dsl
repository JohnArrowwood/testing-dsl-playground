* Define a type
    
    type <identifier> [ is <source>[,<source>]] { <definition> }

* Define a generic object

    object <identifier> [ is ... ] { ... }

* Define an object of a specific type

    <type> <identifier> [ is ... ] { ... }

* Curly brackets 
* * serve to group definition elements
* * are optional, you can define an object in one line without them
* * are unnecessary, you can define an object on 100 lines without them
* * if you use them, they must be balanced
* * can be added even after non-bracketed definition elements
* * and non-bracketed definition elements may appear after a closing bracket

* Continue building object definition (e.g. in another file, building on
  one defined at a higher level, etc.)

    extend <identifier> { ... }

* Every object has at least two common properties:
* * .name = object <identifier>
* * .value = the value that you get if you try to convert it to a string
* * * may be set explicitly via `value = <string-expression>`
* * * or by a <string-expression> not prefixed by a keyword
* * * Example: defect JIRA-1234 "Not enforcing request schema"

* Inside an object definition, when you need to set a property
* * value may be the identifier of a previously declared object
* * or may be an inline declaration of that object, optionally omitting the identifier

* String Expressions

    'single-quoted'
    "double-quoted"
    'with-escaped-\'-delimiter'
    """multi-line string"""
    <text>multi-line string</text>
    <code>multi-line string</code>
    <html>multi-line string that may contain HTML tags</html>
    