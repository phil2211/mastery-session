#!/bin/bash

#
#   Initialize Cloud9 instance
#

#
#   Install and configure Terraform
#
wget https://artifactory.swisscom.com/artifactory/iaws-mastery-bin-generic-local/artifactory/general/tf/terraform_1.8.2_linux_amd64.zip
unzip terraform_1.8.2_linux_amd64.zip
sudo mv terraform /usr/local/bin/

