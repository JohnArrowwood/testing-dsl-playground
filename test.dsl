// This is the minimum that a test case should include
// will add other properties as I think of them
test case foo-bar {
	intent "what I'm trying to test"
	given "the prerequisites for this test case"
	when "the action that is taken to perform the test"
	then "how to verify that the test is successful"
}

test case other-test {
	intent ...
	given "a %s that ...", identifier, ... ; // supports formatting strings and variable
	when "..."
	then "..."
}

test set meta-foo {
	// one at a time syntax
	include foo-bar;
	
	// all at once syntax, with list literal
	includes [
		foo-bar,
		other-test
	]

	// the list literal can be substituted by a list object
}

// for intent, given, when, then, format is one of
// * <keyword> <string-literal>
// * <keyword> <format-string-literal>, <literal-or-variable> ... 
// * <keyword> [ list of <string-literal> ]
// * <keyword> <object>
// where object is something that can be converted to a string or a collection of strings



