namespace <name> {
    // declarations
}

<namespace>.<identifier> allows you to reference things in that namespace

Might use that for grouping stuff into a namespace, like namespace keystone-admin-api vs. keystone-auth-api vs. keystone-admin-ui, etc.

NOTE: if you reference the same namespace in multiple files, the namespace gets all of them, not just the last one
Therefore, you don't have to declare everything in a namespace all at once, in a single file

When referencing an identifier, it is resolved hierarchically, checking the local context first, and rising up through any containing
objects including namespaces, until you reach the global context.

If an identifier can't be resolved, it will complain