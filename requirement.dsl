A requirement is a statement of expectation about the behavior of a system

requirement <identifier> {
    // TBD
}

// examples:

requirement user-authentication {
    description = <text>
        When a user tries to access a resource,
        The system must be able to identify who the user is
        otherwise access is denied
    </text>
}

// alternatively

requirement user-authentication {
    when "a user calls a method of a service"
    if "the system can identify who the user is"
    then "the request MAY be allowed"
    otherwise "the result is a 401 unauthorized"
}

// With Element Re-use:

requirement user-authentication {
    when accessing-system
    if user-identified
    then continue
    else return-401-error
}
requirement user-authorization {
    when accessing-system
    if user-authorized
    then continue
    else return-401-error
}

condition accessing-system {
    value = "a user calls a method of a service"
}
<tbd> return-401-error {
    value = "the result is 401 Unauthorized"
}

// Why re-use elements?  Because of the additional attributes
// that can be attached to them, which will allow us to tie
// related records together automatically

// record tying is TBD
