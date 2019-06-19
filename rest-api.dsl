api <name> {
    // to pull services into the API
    service <service> { optional-declaration } // declare the service here
    services [ list-of-services ]              // pull in externally declared services
}

service <name> is <source>, <alt> {
    member of <api-name> // to push services into an API - NOT SURE IF I WILL SUPPORT THIS        
    // to pull operations into a service
    operation <name> { optional-declaration }
    operations [ list-of-operations ]
}

operation <name> {
    member of <service> // to push operation into a service - NOT SURE IF I WILL SUPPORT THIS
    method = POST | PUT | GET | DELETE (etc.)
}

// allows you to define a base operation and then build on it

operation create {
    method = POST
}
operation application-create is create {
    // method = POST is inherited and need not be specified
}

// allows you to define a base service and build on it
// in this case using external operation definitions
service crud-interface {
    operations [
        create
        retrieve-by-id
        retrieve-all
        retrieve-matching
        update
        delete
    ]
}
// in this case, using internal definitions
service crud-interface {
    operations [
        create            { method = POST }
        retrieve-by-id    { method = GET }
        retrieve-all      { method = GET }
        retrieve-matching { method = GET }
        update            { method = PUT }
        delete            { method = DELETE }
    ]
}

// to build on it an inherit everything:
service application is crud-interface {
    // customizations
}

// to build on it and only inherit the operations, or a subset thereof
service application {
    operations from crud-operations except [ retrieve-matching ]
}

// or to inherit everything but throw away an operation
service application is crud-interface {
    omit operation retrieve-matching // or
    omit operations [ one, two ]

    // to modify an inherited operation, just build on it
    operation <name> { <definition> }       // inline-definition extends any inherited definition
    operation <name> is <operation-object>  // merge an external definition
    operation <name> is <object>, <object>  // merge multiple objects into a single object
    operation <name> is <source> { <customizations> } // build <name> from <source> and then apply customizations
}

// example of a complete service declaration
service application is crud-interface {
    omit operation retrieve-matching  // I don't want the inherited operation included in this service definition
    operation create         is application-create
    operation retrieve-by-id is application-retrieve-by-id
    operation retrieve-all   is application-retrieve-all
    operation search-by-name is application-search-by-name
    operation update         is application-update
    operation delete         is application-delete
    member of keystone-admin-api
}

api keystone-admin-api {
    // define a variable visible while constructing objects in this context
    let service-root = config.keystone-admin-root

    services [
        application
        application-metadata
        attribute
        attribute-type
        directory
        dynamic-rule
        functional-ability
        fa-se
        group
        group-dynamic-assignment
        group-role
        group-role-attribute
        group-user
        reporting
        role
        role-conditional-expression
        role-dynamic-assignment
        role-functional-ability
        role-functional-ability-attribute
        role-functional-ability-conditional-expression
        secured-entity
        user
        user-role
        user-role-attribute
        user-role-conditional-expression
        user-authentication-source
    ]    
    // or
    service application {
        // inline definition (NOT-RECOMMENDED)
        // or customizations of the pre-defined service object
    }
}

// globally defined fields that are used across multiple services
field record-id {
    name = "Id"
    type = GUID
    unique
}
field last-update-datestamp {
    name = "LastUpdate"
    type = iso-date-time-no-tz
    read-only
    auto-update
}
field application-id {
    name = "ApplicationId"
    type = GUID
}
field record-name {
    name = "Name"
    type = String
    max-length = 255
    not-null
    trimmed
    not-empty
    unique
    invalid = contains-special-characters  // filter
}
field friendly-description {
    name = "Description"
    type = String
    max-length = 1000
    trimmed
    may-be-null
    may-be-empty
    not-unique
    invalid = none
}

// global response object definitions
json response-id-only {
    id
}
json response-on-update is empty
json response-on-delete is empty
json response-of-empty-list is "[]"  // or something like that

json response-on-failure {
    field message { name = "Message", type = String }
    field event-id { name = "EventId", type = GUID }
}

// base operations to inherit from
operation crud-create { method = POST }

operation keystone-standard {
    authentication required
    on bad-request   returns 400 and response-on-failure
    on unauthorized  returns 401 and response-on-failure
    on not-found     returns 404 and response-on-failure
}

operation keystone-create is crud-create, keystone-standard {
    on success returns 200 and response-id-only
}
operation keystone-update is crud-update, keystone-standard {
    on success returns 200 and response-on-update
} 
operation not-supported {
    always returns 405
}

service application {

    // define the fields that make up the JSON payload

    json model {
        id          is record-id
        name        is record-name
        last-update is last-update-datestamp
        is-active    "IsActive"    Boolean { default [=] false }
        max-sessions "MaxSessions" Integer { default 0, min 0, max 9999 } 
    }

    // define the different types of responses expected

    json response-on-retrieve-one  is model
    json response-on-retrieve-many is list of model

    // example of a complete inline definition
    operation create {
        authentication required
        method = POST
        url = service-root / "v1" / "application"
        send on-create // can inline your json definition, too
        on success returns 200 and response-id-only  // again, you COULD inline your responses if you didn't want them pre-defined elsewhere
        on bad-request   returns 400 and response-on-failure
        on unauthorized  returns 401 and response-on-failure
        on not-found     returns 404 and response-on-failure
    }

    // example of a compound definition that includes only the parts it needs and inherits the rest
    operation create is keystone-create {
        url = service-root / "v1" / "application"
        send on-create
    }

    // note that since the models are declared and then only used once, it makes more sense to inline them:
    // example of a compound definition that includes only the parts it needs and inherits the rest
    operation create is keystone-create {
        url = service-root / "v1" / "application"
        send model {
            id           optional
            name         required
            is-active    optional
            max-sessions optional
            last-update  forbidden
        }
    }

    operation retrieve-by-id is keystone-retrieve-by-id {
        url = service-root / "v1" / "application" / id
        on succes returns 200 and model
    }

    operation search-by-name is keystone-retrieve-matching {
        url = service-root / "v1" / "application" ? "appName" = pattern
        on success returns 200 and list of model
    }

    operation update is keystone-update {
        url = service-root / "v1" / "application" / id
        send model {
            id           required
            name         required
            is-active    optional
            max-sessions optional
            last-update  ignored
        }
    }

    operation delete is keystone-delete {
        url = service-root / "v1" / "application" / id
    }

}

// recommended approach:
// don't try to build an optimal model when first getting started
// initially, define a service inline, 
// and define all the services/operations that are known
// then, as commonalities are identified, move them into separate files and reference them
// so that the model becomes more concise over time
// but you want it to be verbose when first expressing it to the developers
// so they know everything that goes into it
// and can offer suggestions on what is missing from that model

// COMMENT about push vs. pull for adding objects to parent objects
// push is complicated to implement.  
// have to have an "external definitions" for every object
// and whenever an object tries to push itself into another object, that object is pushed onto that list
// that will mean that the whole code base must be parsed before anything is interpreted
// that may be preferable, anyway, especially if I can find a way to pre-compile things
// it also means the definition of what is included in an item is defined elsewhere
// that is not ALL bad, but violates my preference of having everything readily available
// pull is easy to implement, provided I can control the parsing order
// I lean towards pull only
// but I may allow push just for those who llke that approach