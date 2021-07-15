package policy.workspace_maintainer
import input.kind
import data.policy
import data.launchdarkly.project
import data.launchdarkly.env
import data.policy.flag_integrator


allow[action] {
    kind == "project"
    project.actions[action]
    not project.impacts_existing_flags[action]
}


allow[action] {
    kind == "env"
    env.actions[action]
    not env.impacts_existing_flags[action]
    not env.impacts_audit_log[action]
}

