#!/bin/bash

print_help() {
    echo "Provisions service catalog product: 'iaws-mongodb-cluster'"
    echo ""
    echo "Usage: $0 <mongodb_atlas_cluster_name> <mongodb_atlas_project_name>"
    echo ""
    echo "Arguments:"
    echo "  mongodb_atlas_cluster_name  The name of the cluster to provision."
    echo "  mongodb_atlas_project_name  The name of the project in which cluster is to be provisioned. Ensure that the project is provisioned successfully"
}

# Check if no arguments provided or help option requested
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    print_help
    exit 0
fi

cluster_name="$1"
project_name="$2"

aws servicecatalog provision-product \
    --provisioning-artifact-name "2.2.0-preview" \
    --product-name "iaws-mongodb-cluster" \
    --provisioned-product-name "iaws-mongodb-cluster-${cluster_name}" \
    --provisioning-parameters \
        Key=ClusterName,Value="${cluster_name}" \
        Key=ProjectName,Value="${project_name}" \
        Key=ClusterMongoDBMajorVersion,Value="6.0" \
        Key=ClusterBackupEnabled,Value="True" \
        Key=ClusterContinuousBackupEnabled,Value="True" \
        Key=ClusterDiskSizeGB,Value="10" \
        Key=KMSArnForSecretManager,Value="" \
        Key=RetainBackupsOnClusterDeletion,Value="False" \
        Key=ClusterPauseSchedule,Value="" \
        Key=ClusterResumeSchedule,Value=""