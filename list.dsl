// syntax:
// "list" <identifier> <list-construction-expression>
// list-construction-expression = part ( "and" part )* ( "except" part )* filter-expression*
// part = value | list-literal | list-object-identifier
// value = numeric-literal | string-literal | identifier
// list-literal = "[" value+ "]"
// filter-expression = ( "limit to" filter-object | "filter by" <list> | "filter by" /regex/flags )*
// "and" joins lists together
// "except" filters out from the left part those items found in the right part
// "filter" applies the filter expression, limiting the list to those that match

list foo = [ "one", "two", "three" ]
list foo = tokens( one two three )           // same result, less chatty syntax
list bar = [ "apple", "banana", "cherry" ]
list foobar = foo and bar                    // [ "one", "two", "three", "apple", "banana", "cherry" ]
list no-banana = foobar except "banana"      // [ "one", "two", "three", "apple", "cherry" ]
list has-an-r = foobar filter by /r/i        // [ "three", "cherry" ]

list red-fruit = [ "apple", "cherry", "cranberry", "guava", "red grape", "watermelon", "pomegranate", "strawberry", "raspberry" ]
list is-red = foobar filter by red-fruit     // [ "apple", "cherry" ]
// or
filter is-red-fruit = value in red-fruit 
list is-red = foobar limit to is-red-fruit   // [ "apple", "cherry" ]