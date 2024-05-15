#!/bin/bash

print_help() {
    echo "Provisions service catalog product: 'iaws-mongodb-project'"
    echo ""
    echo "Usage: $0 <mongodb_atlas_project_name>"
    echo ""
    echo "Arguments:"
    echo "  mongodb_atlas_project_name  The name of the project to provision."
}

# Check if no arguments provided or help option requested
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    print_help
    exit 0
fi

project_name="$1"

aws servicecatalog provision-product \
    --provisioning-artifact-name "2.0.0" \
    --product-name "iaws-mongodb-project" \
    --provisioned-product-name "iaws-mongodb-project-${project_name}" \
    --provisioning-parameters \
        Key=MongoDbProjectName,Value="${project_name}" \
        Key=EnableAuditing,Value="True" \
        Key=Subnets,Value="/platform/sharedvpc/private_subnets" \
        Key=EnableLogsExportToS3Bucket,Value="True" \
        Key=S3BucketForExports,Value="taajaan9-atlas-systemdemo"