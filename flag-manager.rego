package policy.flag_manager
import data.flag
import input.kind

deny [action] {
  kind = "flag"
  flag.impacts_existing_flags[action]
}

allow[action] {
  kind = "flag"
  flag.management_actions[action]
  not deny[action]
}

