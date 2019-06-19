// an enum is a special kind of list, where values are identifiers, and they have a relative value, and maybe even a literal value

enum foo {
    one
    two
    three
}

// In this case, foo.one < foo.two < foo.three

// you can assign the identifier a value, 

enum foo {
    one = "foo"
    two = "bar"
    three = "blip"
}

// now, foo.one can be converted to the string "foo"

// you can also control the enumeration

enum foo {
    ord 1 one
    two
    three
    // skip four
    ord 5 five
}

// now the values can be converted to their ordinal values, e.g. foo.two == 2