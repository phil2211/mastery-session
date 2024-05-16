resource "aws_servicecatalog_provisioned_product" "iaws_cloud9" {
  name                       = "cloud9-mastery"
  path_name                  = "iaws-proof-of-concept"
  product_name               = "iaws-cloud9"
  provisioning_artifact_name = "1.0.4"

  provisioning_parameters {
    key   = "EnvironmentName"
    value = "mastery-exploration"
  }

  provisioning_parameters {
    key   = "InstanceType"
    value = "S"
  }

  # depends_on = [
  #   aws_servicecatalog_provisioned_product.join_shared_vpc
  # ]
}

resource "null_resource" "lambda_backend_npm_install" {
  depends_on = [ aws_servicecatalog_provisioned_product.iaws_cloud9 ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "../../scripts/cloud9_sg.sh"
  }

}
