package policy.member
import data.flag
import input.kind

allow[action] {
  kind = "project"
  action = "viewProject"
}

allow[action] {
  kind = "flag"
  action = "createApprovalRequest"
}




