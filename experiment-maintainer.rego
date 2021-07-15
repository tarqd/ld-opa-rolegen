package policy.experiment_maintainer
import data.flag
import input.kind

allow[action] {
  kind = "flag"
  flag.experiment_actions[action]
  not flag.affects_all_environments[action]
}


allow[action] {
  kind = "flag"
  flag.event_actions[action]
  not flag.affects_all_environments[action]
}


