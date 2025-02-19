# Quick Reference

## Block

There are single-statement blocks:

~~~plaintext
<statement>;
~~~

There are multi-statement blocks:

~~~plaintext
{
    <statement>;
    <statement>;
}
~~~

A block can be a whole statement in its own right (exactly as you see above), or it may be a parameter in a larger construct, like:

~~~plaintext
if <condition> then <block> else <block>
~~~

You may pre-declare a block and give it a name, like so:

~~~plaintext
define MeaningfulBlockName as <less-meaningful-statement>; 
define SequenceName as {
    <statement>;
    <statement>;
}
~~~

This allows you to make your design self-documenting.  Then any place where a block is needed, you can either inject the necessary statements directly, or reference the pre-defined block by name, subject to scoping rules.

As with some languages (Perl, JavaScript), the trailing semicolon is optional for the last statement in a multi-statement block.

## Call

If a single statement is the name of a pre-defined multi-statement block, evaluation proceeds in much the same way as a function call in a traditional language.  When that named block returns, flow continues with the next statement in the enclosing scope.  

If the block-name does not exist, it is treated as an empty block, effectively a no-op, and test generation continues.  This allows you to describe behavior without having to include unnecessary declarations.  HOWEVER, this can bite you if you make a typo.

~~~plaintext
<block-name>; // effectively include by reference the behavior defined by block-name
~~~

This should be used liberally, to make the design self-documenting.

NOTE: if that block is defined inside of another object or block, you should be able to navigate to that block using standard dot notation.

~~~plaintext
define foo {
    define bar {
        DoThis;
        DoThat;
    }
}
define baz {
    foo.bar;
    DontGetCaught;
}
~~~

## Return

Exit a block without executing the rest of the statements in the block.  Intended only for use in a conditional.  This does NOT signal that the current path is invalid.

~~~plaintext
if UserIsAuthenticated == NO then return;
~~~

## Reject

Exit the enclosing block (like return) signalling that the current path is invalid, and a backtrack is required.

~~~plaintext
if <condition> then reject; // this flow is invalid, try again with different parameters
~~~

## End

This signals that a process is done, so test generation ends here.  

Can use either `end` or `exit` or `terminate`;

~~~plaintext
if <condition> then end;
~~~

or

~~~plaintext
define SomeLogicalProcess {
    Step1;
    Step2;
    Step3;
    . . .
    end;  // explicitly mark this as the end of the process
}
~~~

If your model is build correctly, you shouldn't need an explicit `end` at the end.

You probably want to model certain success and error flows explicitly:

~~~plaintext
define Return_200_OK {
    set ResponseCode to 200;
    set ResponseReason to OK;
    ReturnResponse;
    end;  // flow ends here
}
~~~

or

~~~plaintext
define Return_404_NotFound {
    set ResponseCode to 404;
    set ResponseReason to NotFound;
    ReturnResponse;
    end;  // flow ends here
}
~~~

## End With `block`

If you say `end with <block>` you are basically saying:

~~~plaintext
{
    <block>
    end;
}
~~~

This is optional syntactic sugar, and replicates `exec` in a shell script.  Control transfers to `block` and does not return.

## Conditionals

The language supports traditional conditional statements:

~~~plaintext
if <condition> then <block> else <block>
switch <variable> {
    case [<operation>] <value>: <block>
    default: <block>
}
~~~

The `else <block>` is optional.  In both cases, the block may be either a single statement block (no curly braces) or a multi-statement block.

Syntax resembles C/Java/JavaScript style if-then-else, so curly braces are optional if the block is a single statement.  If the full if-then-else ends in a single-statement block, a trailing semicolon is needed.  If it ends in a multi-statement block, no semicolon is required.

~~~plaintext
if <condition> then statement;                         // semicolon required
if <condition> then statement else statement;          // required
if <condition> then { statement; } else statement;     // required
if <condition> then { statement; }                     // no trailing semicolon required
if <condition> then statement else { statement; }      // not required
if <condition> then { statement; } else { statement; } // not required
~~~

In most languages, a `switch-case` assumes that the operation is `==`.  This language will, too, if you do not provide an operation.  But unlike other languages, it allows you to provide any conditional operator and apply that.  For example:

~~~plaintext
switch <variable> {
    case == FOO: <block>
    case != BAR: <block> // implicitly, variable is not FOO and not BAR
    default: <default-block>
}
~~~

A switch is internally represented as a series of if statements:

~~~plaintext
if <variable> == FOO then <block>
else if <variable> != BAR then <block>
else <default-block>
~~~

### Many Ways to Say It

In English, there's always more than one way to say something.  Since this language seeks to be as English-like as possible, we chose to support multiple constructs for conditionals:

* `if <condition> then <block>` - evaluate block only if condition is true
* `when <condition> then <block>` - evaluate block only if condition is true
* `unless <condition> then <block>` - evaluate block only if condition is false
* `<statement> if <condition>;` - evaluate statement only if condition is true
* `<statement> when <condition>;` - evaluate statement only if condition is true
* `<statement> unless <condition>;` - evaluate statement only if condition is false

NOTE: I may not support all of these, we shall see.

## Equivalence Class

Declare an equivalence class `name` and annotate it with flags that can help shape test case generation.

~~~plaintext
equivalence-class Valid { positive; default; }
equivalence-class Invalid { negative; }
equivalence-class Upper-Bounds { positive; upper-bounds; }
equivalence-class Lower-Bounds { positive; lower-bounds; }
~~~

See [Equivalence Class](equivalence-class.md).

## Variable

Declare a variable `name` and its possible values (equivalence classes).  Values are pre-defined elsewhere or defined inline.

~~~plaintext
variable <name> {
    is one of [ Valid, Invalid, Upper-Bounds, Lower-Bounds ];
    constraints { . . . }
}
~~~

Alternative names for a variable include:

* `possibility`

Inside of a behavior block, you can list variables as a way of stating dependencies and annotating what kind of dependency they are.  For example:

* `depends on <identifier>` - a generic dependency marker
* `input <identifier>` - a generic input marker
* `user input <identifier>` means this represents DIRECT user inputs - you could just as easily say `direct input`
* `direct input <identifier>` means that the variable models the equivalence classes associated with a formal parameter
* `indirect input <identifier>` means something not provided by the user but is obtained from elsewhere, such as a configuration or a database record.  An alias for this is `system state`.
* `semantic input <identifier>` means something that is not typically thought of as part of the request, but most definitely IS part of the request, and may have an influence on behavior.  As an example, HTTP method and/or headers can influence how a request is processed.
* `output <identifier>` - this is where we will write the result of the operation

You can also create a local variable whose value is a copy of a global variable:

~~~plaintext
indirect input LockedOut is AuthenticationUserLockoutState;
~~~

Why you might want to do this?  When you want to be able to modify the local variable without modifying the global state.  WARNING: if you are doing that, you might be making your model too complex for its own good.  You have been warned.

Note that you can also mimic a variable by explicitly defining the alternatives in a way that makes sense:

~~~plaintext
direct input foobar is one of [ foo, bar, baz ];
~~~

That only works if you need no constraints.

## State Changes

Variables represent the state of the system.  If a flow alters the state of the system, the model needs a way of expressing that.  It is typically meant to be part of a conditional.

~~~plaintext
if <condition> then <variable> = <value>;
~~~

More English like constructs are allowed, as well:

~~~plaintext
if <condition> then set <variable> to <value>;
if <condition> then update <variable> to <value>;
if <condition> then assign <value> to <variable>;
~~~

## Constraints

Variables do not necessarily represent implementation variables, but conditions on which business logic depends.  When you have multiple variables, some combinations of variables may be impossible.  Constraints let you identify those impossible combinations and exclude them from consideration.

A constraint is syntactic sugar.  The condition, by itself:

~~~plaintext
<condition>;
~~~

or prefixed by the keyword `assume` to make it more clear what is happening:

~~~plaintext
assume <condition>;
~~~

Under the covers, both of these map to:

~~~plaintext
if <condition> then reject;
~~~

Similarly, conditional constraints are just a conditional with a constraint for the `then` block:

~~~plaintext
if <condition> then <constraint>;
~~~

Under the covers, this maps to:

~~~plaintext
if <condition> then if <condition> then reject;
~~~

### Constraint Condition

A constraint is a boolean expression:

~~~plaintext
<variable> <operator> <operand>
~~~

Operator supports the usual:

* `==` or `is` or `equals` for equality check
* `!=` or `is not` or `not equal to` for inequality check
* `in [ list ]` or `in <variable>` to check if value is one of a defined list

Note: `in <variable>` only makes sense if there are two different variables that share equivalence classes.

The expression is a boolean expression, so you may use parenthesis and logical operators

* `and`, `&&`, `&` for logical and
* `or`, `||`, `|` for logical or

### Constraint Debugging

Every time a combination violates a constraint, the default behavior is to silently end test flow generation at that statement and backtrack and try again with a different combination.  

Your design isn't guaranteed to be correct on the first try.  Several mechanisms are provided to help you debug.

#### Assumptions

* Declare a block that exercises the target feature
* Insert assumptions at the head of the block to limit the scope to a subset of the feature behavior landscape
* Run test generation
* Inspect the generated test cases for unexpected or unreasonable flows

For example:

~~~plaintext
define LoginHappyPaths {
    assume Username is ValidUser;
    assume Password is ValidPassword;
    Login;
}
~~~

Then you can try changing assumptions and regenerating test flows to see what other flows appear.

#### Tracing

Inside a model component, you might be curious which combinations of inputs are being filtered out.  

~~~plaintext
trace when not <constraint>;
~~~

Whenever `constraint` is violated, instead of just silently backtracking, it triggers the output of the current test flow which was rejected, so you can get a list of all of the flows that made it to a certain point, but were rejected.

Alternative syntax might be:

* `warn when not <constraint>`
* `notify when not <constraint>`
* `notify unless <constraint>`
* `<constraint> expected` - this on would probably require parenthesis

#### Assertions

You can mark a constraint as an assertion.  If this constraint is ever violated, halt test generation and output the flow that violated the constraint.

~~~plaintext
assert <constraint>;
~~~

Do this when you are absolutely certain that the rest of the model should be protecting this feature from experiencing that condition.  The fact that this constraint was violated means that there is an issue with other parts of your model.

## for each

Conceptually, you might want to describe behavior as iterating over a collection and describe what happens for each element.  This is not an algorithm description, just syntactic sugar to make the text read more like English.

~~~plaintext
if OrderList is not empty then for each: <statement>;
~~~

Alternatively, if you want to specify a block:

~~~plaintext
if OrderList is not empty then for each {
    <statement>;
    <statement>;
}
~~~

CAUTION!  This does not actually iterate!  It allows you to DESCRIBE what the application will do.  

// TODO: I may need to strike this from the language.  That is TBD

## Event Modeling

Some software, especially in the browser, can be event driven.  User interactions trigger events.  Those events propagate up the DOM.  Listeners are attached to various DOM elements, looking for specific messages.  When a match is found, that listener is invoked with the event object, and the handler can do what needs to be done.

If events are processed synchronously, it's easy (albeit tedious) to model that using the DSL as defined.  You declare a named block whose contents are the list of event handlers, in order.

The problem is, in event driven software, they are usually asynchronous.  Modeling that requires doing things a little differently.

### Defining Events

An Event is just an object, like any other.

~~~plaintext
event <identifier> { . . . }
~~~

You can then declare event handlers:

~~~plaintext
define <identifier> {
    handles <event-identifier>;

    DoThis;
    DoThat;
}
~~~

### Delivering Events

Under the covers, at parse/validate time, the `handles` statement triggers the registration of a listener for that event.  However, that node is omitted from the internal data structure that is used for execution, or the execution engine treats that node as a no-op.

Later, you trigger an event:

~~~plaintext
define Something {
    DoThis;
    raise event EventName [sync|synchronous|async|asynchronous];
    DoThat;
    DoSomethingElse;
    process events;
}
~~~

`raise event` behaves differently if it is sync or async.  If it is synchronous, it immediately calls all handlers.  If it is asynchronous, then it emulates an event being added to the queue.  Once the current thread terminates, then the events can be delivered.

The problem is, if you don't say `process events` the model will never know when to simulate that, and the model will be incomplete.  Figuring out where to put it requires careful planning.  Hint: you need it at the end of any block triggered by `process events`.  Let me explain:

Say you have an event-based system.  You need to test what happens when a particular event is issued.  You would define your event and all the handlers.  Then you create a test entry point:

~~~plaintext
define MyEventTest {
    raise event MyEvent;
    process events;
}
~~~

During test generation, the `raise event` will push the referenced event into a special execution context variable which represents the event queue.  `process events` then does the following:

* Inspect the queue.  If it's empty, this is a no-op.
* Otherwise, shift the first event out of the queue (for backtracking purposes, this does not modify the queue, it makes a new version)
* Inspect the event listener registrations to make a list of handlers to call
* For each one, call the handler the same way one block calls another named block
* If at any point the code path is rejected, backtrack
* If we make it to the end of the handlers for that event without backtracking, then we loop, pulling the latest event, and repeat
* Once the event queue is empty, we have delivered all events, and processing is complete

## Custom Types

If all goes well, EVERYTHING will be a custom type.  We'll see.  

TODO: Finish this.

### Inheritance

An object can be initialized as a copy of another object, and then customized:

~~~plaintext
<type> <name> is [a|an] <baseline> {
    // instance-specific initialization
}
~~~

A type can be defined as being a customization of another type:

~~~plaintext
type <sub-class> is [a|an] <base-class> {
    // overriding definitions
}
~~~

A variable can be declared to be a modified version of another variable, so you can add or remove equivalence classes as needed.

~~~plaintext
variable foo { is one of [ FOO, BAR, BAZ ] }
variable spaz is like foo { without BAZ; with SPAZ; }
~~~

In this case, `spaz` is initialized identically as `foo`.  Then when you declare `without BAZ` it finds `BAZ` in the values, and removes it.  Then you declare `with SPAZ` it adds that to the list.  Useful for creating variants.

You COULD take advantage of variable scope to overwrite the outer scope with a variation that goes away after you leave scope.  But that could be very confusing.  Don't do that.

Since this is basically mix-in semantics, you could also mix in other things, too, effectively creating a simplistic form of multiple inheritance.

~~~plaintext
<type> a { . . . }
<type> b { . . . }
<type> c is like a, b {
    // customizations
}
~~~

This is an advanced idea that we'll have to weigh.  It SHOULD be easy, but it will not be implemented if doing so makes it hard to understand what is happening.

Syntax will probably support both `is a`, `is like`, and `extends`.

### Behavior models and inheritance

If you define a block, and then you define a new block that is like an old block, you are basically saying "pre-populate the block with all the same contents:

~~~plaintext
define abc { a; b; c; } // do those three steps in sequence
define abcd extends abc { d; } // append d to the end of the sequence
~~~

Does this make sense?  We can do it, but SHOULD we?  I'm not sold on it yet.  Indeed, it makes more sense to do:

~~~plaintext
define abc { a; b; c; } // do those three steps in sequence
define abcd { abc; d; } // append d to the end of the sequence
~~~

Where this might make more sense is in more complex object types that include fields that define behavior blocks.  In which case, maybe we can do <object>.<field> in order to invoke the behavior defined in that external object, much like explicit super class constructor calling.

~~~plaintext
define abc {
    logic {
        DoThis;
        DontDoThat;
    }
}
define signs {
    logic {
        abc.logic;
        CantYouReadTheSign;
    }
}
~~~

### Types and inheritance

Should we support `without <field>` in a type declaration as a way of saying that this new type is missing `field`?

Or should we just implement inheritance by reference:

~~~plaintext
type foo { . . . }
type bar {
    includes foo;  // or `like foo` or `extends foo` or `start with foo`?
    without <field>;
}
~~~

This way inheritance is easier to control.  And implementation is easy because type definition is simply stepping through the body and interpreting each statement as it is encountered.  

Would we want to do the same thing for variable inheritance, e.g.:

~~~plaintext
variable a { is one of [ foo, bar, baz ] }
variable b {
    start with a;
    remove bar from values;  
    add blip to values;
}
~~~

The remove/add commands could have the `from <field>` and `to <field>` parts optional, where the default is the `values` field.  That way the syntax is cleaner for variables, but can work for any list field in any object type.

## Design / Requirements Validation

One MASSIVE value of having your application design in an executable format is not just that you can generate a test matrix, but you can test the design against the requirements, long before a single line of application code is written.  You can tell if the design is going to work or not, and find gaps in the requirements specification.

### Requirements

Requirements can be expressed in a variation of classic BDD-style GIVEN / WHEN / THEN.  Instead of pure English, the clauses are written in the English-like language of the DSL.

The syntax for this BDD is simple:

~~~plaintext
requirement "<case-description>" 
given <constraint> 
when <operation> 
then <validation>;
~~~

Alternatively, if you prefer, you can use `scenario` in place of `requirement`, although I recommend you stick with `requirement` because it more accurately reflects what this is.  A `scenario` is usually a single test case with specific inputs.  This is a more generic description of the user flow, and uses equivalence classes in place of concrete inputs.  Using `scenario` may be more familiar, but it may lead people to treat it as something it is not.

#### GIVEN `<constraint>`

`<constraint>` is a block that contains one or more constraints.  It can be a single-statement block, a multi-statement block, or the identifier of a pre-defined named block.  This means you can say:

~~~plaintext
given <variable> == <value>
~~~

or, if you want to be silly:

~~~plaintext
given {
    <variable1> == <value1>;
    <variable2> == <value2>;
}
~~~

Or, the recommended way - use a named block so you can re-use the preconditions in multiple tests:

~~~plaintext
define ConstraintIntention {
    <variable1> == <value1>;
    <variable2> == <value2>;
}

. . .

given ConstraintIntention
~~~

#### WHEN `<operation>`

`<operation>` is similarly very simple: a block - single- or multi-statement.

~~~plaintext
when <named-block>
~~~

or - NOT RECOMMENDED - you can do this:

~~~plaintext
when {
    DoThis;
    DoThat;
}
~~~

The language will let you.  But really, don't do that!

The language will also let you put constraints in the when clause.  You can.  Don't.

#### THEN `<validation>`

`<validation>` is the same as that for GIVEN: it is one or more constraints.  This time, however, instead of being used to constrain test generation, it's used to evaluate if the test case will pass or fail.

~~~plaintext
then <variable> == <value>
~~~

or

~~~plaintext
then {
    <variable1> == <value1>;
    <variable2> == <value2>;
}
~~~

Or, the recommended way - use a named block so you can re-use the same validations in multiple tests:

~~~plaintext
define ExpectedResult {
    <variable1> == <value1>;
    <variable2> == <value2>;
}

. . .

then ExpectedResult;
~~~

Note that in the validation block, you can also invoke named blocks, giving you the ability to compose optimal validations, like so:

~~~plaintext
then {
    TypicalResults;
    SpecialResults;
}
~~~

In the `then` block, we will support a special kind of validation that validates that a particular named block gets invoked as part of the test case flow.

~~~plaintext
then triggers NamedBlock;
~~~

The keyword might be `triggers` or `invokes` or `includes` or `expect` . . . whatever makes sense.  This only makes sense if somewhere in the flow is an invocation of that exact named block, but it is gated by some form of logic, so it does not get invoked every time.

We can also do the inverse:

~~~plaintext
then does not invoke NamedBlock;
~~~

#### Compound Steps using AND

You could use a multi-statement block using curly brackets, as shown above.  

Or you could use the AND keyword to add another statement.  The effect is the same.  

~~~plaintext
given <constraint1>
and   <constraint2>
~~~

**OR** you can define a named multi-statement block and then use that in your test definition.  That is the RECOMMENDED style.  

This keeps the test cases easy to read and self-documenting.  Using `AND` or inline multi-statement blocks invites various bad-practices, such as copy-paste-tweak (oops!  missed a tweak!) or "can't see the forest for the trees."  By always invoking a named block, you give a meaningful name, so you don't just know what it is validating, but WHY it is validating it.

#### Nested / Shared Preconditions

It is not uncommon that you will have a number of tests that all have the same precondition, in whole or in part.  Instead of duplicating that precondition in every requirement, we can support nested requirements.  The outer requirement provides a name / string that describes the preconditions, and a block that defines what those preconditions are.  Then, inside that, you have additional requirements.  If a test case needs additional preconditions, you can provide another `given` clause, but if not, you can omit that clause completely.  For example:

~~~plaintext
requirement "<subset-description>" {
    <constraint>;
    <constraint>;

    requirement "<case-description>" given <constraint> when <operation> then <validation>;
    requirement "<case-description>" given <constraint> when <operation> then <validation>;
    requirement "<case-description>" given <constraint> when <operation> then <validation>;

    requirement "<case-description>" when <operation> then <validation>;
    requirement "<case-description>" when <operation> then <validation>;
}

requirement "<subset-description>" {
    <alternative-constraint>;

    requirement "<case-description>" given <constraint> when <operation> then <validation>;
    requirement "<case-description>" given <constraint> when <operation> then <validation>;
}
~~~

### Story Validation

We can and should use this syntax to document user stories and then use that documentation to validate our design changes.  For example:

~~~plaintext
story <name> {
    ticket: ABC-12345;  // or `jira`
    description: "brief summary of the intent of the story";

    // optional copy of the role text
    AS-A: "<role>";
    I-WANT: "<feature>";
    SO-THAT: "<benefit>";

    acceptance-criteria {
        requirement "<description>"
        GIVEN <precondition>
        WHEN <action>
        THEN <validation>;
    }
}
~~~

A **story** is just a custom type.

We feed that story into a story validation process.  It steps through the acceptance criteria, one requirement at a time, and generates all possible test flows that are possible given those preconditions and that action.

* If it generates no test cases, the design does not meet the requirement.
* If a test case passes the `<validation>`, that indicates at least partial alignment.
* If a test case fails the `<validation>`, it may mean a requirements gap, or a design flaw.

The outcome of running this process is something like this:

~~~plaintext
# Requirements Analysis and Design Testing

## <test-case-description-text>

**GIVEN** <precondition>
**WHEN**  <action>
**THEN**  <validation>

---

The following test flows match this acceptance criteria:

* . . .

These test flows match the GIVEN and WHEN but produce a different result, suggesting either a flaw in the design, or a requirements gap.

* . . .

## <test-case-description-text>

**GIVEN** <precondition>
**WHEN**  <action>
**THEN**  <validation>

---

This acceptance criteria is not exercised by the design.  This is a design gap.
~~~

### Full Design Validation

You can validate that your design satisfies a story by executing the process described above.  Then, ideally, you will integrate those requirements into your main requirements repository.  You can then institute a design validation step in your CI/CD pipeline.

You could put these artifacts in their own top-level folders:

~~~plaintext
project-root/
├── src/
├── stories/
│   ├── 2022/
│   ├── 2023/
│   ├── 2024/
│   └── 2025/
├── requirements/
│   ├── <feature>/
│   └── <feature>/
└── design/ 
    ├── common/
    ├── <feature>/
    └── <feature>/
~~~

Alternatively, you could put them under `src`.

~~~plaintext
project-root/
└── src/
    ├── main/
    │   ├── design/
    │   ├── java/
    │   └── resources/
    └── test/
        ├── requirements/
        ├── stories/
        ├── java/
        └── resources/
~~~

The requirements will be divided up into feature files, much like Cucumber:

~~~plaintext
feature <name> {
    requirement . . .;
    requirement . . .;
}
~~~

Nothing says that everything has to be in a single file, or that a file can only have one feature.  The language already supports importing other files and invoking named blocks.  You can use that here to aggregate multiple files into one feature.  However, it's probably easier to just divide the requirements into smaller sub-features or flows, giving each a unique name.

### History

Archiving all the old story text can be organized however teams wish.  By date, by year+feature, by ticket number, whatever teams may choose.

It may seem like a waste, but

* the cost of archiving them is negligible
* it documents the evolution of the system
* is searchable in a way that Jira likely will never be
* is right there in your IDE, along side your design and your implementation
* who knows what insights you can extract from it later

Better to have it and not need it than to discard it and discover only later that you could have gained tremendous insights from it if only you had saved it.

### Requirements Gaps

Knowing that your design meets the requirements is only half the job.  You also need to make sure that the requirements are complete.  Gaps in the requirements create churn, slow development, and can actually lead to re-work.  Design Validation can reveal some gaps, but only in the areas specified by your preconditions.

To achieve full design to requirements validation in an automated way, we can create a utility that:

* Loads your entire requirements suite
* Flattens and indexes the full set of requirements (consolidating the given clauses)
  * Indexes first by operation, then by constraints
* For each operation
  * Generate the full suite of flows through that feature / operation
  * For each valid flow, walk through all of the requirements for that operation
  * If a requirement matches the test case, we call it accounted for and move on
  * If the GIVEN and WHEN match, but the THEN does not, we flag it as either a test failure or a requirements gap
  * If there are no requirements that match the flow, we flag it as a requirements gap

This process can be included in the CI/CD pipeline to validate the design.  If there are no requirements gaps, all requirements are met and every test case matches a requirement, then it passes.

## Authentication and Authorization

Many people do not treat authentication and authorization as a functional requirement.  IT IS.  And it should be DEEPLY integrated into the design model.  We can surface these considerations by making them part of standardized custom objects that represent common application elements, like Pages and RestEndpoints.  All it really takes to make sure that these considerations are taken into account is for someone to actually ask: what are the requirements.  Once they are defined, they can be modeled, and then from that point forward, they become an inseparable part of the test suite.

## Scoping

If you define something, e.g. declaring a named block, then that symbol is only available inside that block.  Define it at the top level, it's available anywhere in that file.  If you import a file, everything defined at the file level is available in the importing file.  Examples:

~~~plaintext
define SomethingUseful { . . . }

define Sub-Block {
    define aThing { . . . }

    SomethingUseful; // allowed, shows up in the parent scope
    aThing;  // allowed - in current scope
}

define SomethingElse {
    aThing; // WRONG!  Will actually treat aThing as an undefined block, which behaves as a no-op.
    Sub-Block.aThing;  // Allowed.  Not encouraged, but allowed.
}
~~~

In another file, you can import the above file and reference its named blocks.

~~~plaintext
import <package>.<file>;

define MyTest {
    assume <variable> = <value>;
    Sub-Block;
}
~~~

## Packages and Namespaces

NOTE: package namespaces and importing is likely required for this language.  We do not want to force everything in a single file.  And we do not want to force every symbol to be unique.  So if you want to use a symbol defined in a package, you have to import that package.  The only question is, do we declare package names?

## Open Questions

* Events & Triggers
  * Do we need an explicit event model, or is everything driven by state transitions?

* Collections
  * How do we handle lists, maps, and sets declaratively?

* Expressions
  * How powerful does the expression system need to be? Full arithmetic, regex, etc.?

* Execution Semantics
  * Do we need an explicit execution model, or does the AST define everything?

* Persistence & Lifespan
  * Should we track whether a state is session-based, request-based, persistent, etc.?

* Type Safety & Casting
  * Should states be strongly typed, or do we infer types from equivalence classes?

* Test Matrix Optimizations
  * How do we prune the test space intelligently to avoid an explosion of cases?

* Tooling & Extensibility
  * Should users be able to extend the core syntax dynamically?
