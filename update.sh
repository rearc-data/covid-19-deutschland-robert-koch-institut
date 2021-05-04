#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
#set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# Sets profile variable to an empty value by default, reassigns in while loop below if it was included as a parameter
PROFILE=""

while [[ $# -gt 0 ]]; do
  opt="${1}"
  shift;
  current_arg="$1"
  case ${opt} in
    "-d"|"--dataset-name") export DATASET_NAME="$1"; shift;;
    "-r"|"--region") export REGION="$1"; shift;;
    "-f"|"--profile") PROFILE=" --profile $1"; shift;;
    *) echo "ERROR: Invalid option: \""$opt"\"" >&2; exit 1;;
  esac
done

while [[ ${#DATASET_NAME} -gt 53 ]]; do
    echo "dataset-name must be under 53 characters in length, enter a shorter name:"
    read -p "New dataset-name: " DATASET_NAME
    case ${#DATASET_NAME} in
        [1-9]|[1-4][0-9]|5[0-3]) break;;
        * ) echo "Enter in a shorter dataset-name";;
    esac
done

#get existing cloudformation stack
echo "getting existing CFN parameters"
CFN_STACK_NAME="producer-${DATASET_NAME}-preprocessing"
while read parameter_name parameter_value; do
  echo "$parameter_name: $parameter_value"
  case ${parameter_name} in
    "S3Bucket") export S3_BUCKET="$parameter_value";;
    "DataSetArn") export DATASET_ARN="$parameter_value";;
    "ProductId") export PRODUCT_ID="$parameter_value";;
    #Ignore these two because they were set manually already
    "Region");;
    "DataSetName");;
    *) echo "ERROR: Invalid parameter found: \""$parameter_name"\", please update manually" >&2; exit 1;;
  esac
done < <(aws cloudformation describe-stacks --stack-name $CFN_STACK_NAME --query 'Stacks[0].Parameters' --output text$PROFILE)

#creating a pre-processing zip package, these commands may need to be adjusted depending on folder structure and dependencies
(cd pre-processing/pre-processing-code && zip -r pre-processing-code.zip . -x "*.dist-info/*" -x "bin/*" -x "**/__pycache__/*")

#upload pre-preprocessing.zip to s3
echo "uploading pre-preprocessing.zip to s3"
aws s3 cp pre-processing/pre-processing-code/pre-processing-code.zip s3://$S3_BUCKET/$DATASET_NAME/automation/pre-processing-code.zip --region $REGION$PROFILE

#invoking the pre-processing lambda function to create first dataset revision
echo "updating the pre-processing lambda function code"
LAMBDA_FUNCTION_NAME="source-for-${DATASET_NAME}"
# AWS CLI version 2 changes require explicitly declairing `--cli-binary-format raw-in-base64-out` for the format of the `--payload`
aws lambda update-function-code --function-name $LAMBDA_FUNCTION_NAME --s3-bucket $S3_BUCKET --s3-key $DATASET_NAME/automation/pre-processing-code.zip$PROFILE
echo "updated lambda function code to use latest pre-processing.zip"

#updating pre-processing cloudformation stack
echo "updating pre-processing cloudformation stack"
CFN_STACK_NAME="producer-${DATASET_NAME}-preprocessing"
aws cloudformation update-stack --stack-name $CFN_STACK_NAME --template-body file://pre-processing/pre-processing-cfn.yaml --parameters ParameterKey=S3Bucket,ParameterValue=$S3_BUCKET ParameterKey=DataSetName,ParameterValue=$DATASET_NAME ParameterKey=DataSetArn,ParameterValue=$DATASET_ARN ParameterKey=ProductId,ParameterValue=$PRODUCT_ID ParameterKey=Region,ParameterValue=$REGION --region $REGION --capabilities "CAPABILITY_AUTO_EXPAND" "CAPABILITY_NAMED_IAM" "CAPABILITY_IAM"$PROFILE

echo "waiting for cloudformation stack update to complete"
aws cloudformation wait stack-update-complete --stack-name $CFN_STACK_NAME --region $REGION$PROFILE

if [[ $? -ne 0 ]]
then
  echo "Cloudformation stack update failed"
  break
fi
echo "cloudformation stack update completed"
