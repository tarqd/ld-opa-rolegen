package launchdarkly.project

actions := {
"createProject",
"deleteProject",
"updateProjectName",
"updateTags",
"updateIncludeInSnippetByDefault",
"updateDefaultClientSideAvailability",
"viewProject",
}

impacts_evaluation := {
    "updateDefaultClientSideAvailability",
    "updateIncludeInSnippetByDefault",
    "deleteProject"
}

impacts_existing_flags := {
    "deleteProject"
}