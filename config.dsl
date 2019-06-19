// JSON-like object construction

object <identifier> {
    var = value

    var = { 
        foo = bar
    }
}

enum environments {
    LOCAL
    DEV
    QA
    PERF
    STG
    PROD
}

set environment = environments.LOCAL

object config = switch environment {
    case LOCAL: local-config
    case DEV: dev-config;
    case QA: qa-config;
    case STG: stage-config;
    case PROD: prod-config;
}