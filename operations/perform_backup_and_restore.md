# Backup & Restore iAWS MongoDB Atlas Clusters via Service Actions

## 1. Take Snapshot

### Set id of the provisioned iaws-mongodb-cluster product
```terminal
export PP_ID=<pp-id>
```

### Set id of the version of the provisioned iaws-mongodb-cluster product
```terminal
export MONGODB_ATLAS_CLUSTER_PRODUCT_VERSION="2.2.0-preview"
```

### Get available service actions for version
```terminal
aws servicecatalog list-service-actions --query "ServiceActionSummaries[?starts_with(Name, \`sc-mongodb-cluster-v${MONGODB_ATLAS_CLUSTER_PRODUCT_VERSION}\`)].[Name, Id]"
```

### Set id of the relevant service action. In this case, "take-snapshot"
```terminal
export SA_ID=<id-of-take-snapshot-service-action>
```

### Execute the Service Action and get the 'record-id' of the operaton
```terminal
export SA_RECORD_ID=$(aws servicecatalog execute-provisioned-product-service-action \
    --provisioned-product-id ${PP_ID} \
    --service-action-id ${SA_ID} \
    --parameters Description="Mastery-Friday-Snapshot",RetentionInDays="2" \
    --query "RecordDetail.RecordId" \
    --output text
)
```

### Use the 'record-id' from the previous step to check the status of the operation
```terminal
watch -n 10 'aws servicecatalog describe-record --id ${SA_RECORD_ID} --query "RecordDetail.Status" --output text'
```

### After the operation is successful, get the output of the operation. In this case, snapshot-id 
```terminal
aws servicecatalog describe-record --id $SA_RECORD_ID --query "RecordOutputs[?ends_with(OutputKey, 'SnapshotId')].OutputValue" --output text
```

---

## 2. Restore Snapshot

### Set id of the provisioned iaws-mongodb-cluster product
```terminal
export PP_ID=<pp-id>
```

### Set id of the version of the provisioned iaws-mongodb-cluster product
```terminal
export MONGODB_ATLAS_CLUSTER_PRODUCT_VERSION="2.2.0-preview"
```

### Get available service actions for version
```terminal
aws servicecatalog list-service-actions --query "ServiceActionSummaries[?starts_with(Name, \`sc-mongodb-cluster-v${MONGODB_ATLAS_CLUSTER_PRODUCT_VERSION}\`)].[Name, Id]"
```

### Set id of the relevant service action. In this case, "restore-snapshot"
```terminal
export SA_ID=<act-id>
```

### Set id of the Snapshot to be restored
```terminal
export SNAPSHOT_ID_TO_BE_RESTORED=<id-of-the-snapshot>
```

### Execute the Service Action and get the 'record-id' of the operaton
```terminal
export SA_RECORD_ID=$(aws servicecatalog execute-provisioned-product-service-action \
    --provisioned-product-id ${PP_ID} \
    --service-action-id ${SA_ID} \
    --parameters SnapshotId="${SNAPSHOT_ID_TO_BE_RESTORED}" \
    --query "RecordDetail.RecordId" \
    --output text)
```

### Use the 'record-id' from the previous step to check the status of the operation
```terminal
watch -n 10 'aws servicecatalog describe-record --id ${SA_RECORD_ID} --query "RecordDetail.Status" --output text'
```
---

## Additional

Related [Documentation](https://devops.swisscom.com/docs/iaws/services/iaws-product-mongodb-cluster/index.html#service-actions-v210) on DevOps Portal