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
          "runuser -l ec2-user -c 'git clone https://oauth2:glpat-dAeEAhdXJYs-5_JeJFrg@code.swisscom.com/swisscom/iaws-devops-mastery-friday/iaws-mongodb.git /home/ec2-user/environment/iaws-mongodb'",
          "cd /home/ec2-user/environment/iaws-mongodb/scripts",
          "chmod +x cloud9_init.sh",
          "./cloud9_init.sh"
        ]
      }
    }
  ]
}
DOC
}

data "aws_instances" "cloud9_instances" {
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
