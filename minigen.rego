package minigen

import data.policy 
import data.launchdarkly

envs := {"production", "test"}
bools := {true, false}
workspaces := {"teamname"}

roleKeyMap := {k: role | policy[k]; role := replace(k, "_", "-") }

roles := {r | r := roleKeyMap[_]}

allow[action] {
    input.role == roleKeyMap[p]
    policy[p].allow[action]
    
}

workspace_selector[workspace] = selector {
    workspaces[workspace]
    selector := concat(";", ["proj/*", workspace])
}




integration_resources := {"code-reference-repository", "integration", "webhook", "relay-proxy-autoconfig"}
allow[action] {
    input.role == "integration-admin"
    input.kind == "code-reference-repository"
    actions := {
        "createCodeRefsRepository",
        "updateCodeRefsRepositoryName",
        "updateCodeRefsRepositoryConfiguration",
        "updateCodeRefsRepositoryOn",
        "updateCodeRefsRepositoryBranches",
        "deleteCodeRefsRepository"
    }
    actions[action]
}
allow[action] {
    input.role == "integration-admin"
    input.kind == "integration"
     actions := {
        "createIntegration",
        "deleteIntegration",
        "updateName",
        "updateConfiguration",
        "updateOn",
        "validateConnection"
    }
    actions[action]
}
allow[action] {
    input.role == "integration-admin"
    input.kind == "webhook"
    actions := {
        "createWebhook",
        "deleteWebhook",
        "updateName",
        "updateUrl",
        "updateSecret",
        "updateStatements",
        "updateOn",
        "updateTags",
        "updateQuery"
    }
    actions[action]
}



allow[action] {
    input.role == "relay-admin"
    input.kind == "relay-proxy-autoconfig"
    actions := {
    "createRelayAutoConfiguration",
"updateRelayAutoConfigurationName",
"updateRelayAutoConfigurationPolicy",
"deleteRelayAutoConfiguration",
"resetRelayAutoConfiguration"
    }
    actions[action]
}

resources := {"project", "env","segment", "flag"} | integration_resources
globals := integration_resources

workspace_resource_selector[[workspace, resource, statement]] {
    resources[resource]
    workspaces[workspace]
    resource == "project"
    statement := workspace_selector[workspace]
}

workspace_resource_selector[[workspace,resource,statement, env]] {
resources[resource]
    workspaces[workspace]
    resource == "env"
    envs[env]
    statement := concat(":env/", [workspace_selector[workspace], env])
}

workspace_resource_selector[[workspace,resource,statement]] {
resources[resource]
    workspaces[workspace]
    resource == "flag"
    env := "*"
    statement := concat("", [workspace_selector[workspace], ":env/",env, ":flag/*"])
}

workspace_resource_selector[[workspace,resource,statement, env]] {
    resources[resource]
    workspaces[workspace]
    resource == "flag"
    env := "*"
    
    statement := concat("", [workspace_selector[workspace], ":env/", env, ":flag/*"])
}
workspace_resource_selector[[workspace,resource,statement]] {
    resources[resource]
    workspaces[workspace]
    resource == "env"
    env := "*"
    
    statement := concat("", [workspace_selector[workspace], ":env/", env])
}
workspace_resource_selector[[workspace,resource,statement, env]] {
    resources[resource]
    workspaces[workspace]
    resource == "flag"
    envs[env]
    
    statement := concat("", [workspace_selector[workspace], ":env/", env, ":flag/*"])
}

workspace_resource_selector[[workspace,resource,statement, env]] {
    resources[resource]
    workspaces[workspace]
    resource == "segment"
    envs[env]
    statement := concat("", [workspace_selector[workspace], ":env/", env, ":segment/*"])
}


workspace_resource_selector[[workspace,resource,statement]] {
    resources[resource]
    workspaces[workspace]
    globals[resource]
    statement := concat("", [resource, "/", "*"])
}

per_env := {
    "flag-maintainer",
    "experiment-maintainer",
    "flag-approver",
    "flag-reviewer",
    "flag-integrator"
}

workspace_roles[workspace] = x {
    workspaces[workspace]
    
    x := [role | roles[y]; not per_env[y]; role := concat("-", [workspace, y]) ]
    
}

workspace_role_actions[role] = map {
    roles[role]
    
    map := { 
        resource: actions |
        resources[resource]

        actions := allow with input as {
            "role": role,
            "kind": resource
        }
     } 
}

workspace_role_statement[[workspace, role, selector, actions]] {
    roles[role]
    [workspace, resource, selector] = workspace_resource_selector[_]
    actions := workspace_role_actions[role][resource]
    not per_env[role]
    not count(actions) == 0
}

workspace_role_statement[[workspace, role, selector, actions]] {
    roles[role]
    [workspace, resource, selector, env] := workspace_resource_selector[_]
    actions := workspace_role_actions[role][resource]
    not resource == "flag"
    not all_env[role]
    not count(actions) == 0
}
all_env := {"member", "project-maintainer", "workspace-maintainer", "workspace-admin", "experiment-manager", "flag-manager", "flag-archiver"}
workspace_role_statement[[workspace, role, selector, actions]] {
    roles[role]
    [workspace, resource, selector, env] := workspace_resource_selector[_]
    all_actions := workspace_role_actions[role][resource]
    resource == "flag"
    actions := all_actions - data.flag.requires_parent_scope
    not env == "*"
    not all_env[role]
    not count(actions) == 0
}

workspace_role_statement[[workspace, role, selector, actions]] {
    roles[role]
    [workspace, resource, selector, env] := workspace_resource_selector[_]
    all_actions := workspace_role_actions[role][resource]
    resource == "flag"
    actions := (all_actions & data.flag.requires_parent_scope)
    env == "*"
    not all_env[role]
    not count(actions) == 0
}



workspace_allow_statements[[workspace, role, statement]] {
    [workspace, role, selector, actions] := workspace_role_statement[_]
    not per_env[role]
    statement := { 
        "resources": [selector],
        "actions": actions,
        "effect": "allow"
     }
}

workspace_allow_statements[[workspace, role, statement]] {
    [workspace, base_role, selector, actions] := workspace_role_statement[_]
    per_env[base_role]
    envs[env]
    [workspace,_,selector, env] = workspace_resource_selector[_]
    
    role := concat("-", [base_role, env])
    statement := { 
        "resources": [selector],
        "actions": actions,
        "effect": "allow"
     }
}
workspace_allow_statements[[workspace, role, statement]] {
    [workspace, base_role, selector, actions] := workspace_role_statement[_]
    per_env[base_role]
    envs[env]
    [workspace,_,selector, "*"] = workspace_resource_selector[_]
    
    role := concat("-", [base_role, env])
    statement := { 
        "resources": [selector],
        "actions": actions,
        "effect": "allow"
     }
}

all_roles[role] {
    roles[role]
    not per_env[role]
}

all_roles[role] {
    per_env[base_role]
    envs[env]
    role := concat("-", [base_role, env])
}

role_policy[role] = policy {
    all_roles[base_role]
    workspaces[workspace]
    role := concat("-", [workspace, base_role])
    
    policy := [s | 
        [w, r, s] := workspace_allow_statements[_]
        base_role == r
        w == workspace
    ]
}

