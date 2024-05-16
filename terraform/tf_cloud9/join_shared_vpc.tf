# resource "aws_servicecatalog_provisioned_product" "join_shared_vpc" {
#   count                      = var.join_shared_vpc ? 1 : 0
#   name                       = "shared-vpc-mastery-friday"
#   path_name                  = "iaws-networking-content-delivery"
#   product_name               = "iaws-join-shared-vpc"
#   provisioning_artifact_name = "8.0.1"
# }
