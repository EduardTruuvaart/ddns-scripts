Bash script that implement Dynamic DNS service on top of AWS Route53.

## Usage
In this example I am using UDM Pro to run the script, but it should work on any Unix based system.

### Setup
1. Enable SSH on your UDM Pro
2. Install AWS CLI by following this [guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Create AWS user that will have `route53:ChangeResourceRecordSets` and `route53:ListResourceRecordSets` permissions. You can use the following policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Route53DDNS",
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/<hosted_zone_id>"
            ]
        }
    ]
}
```
4. Create AWS profile that will use user with permissions above by running the following command:
```
aws configure --profile <aws_profile>
```
5. SSH into your UDM Pro and create folder /root/ddns
6. Copy the scripts from this repo to /root/ddns by running the following commands:
```
7. scp ./aws_ddns_update.sh root@<Your IP here>:/root/ddns/
```
8. Go into /root/ddns/ folder and add execute permissions to the script by running the following command:
```
chmod +x /root/ddns/aws_ddns_update.sh
```
9. Create a cron job to run the script every 20 minutes by running the following command:
```
crontab -e
```
and add the following lines to the end of the file:
```
*/20 * * * * /root/ddns/aws_ddns_update.sh <hosted_zone_id> <domain_name> <aws_profile> >>/root/ddns/ddns.log 2>&1
0 2 * * * rm /root/ddns/ddns.log
```
First line will execute the script every 20 minutes and the second line will delete the log file every day at 2am. Log file will be located at /root/ddns/ddns.log.
