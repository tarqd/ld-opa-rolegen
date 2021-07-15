package launchdarkly.env

actions = {
"createEnvironment",
"deleteEnvironment",
"updateName",
"updateColor",
"updateTtl",
"updateApiKey",
"updateMobileKey",
"updateSecureMode",
"updateDefaultTrackEvents",
"updateTags",
"updateRequireComments",
"updateConfirmChanges"
}

management_actions := {
    "createEnvironment",
    "deleteEnvironment",
    "updateName",
    "updateColor",
    "updateTtl",
    "updateMobileKey",
    "updateSecureMode",
    "updateTags",
    "updateRequireComments",
    "updateConfirmChanges",
    "updateDefaultTrackEvents",
}

impacts_audit_log := {
    "updateRequireComments",
    "updateConfirmChanges",
}
impacts_evaluation := {
    "createEnvironment",
    "deleteEnvironment",
    "updateApiKey",
    "updateMobileKey",
    "updateSecureMode",
}

impacts_events := {
    "updateDefaultTrackEvents"
}

impacts_existing_flags[action] {
    actions[action]
    impacts_evaluation[action]
    not action == "createEnvironment"
}
