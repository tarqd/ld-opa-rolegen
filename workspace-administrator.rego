package policy.workspace_admin
import data.launchdarkly.project
import data.launchdarkly.env
import data.launchdarkly.flag

import input.kind 

allow[action] {
    kind == "project"
    project.actions[action]
}

allow[action] {
    kind == "env"
    env.actions[action]
}

