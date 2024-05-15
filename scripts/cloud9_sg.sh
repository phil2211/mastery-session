#!/bin/bash

#
#   Adding egress rule to Cloud9 security groups to enable MongoDB Atlas
#   connectivity via mongodb shell
#

TAG_KEY="Name"
TAG_VALUE="*cloud9*"
REGION="eu-central-1"

# Get list of all security groups with the specified TAG_KEY and TAG_VALUE
sg_list=$(aws ec2 describe-security-groups --region ${REGION} --filters Name=tag:${TAG_KEY},Values=${TAG_VALUE} --query 'SecurityGroups[*].GroupId' --output text)
 
for sg in $sg_list 
do
    echo "Adding egress rule to Security Group ID: $sg"
    aws ec2 authorize-security-group-egress --region ${REGION} --group-id $sg --protocol tcp --port 1026 --cidr 0.0.0.0/0
done