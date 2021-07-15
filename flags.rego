package flag
import data.launchdarkly.customroles.utilities.parts
import data.launchdarkly.customroles.utilities.subject
import data.launchdarkly.customroles.utilities.verb
import data.launchdarkly.flag.actions

management_actions := {
  "createFlag",
  "cloneFlag",
  "deleteFlag",
  "updateIncludeInSnippet",
  "updateClientSideFlagAvailability",
  "updateName",
  "updateDescription",
  "updateTemporary",
  "updateTags",
  "updateFlagCustomProperties",
  "updateFlagSalt",
  "updateGlobalArchived",
  "updateMaintainer",
  "updateFlagVariations",
  "updateFlagDefaultVariations",
  "updateFlagSalt",
}

sdk_actions := {
  "updateIncludeInSnippet",
  "updateClientSideFlagAvailability",
}

targeting_rule_actions := {
    "updateOn",
    "updateTemporary",
    "updateTags",
    "updatePrerequisites",
    "updateTargets",
    "updateRules",
    "updateFlagRuleDescription",
    "updateFallthrough",
    "updateOffVariation",
    "updateExpiringRules",
    "updateExpiringTargets",
    "copyFlagConfigFrom",
    "copyFlagConfigTo",
}

flag_promotion_action := {
  "copyFlagConfigFrom",
  "copyFlagConfigTo",
}

experiment_actions := {
  "createExperiment",
  "deleteExperiment",
  "deleteExperimentResults",
  "updateExperimentActive",
  "updateExperimentBaseline",
  "updateAttachedGoals",
  "deleteFlagAttachedGoalResults",
}

event_actions := {
  "updateTrackEvents",
  "updateFlagFallthroughTrackEvents",
}

integration_actions := {
  "updateTriggers",
}

approval_actions := {
        "createApprovalRequest",
        "updateApprovalRequest",
        "deleteApprovalRequest",
        "reviewApprovalRequest",
        "applyApprovalRequest",
}

workflow_actions := {
  "updateFeatureWorkflows",
  "updateScheduledChanges",
  "updateExpiringTargets",
  "updateExpiringRules",
}

impacts_evaluation[x]  {
  targeting_rule_actions[x]
}
impacts_evaluation[x]  {
  sdk_actions[x]
}
impacts_evaluation[x] {
  workflow_actions[x]
}

impacts_evaluation[x] {
  
  y := {
    "updateFlagSalt",
    "updateGlobalArchived",
    "updateFlagVariations",
    "createFlag",
    "cloneFlag",
    "deleteFlag",
    "applyApprovalRequest"
  }
  y[x]

}

affects_all_environments[x] {
  management_actions[x]
}

affects_all_environments[x] {
  experiment_actions[x]
  env_actions := {
    "updateExperimentActive", "updateExperimentActive"
  }
  not env_actions[x]
}

impacts_existing_flags[x] {
  impacts_evaluation[x]
  except := {"createFlag", "cloneFlag"}
  not except[x]
}




depends_on[x] = v {
  workflow_actions[x]
  v:= {"updateFeatureWorkflows"}
  not v[x]
}

requires_parent_scope[x] {
  affects_all_environments[x]
}

resource[x] = "flag" {
  actions[x]
}
parent_resource[x] = "env" {
  resource[x] = "flag"
}