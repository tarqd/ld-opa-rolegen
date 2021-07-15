 package policy.flag_maintainer
import data.flag
import input.kind
import data.policy
import data.launchdarkly.segment

deny[action] {
  flag.affects_all_environments[action]
}

allow[action] {
  kind == "flag"
  flag.impacts_evaluation[action]
  not deny[action]
}

allow[action] {
  kind == "segment"
  segment.impacts_evaluation[action]
  not deny[action]
}



















allow[action] {
  kind == "flag"
  policy.flag_approver.allow[action]
  not deny[action]
}

allow[action] {
  kind == "flag"
  policy.flag_reviewer.allow[action]
  not deny[action]
}

allow[action] {
  kind == "segment"
  segment.actions[action]
}

