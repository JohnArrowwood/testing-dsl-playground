// generate a combinatorial explosion of the provided variables
// example:

matrix code {
    param letter = tokens( a b c )
    param digit  = tokens( 1 2 3 )
    param symbol = tokens( ! @ # )
}

// output will be 27 combinations:
// a 1 !, a 1 @, a 1 #
// a 2 !, a 2 @, a 2 #
// a 3 !, a 3 @, a 3 #
// b 1 !, b 1 @, b 1 #
// b 2 !, b 2 @, b 2 #
// b 3 !, b 3 @, b 3 #
// c 1 !, c 1 @, c 1 #
// c 2 !, c 2 @, c 2 #
// c 3 !, c 3 @, c 3 #

// except sometimes you don't need to test every combination, just each combination of two values
// so I really only need to test "a 1", "1 !", and "a !" one time each
// the matrix will by default automatically try and accomplish this, and give you results more like this:

//               a 1 #
//        a 2 @, a 2 #
// a 3 !, a 3 @, a 3 #
//        b 1 @, b 1 #
// b 2 !
// b 3 ! 
// c 1 !, c 1 @, c 1 #
// c 2 ! 
// c 3 !

// a is tested 6 times, instead of 9 times
// b is tested 4 times
// c is tested 5 times
// 1 is tested 6 times
// 2 is tested 4 times
// 3 is tested 5 times
// ! is tested 6 times
// @ is tested 4 times
// # is tested 5 times
// for a grand total of 15 combinations, instead of 27, a savings of almost 45%

matrix <identifier> {

    // defines an internal list named <name>
    // where the "except" clause lets you exclude values from the list when it is pre-defined
    param <name> = <list-expression> 

    // defines an internal list named the same as the provided list object
    // and initialized with the values of that list object
    param <list-object>             

    // if you need to add to or take away from the list, use the first form

    // by default, generates at least one combination that includes each parameter set to every one of its possible values
    // and every combination of values for every pair of parameters

    // still generate every value of <name>
    // but don't worry about having one of each in the output
    ignore param <name> 

    // ignore all pairs, and just try to output each value once
    ignore pairs

    // include all pairs (the default, but useful if building off of another matrix)
    include pairs

    // include only select pairs
    ignore pairs
    include pair param1, param2
    include pair param2, param3

    // same thing specified in reverse
    include pairs  // the default
    ignore pair param1, param3

    // on some rare occasions, it may be desirable to test every combination of three values
    include triplets
    ignore triplet param1, param3, param5

    // but most of the time, you don't want triplets, but you might want a specific triplet
    ignore triplets  // the default
    include triplet param1, param2, param3

    // sometimes, some combinations are invalid and should be skipped
    skip when <boolean-expression>    // omit combination if boolean expression is true
    skip unless <boolean-expression>  // omit combination if boolean expression is false
    valid when <boolean-expression>   // keep combination if boolean expression is true
    valid unless <boolean-expression> // keep combination if boolean expression is false
    // which to use depends on which makes the most sense in the context, and which kind of expression is easier to construct

    // example
    param color = [ "red", "green", "blue" ]
    param fruit = [ "apple", "banana", "cherry" ]
    skip when color == "red" and fruit not in red-fruit  // red-fruit defined elsewhere, as in list.dsl 
    
}

// you can build a matrix, and then build another matrix that filters the first differently
matrix all-combinations {
    ...
}

expression invalid = <expression>
matrix valid-combinations is all-combinations {
    skip when invalid // add conditions to filter out things that should fail
}

matrix invalid-combinations is all-combinations {
    skip unless invalid // only keep those that are invalid
}

// in this situation, you have the all-combinations matrix, which gives you everything
// then you construct a matrix based on it, but add some more conditions