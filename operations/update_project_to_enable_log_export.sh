#!/bin/bash

print_help() {
    echo "Updates already provisioned 'iaws-mongodb-project' product to enable log export to an S3 bucket"
    echo ""
    echo "Usage: $0 <mongodb_atlas_project_name> <bucket_name>"
    echo ""
    echo "Arguments:"
    echo "  mongodb_atlas_project_name  The name of already provisioned mongodb atlas project."
    echo "  bucket_name  The name of S3 bucket to export logs to. Ensure that the bucket exists already."
}

# Check if no arguments provided or help option requested
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    print_help
    exit 0
fi

project_name="$1"
bucket_name="$2"

aws servicecatalog update-provisioned-product \
    --provisioning-artifact-name "2.0.0" \
    --product-name "iaws-mongodb-project" \
    --provisioned-product-name "iaws-mongodb-project-${project_name}" \
    --provisioning-parameters \
        Key=MongoDbProjectName,UsePreviousValue=True \
        Key=EnableAuditing,UsePreviousValue=True \
        Key=Subnets,UsePreviousValue=True \
        Key=EnableLogsExportToS3Bucket,Value="True" \
        Key=S3BucketForExports,Value="${bucket_name}"