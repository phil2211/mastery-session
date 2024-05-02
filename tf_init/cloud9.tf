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

resource "aws_ssm_document" "cloud9_document" {
  name          = "iaws-mastery-cloud9-init-document"
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
          "cd /home/ec2-user/environment",
          "runuser -l ec2-user -c git clone https://oauth2:glpat-dAeEAhdXJYs-5_JeJFrg@code.swisscom.com/swisscom/iaws-devops-mastery-friday/iaws-mongodb.git",
          "cd iaws-mongodb/scripts",
          "chmod +x cloud9_init.sh",
          "runuser -l ec2-user -c ./cloud9_init.sh"
        ]
      }
    }
  ]
}
DOC
  depends_on    = [aws_servicecatalog_provisioned_product.iaws_cloud9]
}

data "aws_instances" "cloud9_instances" {
  depends_on = [aws_servicecatalog_provisioned_product.iaws_cloud9]
  instance_tags = {
    Name = "*"
  }
}
resource "aws_ssm_association" "cloud9_ssm_association" {
  name = aws_ssm_document.cloud9_document.name
  targets {
    key    = "InstanceIds"
    values = data.aws_instances.cloud9_instances.ids
  }
  output_location {
    s3_bucket_name = aws_s3_bucket.cloud9_document_bucket.bucket
    s3_key_prefix  = "ssm-documents/my-ssm-document"
  }
}

resource "aws_s3_bucket" "cloud9_document_bucket" {
  bucket        = "mfriday-document-bucket"
  force_destroy = true
}
