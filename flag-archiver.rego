package policy.flag_archiver
import data.launchdarkly.flag
import input.kind


allow[action] {
  kind = "flag"
  flag.actions[action]
  action = "updateGlobalArchived"
}

# warning: this is permanent!
#allow[action] {
#  kind = "flag"
#  action = "deleteFlag"
#}

