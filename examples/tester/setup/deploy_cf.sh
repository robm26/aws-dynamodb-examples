echo This script will deploy the CloudFormation tester-tables stack that creates four DynamoDB tables and an S3 bucket.
echo It will also put resource policies on all tables and replicas.
echo You may pass in three arguments for the regions to use for the global table replicas. 

REGION=$AWS_REGION

if [ -z "$REGION" ]; then
    echo Please set AWS_REGION environment variable
    echo i.e. run:
    echo export AWS_REGION=us-east-1
    exit
fi

GTregion1=$AWS_REGION
GTregion2="us-east-2"
GTregion3="us-west-2"

# use cmd line args to override default regions if provided
if [[ -n "$1" ]]; then GTregion1="$1"; fi
if [[ -n "$2" ]]; then GTregion2="$2"; fi
if [[ -n "$3" ]]; then GTregion3="$3"; fi

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "AWS Account ID: $ACCOUNT_ID"

echo "Creating Global Tables in the following regions:"
echo "GTregion1: $GTregion1"
echo "GTregion2: $GTregion2"
echo "GTregion3: $GTregion3"


aws cloudformation deploy --template-file ./tester_tables.yaml --stack-name tester-tables \
  --parameter-overrides GTregion1=$GTregion1 GTregion2=$GTregion2 GTregion3=$GTregion3

aws cloudformation wait stack-create-complete --stack-name tester-tables

# aws cloudformation describe-stacks --stack-name tester-tables --query "Stacks[0].Outputs[0].OutputValue" --output text

TESTER_BUCKET=$(aws cloudformation describe-stacks --stack-name tester-tables --query "Stacks[0].Outputs[0].OutputValue" --output text)
echo
echo "adding to file ../.env :"
echo TESTER_BUCKET=$TESTER_BUCKET

echo "TESTER_BUCKET=$TESTER_BUCKET" > ../.env

# put resource policies for MREC and MRSC tables

GTregion1=$AWS_REGION
GTregion2="us-east-2"
GTregion3="us-west-2"

echo "GTregion1: $GTregion1"
echo "GTregion2: $GTregion2"
echo "GTregion3: $GTregion3"

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "AWS Account ID: $ACCOUNT_ID"


MREC_POLICY1='{ "Version": "2012-10-17", "Statement": [ { "Sid": "AllowUserAccess1", "Effect": "Allow", "Principal": {"AWS": "'$ACCOUNT_ID'"}, "Action": ["dynamodb:*"], "Resource": "arn:aws:dynamodb:'$GTregion1':'$ACCOUNT_ID':table/MREC" }]}'
MREC_POLICY2='{ "Version": "2012-10-17", "Statement": [ { "Sid": "AllowUserAccess1", "Effect": "Allow", "Principal": {"AWS": "'$ACCOUNT_ID'"}, "Action": ["dynamodb:*"], "Resource": "arn:aws:dynamodb:'$GTregion2':'$ACCOUNT_ID':table/MREC" }]}'
MREC_POLICY3='{ "Version": "2012-10-17", "Statement": [ { "Sid": "AllowUserAccess1", "Effect": "Allow", "Principal": {"AWS": "'$ACCOUNT_ID'"}, "Action": ["dynamodb:*"], "Resource": "arn:aws:dynamodb:'$GTregion3':'$ACCOUNT_ID':table/MREC" }]}'

aws dynamodb put-resource-policy --resource-arn arn:aws:dynamodb:$GTregion1:$ACCOUNT_ID:table/MREC --policy "$MREC_POLICY1" --region $GTregion1
aws dynamodb put-resource-policy --resource-arn arn:aws:dynamodb:$GTregion2:$ACCOUNT_ID:table/MREC --policy "$MREC_POLICY2" --region $GTregion2
aws dynamodb put-resource-policy --resource-arn arn:aws:dynamodb:$GTregion3:$ACCOUNT_ID:table/MREC --policy "$MREC_POLICY3" --region $GTregion3

MRSC_POLICY1='{ "Version": "2012-10-17", "Statement": [ { "Sid": "AllowUserAccess1", "Effect": "Allow", "Principal": {"AWS": "'$ACCOUNT_ID'"}, "Action": ["dynamodb:*"], "Resource": "arn:aws:dynamodb:'$GTregion1':'$ACCOUNT_ID':table/MREC" }]}'
MRSC_POLICY2='{ "Version": "2012-10-17", "Statement": [ { "Sid": "AllowUserAccess1", "Effect": "Allow", "Principal": {"AWS": "'$ACCOUNT_ID'"}, "Action": ["dynamodb:*"], "Resource": "arn:aws:dynamodb:'$GTregion2':'$ACCOUNT_ID':table/MREC" }]}'
MRSC_POLICY3='{ "Version": "2012-10-17", "Statement": [ { "Sid": "AllowUserAccess1", "Effect": "Allow", "Principal": {"AWS": "'$ACCOUNT_ID'"}, "Action": ["dynamodb:*"], "Resource": "arn:aws:dynamodb:'$GTregion3':'$ACCOUNT_ID':table/MREC" }]}'

aws dynamodb put-resource-policy --resource-arn arn:aws:dynamodb:$GTregion1:$ACCOUNT_ID:table/MRSC --policy "$MRSC_POLICY1" --region $GTregion1
aws dynamodb put-resource-policy --resource-arn arn:aws:dynamodb:$GTregion2:$ACCOUNT_ID:table/MRSC --policy "$MRSC_POLICY2" --region $GTregion2
aws dynamodb put-resource-policy --resource-arn arn:aws:dynamodb:$GTregion3:$ACCOUNT_ID:table/MRSC --policy "$MRSC_POLICY3" --region $GTregion3



# aws cloudformation validate-template --template-body file://tester_tables.yaml

# aws cloudformation create-change-set   --stack-name tester-tables --change-set-name TesterChangeSetDryRun --template-body file://tester_tables.yaml 
# aws cloudformation describe-change-set --stack-name tester-tables --change-set-name TesterChangeSetDryRun 


# aws cloudformation delete-stack --stack-name tester-tables
# aws cloudformation wait stack-delete-complete --stack-name tester-tables

