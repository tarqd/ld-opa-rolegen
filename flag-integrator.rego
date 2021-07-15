package policy.flag_integrator
import data.flag
import input.kind

allow[action] {
  kind = "flag"
  flag.integration_actions[action]
}
