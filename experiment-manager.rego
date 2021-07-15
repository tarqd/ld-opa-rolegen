package policy.experiment_manager
import data.flag
import input.kind

allow[action] {
  kind = "flag"
  flag.experiment_actions[action]
  not flag.experiment_environment_actions[action]
}



