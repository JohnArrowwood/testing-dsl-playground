# Equivalence Class

By definition, an equivalence class is the set of all values that are functionally identical.  Where testing with one option or testing with another will always produce identical results.  Knowing the boundaries of equivalence classes requires knowing implementation details.

You define an equivalence class as a way of saying: when defining a test case, I intend to test with a definitive value that falls into this category.

## Examples

### Pre-declaring and naming an equivalence class

This allows you to define a named object so it can be used in various contexts.

~~~plaintext
equivalence-class <name> {
    // options
}
~~~

### Pre-declaring a variation from another

This lets you copy an existing object as a starting point, give it a new name, and then apply customizations, rather than having to define it all from scratch.

~~~plaintext
equivalence-class <name> is [a|an] <baseline> {
    // customization options
} 
~~~

### Declaring the class inline

Any place where you would normally expect to find an equivalence class <name>, you could also add an inline declaration so you can customize it then and there.

~~~plaintext
<type> <name> {
    <field-name>: one of [ <name> { /* options */ }, . . . ]
}
~~~

## Options

You can add an annotation to an equivalence class to help guide the generation of test cases.  For example, if one input is a negative test case, it doesn't make sense to pair it with other negatives, as one of them is wasted.  

| Attribute  | Meaning |
|------------|---------|
| `definition "<explanation>"` | Documents the boundaries of the equivalence class and the rationale for why all values in that range are equivalent |
| `BDD-text "<text>"` | Defines what the BDD description text should be for this value - TODO: decide if I really want this |
| `default`  | If any input in the group is negative, only generate the default value from that point forwards |
| `positive` | Mark this as a positive or happy-path value |
| `negative` | Mark this as a negative or failure case value |
| `upper-bounds` | Mark this as a special case of the upper bounds |
| `lower-bounds` | Mark it as the lower bounds |
| `malformed` | indicate that it is negative because the format is wrong |
| `out-of-bounds` | flag

## Aliases

While `equivalence-class` should work in most cases, there may be situations where you want something that makes more sense in that context.  For that reason, aliases are provided

* `equivalence-class` - the technical term that best describes what we are declaring
* `possibility` - one possible value of many for a parameter - though all of those possibilities are still equivalence classes
* `variant` - Jokes about the TVA aside, defines this as one variant of possible values.
* `category`

You create an alias like so:

`type <alias-name> is an equivalence-class;`

TODO: Figure out how we can support having identifiers with spaces in them and not freak out the parser
