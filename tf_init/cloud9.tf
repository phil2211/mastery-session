#
#   Create Cloud9 instances from service catalog
#
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

  depends_on = [
    aws_servicecatalog_provisioned_product.join_shared_vpc
  ]
}

resource "aws_ssm_document" "cloud9_document" {
  name          = "my-ssm-document"
  document_type = "Command"
  content       = <<DOC
{
  "schemaVersion": "2.2",
  "description": "Update instances",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "runShellScript",
      "inputs": {
        "runCommand": [
          "sudo yum update -y",
          "git clone https://oauth2:glpat-dAeEAhdXJYs-5_JeJFrg@code.swisscom.com/swisscom/iaws-devops-mastery-friday/iaws-mongodb.git",
          "cd iaws-mongodb",
          "sudo ./install.sh"
        ]
      }
    }
  ]
}
DOC
}

resource "aws_ssm_association" "cloud9_ssm_association" {
  name = aws_ssm_document.cloud9_document.name
  targets {
    key    = "InstanceIds"
    values = ["*"]

  }
}
