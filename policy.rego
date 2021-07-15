package gen

import data.policy 
import data.launchdarkly

envs := {"production", "test"}
bools := {true, false}
workspaces := {"teamname"}

roles := {"release-manager", "flag-maintainer", "member", "project-maintainer", "workspace-admin", "workspace-maintainer", "integration-admin", "relay-admin"}

workspace_selector[workspace] = selector {
    workspaces[workspace]
    selector := concat(";", ["proj/*", workspace])
}

allow[action] {
    input.role = "release-manager"
    policy.flag_maintainer.allow[action]
}

allow[action] {
    input.role = "flag-maintainer"
    policy.flag_maintainer.allow[action]
}

allow[action] {
    input.role = "flag-maintainer"
    policy.flag_manager.allow[action]
}


allow[action] {
    input.role == "workspace-admin"
    policy.workspace_admin.allow[action]
}

allow[action] {
    input.role == "workspace-maintainer"
    policy.workspace_maintainer.allow[action]
}

allow[action] {
    input.role == "project-maintainer"
    policy.flag_archiver.allow[action]
    
}
allow[action] {
    input.role == "project-maintainer"
    policy.flag_integrator.allow[action]
    
}

allow[action] {
    input.kind == "project"
    input.role == "project-maintainer"
    data.launchdarkly.project.actions[action]
    not data.launchdarkly.project.impacts_existing_flags[action]
    not action == "createProject"
}
allow[action] {
    input.kind == "env"
    input.role == "project-maintainer"
    data.launchdarkly.env.actions[action]
    not data.launchdarkly.env.impacts_evaluation[action]
    not data.launchdarkly.env.impacts_audit_log[action]
    not action == "createEnvironment"
}
allow[action] {
    input.kind == "flag"
    input.role == "project-maintainer"
    data.launchdarkly.flag.actions[action]
    not data.flag.approval_actions[action]
    not data.flag.impacts_evaluation[action]
}




allow[action] {
    input.kind == "project"
    data.launchdarkly.project.actions[action]
    action == "viewProject"
    except := {
        "integration-admin", "relay-admin"
    }
    not except[input.role]
}


allow[action] {
    input.role == "member"
    input.kind == "flag"
    data.flag.approval_actions[action]
    action == "createApprovalRequest"
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
    "release-manager"
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
all_env := {"member", "project-maintainer", "workspace-maintainer", "workspace-admin"}
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

