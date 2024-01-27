#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <access_key> <secret_key> <hosted_zone_id> <domain_name>"
  exit 1
fi

AWS_ACCESS_KEY="$1"
AWS_SECRET_KEY="$2"
HOSTED_ZONE_ID="$3"
DOMAIN_NAME="$4"

# Fetch the public IP address
PUBLIC_IP=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')

# Construct the AWS authentication header
AUTH_HEADER="Authorization: AWS $AWS_ACCESS_KEY:$AWS_SECRET_KEY"

echo "AWS_ACCESS_KEY: $AWS_ACCESS_KEY"
echo "AWS_SECRET_KEY: $AWS_SECRET_KEY"
echo "HOSTED_ZONE_ID: $HOSTED_ZONE_ID"
echo "DOMAIN_NAME: $DOMAIN_NAME"
echo "Public IP: $PUBLIC_IP"

# Update the Route 53 A record using curl
curl -X POST "https://route53.amazonaws.com/2013-04-01/hostedzone/$HOSTED_ZONE_ID/rrset" \
  -H "$AUTH_HEADER" \
  -H "Content-Type: application/xml" \
  --data "<ChangeResourceRecordSetsRequest xmlns=\"https://route53.amazonaws.com/doc/2013-04-01/\">
    <ChangeBatch>
      <Changes>
        <Change>
          <Action>UPSERT</Action>
          <ResourceRecordSet>
            <Name>$DOMAIN_NAME</Name>
            <Type>A</Type>
            <TTL>300</TTL>
            <ResourceRecords>
              <ResourceRecord>
                <Value>$PUBLIC_IP</Value>
              </ResourceRecord>
            </ResourceRecords>
          </ResourceRecordSet>
        </Change>
      </Changes>
    </ChangeBatch>
  </ChangeResourceRecordSetsRequest>"
