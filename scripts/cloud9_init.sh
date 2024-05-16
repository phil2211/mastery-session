#!/bin/bash

#
#   Initialize Cloud9 instance
#
pwd
mkdir -p /home/ec2-user/environment/installations
cd /home/ec2-user/environment/installations

# Perform general update
sudo yum update -y

#   Setup npm registry
npm config set registry https://artifactory.swisscom.com/artifactory/api/npm/npm-remote

#   Install mongodb shell
wget https://artifactory.swisscom.com/artifactory/iaws-mastery-bin-generic-local/artifactory/general/mongodb/mongosh-2.2.5-linux-x64.tgz
tar -zxvf mongosh-2.2.5-linux-x64.tgz
cd mongosh-2.2.5-linux-x64/
chmod +x bin/mongosh
sudo cp bin/mongosh /usr/local/bin/
sudo cp bin/mongosh_crypt_v1.so /usr/local/lib/
cd ..

#   Install and configure Terraform
wget https://artifactory.swisscom.com/artifactory/iaws-mastery-bin-generic-local/artifactory/general/tf/terraform_1.8.2_linux_amd64.zip
unzip terraform_1.8.2_linux_amd64.zip
sudo mv terraform /usr/local/bin/

cat <<EOF> ~/.terraformrc
provider_installation {
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
  network_mirror {
    url = "https://artifactory.swisscom.com/artifactory/api/terraform/terraform-remote/providers/"
  }
}
EOF
