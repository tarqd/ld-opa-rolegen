package policy.flag_reviewer
import data.flag
import input.kind

allow[action] {
  kind = "flag"
  flag.approval_actions[action]
  action = "reviewApprovalRequest"
}



