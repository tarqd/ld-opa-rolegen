package launchdarkly.segment

actions := {
"createSegment",
"deleteSegment",
"updateName",
"updateDescription",
"updateTags",
"updateIncluded",
"updateExcluded",
"updateRules",
"updateExpiringRules",
"updateExpiringTargets",
"updateScheduledChanges",
}

management_actions := {
    "createSegment",
    "deleteSegment",
    "updateName",
    "updateDescription",
    "updateTags",
}

workflow_actions[action] {
    data.flag.workflow_actions[action]
    actions[action]
}

impacts_evaluation := {
    "createSegment",
    "deleteSegment",
    "updateIncluded",
    "updateExcluded",
    "updateRules",
    "updateExpiringRules",
    "updateExpiringTargets",
    "updateScheduledChanges",
}

does_not_impact_existing_flags := {
    "createSegment",
    # you can't delete segments that are used by other flags 
    "deleteSegment",
}

impacts_existing_flags[action] {
    impacts_evaluation[action]
    not does_not_impact_existing_flags[action]
}

