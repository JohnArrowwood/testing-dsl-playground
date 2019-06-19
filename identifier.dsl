// starts with _ or letter
// continues with _ or letter or digit
// must include something other than just underscores
// hierarchy / object property notation supported
// may allow dash (-) as an inter-identifier visual separator, instead of just _

// perl compatible regular expression for parsing a valid identifier 
/
    ^                # starting at the beginning
    (?=[_[:alpha:]]) # first character must be underscore or letter
    (?=.*[^_])       # must contain something other than an underscore (maybe?)
    (?:                                                       # options
      (?<[[:alpha:][:digit:]])  - (?=[[:alpha:][:digit:]])  | # dash restrictions
      [?<[[:alpha:][:digit:]_]) . (?=[[:alpha:][:digit:]_]) | # dot restrictions
      [[:alpha:][:digit:]_]                                   # a letter, digit, or underscore
    )+                                                        # one or more times
    (?<[[:alpha:][:digit:]_])    # must end with a letter, digit, or underscore 
    (?=[^[:alpha:][:digit:]_])   # end of identifier is a non-identifer character of some kind, usually whitespace
/i