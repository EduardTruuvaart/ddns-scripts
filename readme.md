## What is Dynamic DNS?
In a typical scenario, when you connect to the internet through an Internet Service Provider (ISP), you are assigned an IP address. However, in some cases, this IP address may change periodically, especially for users with dynamic IP addresses. This can cause a problem if you're trying to access a device or service on your network from the internet, such as a web server or a camera, because the IP address might change, and you would need to know the new address each time.

Dynamic DNS is solving a problem for individuals or small businesses that don't have a static IP address provided by their ISP and need a way to maintain a consistent way of accessing their network resources from the internet.

## Contents
This repo contains a script that will update AWS Route53 record with your current public IP address. It will also create a log file that will contain the output of the script. The script will only update the record if the IP address has changed.

## Usage
In this example I am using UDM Pro to run the script, but it should work on any Unix based system.

### Setup
1. Enable SSH on your UDM Pro
2. Download AWS CLI as described in a following [guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Install AWS CLI to selected location by running the following command:
```
/root/aws/install -i /root/awscli/ -b /root/awscli/bin
```
4. Create AWS user that will have `route53:ChangeResourceRecordSets` and `route53:ListResourceRecordSets` permissions. You can use the following policy:
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
5. Create AWS profile that will use user with permissions above by running the following command:
```
aws configure --profile <aws_profile>
```
6. SSH into your UDM Pro and create folder /root/ddns
7. Copy the scripts from this repo to /root/ddns by running the following commands:
```
scp ./aws_ddns_update.sh root@<Your IP here>:/root/ddns/
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
