package policy.flag_approver
import data.flag
import input.kind

allow[action] {
  kind = "flag"
  action = "reviewApprovalRequest"
}

allow[action] {
  kind = "flag"
  action = "updateApprovalRequest"
}

allow[action] {
  kind = "flag"
  action = "deleteApprovalRequest"
}


