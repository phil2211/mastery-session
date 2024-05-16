
locals {
  account_id    = data.aws_caller_identity.current.account_id
  user_id       = regex(".*:(\\w*)@",data.aws_caller_identity.current.user_id)[0]
}