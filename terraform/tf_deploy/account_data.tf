# The attribute `${data.aws_caller_identity.current.account_id}` will be current account number.
data "aws_caller_identity" "current" {}


# Set as [local values](https://www.terraform.io/docs/configuration/locals.html)
locals {
  account_id    = data.aws_caller_identity.current.account_id
  user_id       = regex(".*:(\\w*)@",data.aws_caller_identity.current.user_id)[0]
}