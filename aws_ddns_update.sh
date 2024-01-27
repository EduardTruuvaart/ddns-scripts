#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <hosted_zone_id> <domain_name> <aws_profile>"
  exit 1
fi

HOSTED_ZONE_ID="$1"
DOMAIN_NAME="$2"
AWS_PROFILE="$3"

# echo "HOSTED_ZONE_ID: $HOSTED_ZONE_ID"
# echo "DOMAIN_NAME: $DOMAIN_NAME"
# echo "AWS_PROFILE: $AWS_PROFILE"

# Fetch the public IP address
PUBLIC_IP=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')

# Update the Route 53 A record
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch '{
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'"$DOMAIN_NAME"'",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [
            {
              "Value": "'"$PUBLIC_IP"'"
            }
          ]
        }
      }
    ]
  }' \
  --profile $AWS_PROFILE

echo "A record updated with public IP: $PUBLIC_IP"