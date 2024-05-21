resource "aws_servicecatalog_provisioned_product" "iaws_cloud9" {
  count                      = 2
  name                       = "cloud9-mastery-${count.index}"
  path_name                  = "iaws-proof-of-concept"
  product_name               = "iaws-cloud9"
  provisioning_artifact_name = "1.0.4"

  provisioning_parameters {
    key   = "EnvironmentName"
    value = "mastery-exploration-${count.index}"
  }

  provisioning_parameters {
    key   = "InstanceType"
    value = "S"
  }

  # depends_on = [
  #   aws_servicecatalog_provisioned_product.join_shared_vpc
  # ]
}

resource "null_resource" "cloud9_sg_update" {
  depends_on = [aws_servicecatalog_provisioned_product.iaws_cloud9]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "../../scripts/cloud9_sg.sh"
  }

}
