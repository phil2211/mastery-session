#!/bin/bash
#Queries a service-catalog operation with its record-id to get the status

if [ -z "$1" ]; then
    echo "Usage: $0 <record_id>"
    exit 1
fi

record_id="$1"

response=$(aws servicecatalog describe-record --id "${record_id}" --query 'RecordDetail.Status') 

echo "Status: ${response}"