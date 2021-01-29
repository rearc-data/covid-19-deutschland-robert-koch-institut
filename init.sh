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
    "-s"|"--s3-bucket") export S3_BUCKET="$1"; shift;;
    "-d"|"--dataset-name") export DATASET_NAME="$1"; shift;;
    "-p"|"--product-name") export PRODUCT_NAME="$1"; shift;;
    "-i"|"--product-id") export PRODUCT_ID="$1"; shift;;
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

while [[ ${#PRODUCT_NAME} -gt 72 ]]; do
    echo "product-name must be under 72 characters in length, enter a shorter name:"
    read -p "New product-name: " PRODUCT_NAME
    case ${#PRODUCT_NAME} in
        [1-9]|[1-6][0-9]|7[0-2]) break;;
        * ) echo "Enter in a shorter product-name";;
    esac
done

#creating a pre-processing zip package, these commands may need to be adjusted depending on folder structure and dependencies
(cd pre-processing/pre-processing-code && zip -r pre-processing-code.zip . -x "*.dist-info/*" -x "bin/*" -x "**/__pycache__/*")

#upload pre-preprocessing.zip to s3
echo "uploading pre-preprocessing.zip to s3"
aws s3 cp pre-processing/pre-processing-code/pre-processing-code.zip s3://$S3_BUCKET/$DATASET_NAME/automation/pre-processing-code.zip --region "$REGION$PROFILE"

#creating dataset on ADX
echo "creating dataset on ADX"
DATASET_COMMAND="aws dataexchange create-data-set --asset-type "S3_SNAPSHOT" --description file://dataset-description.md --name \"${PRODUCT_NAME}\" --region $REGION --output json $PROFILE"
DATASET_OUTPUT=$(eval $DATASET_COMMAND)
DATASET_ARN=$(echo $DATASET_OUTPUT | tr '\r\n' ' ' | jq -r '.Arn')
DATASET_ID=$(echo $DATASET_OUTPUT | tr '\r\n' ' ' | jq -r '.Id')

#creating pre-processing cloudformation stack
echo "creating pre-processing cloudformation stack"
CFN_STACK_NAME="producer-${DATASET_NAME}-preprocessing"
aws cloudformation create-stack --stack-name "$CFN_STACK_NAME" --template-body file://pre-processing/pre-processing-cfn.yaml --parameters ParameterKey=S3Bucket,ParameterValue="$S3_BUCKET" ParameterKey=DataSetName,ParameterValue="$DATASET_NAME" ParameterKey=DataSetArn,ParameterValue="$DATASET_ARN" ParameterKey=ProductId,ParameterValue="$PRODUCT_ID" ParameterKey=Region,ParameterValue="$REGION" --region "$REGION" --capabilities "CAPABILITY_AUTO_EXPAND" "CAPABILITY_NAMED_IAM" "CAPABILITY_IAM" $PROFILE

echo "waiting for cloudformation stack to complete"
aws cloudformation wait stack-create-complete --stack-name "$CFN_STACK_NAME" --region "$REGION" $PROFILE

if [[ $? -ne 0 ]]
then
  # Cloudformation stack created
  echo "Cloudformation stack creation failed"
  exit 1
fi

#invoking the pre-processing lambda function to create first dataset revision
echo "invoking the pre-processing lambda function to create first dataset revision"
LAMBDA_FUNCTION_NAME="source-for-${DATASET_NAME}"
# AWS CLI version 2 changes require explicitly declairing `--cli-binary-format raw-in-base64-out` for the format of the `--payload`
LAMBDA_FUNCTION_STATUS_CODE=$(aws lambda invoke --function-name "$LAMBDA_FUNCTION_NAME" --invocation-type "RequestResponse" --payload '{ "test": "event" }' response.json --cli-binary-format raw-in-base64-out --region "$REGION" --query 'StatusCode' --output text $PROFILE)

#grabbing dataset revision status
echo "grabbing dataset revision status"
DATASET_REVISION_STATUS=$(aws dataexchange list-data-set-revisions --data-set-id "$DATASET_ID" --region "$REGION" --query "sort_by(Revisions, &CreatedAt)[-1].Finalized" $PROFILE)

update () {
  echo ""
  echo "Manually create the ADX product and enter in the Product ID below:"
  read -p "Product ID: " NEW_PRODUCT_ID
  
  # Cloudformation stack update
  echo "updating pre-processing cloudformation stack"
  aws cloudformation update-stack --stack-name "$CFN_STACK_NAME" --use-previous-template --parameters ParameterKey=S3Bucket,ParameterValue="$S3_BUCKET" ParameterKey=DataSetName,ParameterValue="$DATASET_NAME" ParameterKey=DataSetArn,ParameterValue="$DATASET_ARN" ParameterKey=ProductId,ParameterValue="$NEW_PRODUCT_ID" ParameterKey=Region,ParameterValue="$REGION" --region "$REGION" --capabilities "CAPABILITY_AUTO_EXPAND" "CAPABILITY_NAMED_IAM" "CAPABILITY_IAM" $PROFILE

  echo "waiting for cloudformation stack update to complete"
  aws cloudformation wait stack-update-complete --stack-name "$CFN_STACK_NAME" --region "$REGION $PROFILE"

  if [[ $? -ne 0 ]]
  then
    echo "Cloudformation stack update failed"
    break
  fi
  echo "cloudformation stack update completed"
}

delete () {
  echo "Destroying the CloudFormation stack"
  aws cloudformation delete-stack --stack-name "$CFN_STACK_NAME" --region "$REGION" $PROFILE

  #check status of cloudformation stack delete action
  aws cloudformation wait stack-delete-complete --stack-name "$CFN_STACK_NAME" --region "$REGION" $PROFILE
  if [[ $? -eq 0 ]]
  then
    # Cloudformation stack deleted
    echo "CloudFormation stack successfully deleted"
    break
  else
    # Cloudformation stack deletion failed
    echo "Cloudformation stack deletion failed"
    exit 1
  fi
}

if [[ $DATASET_REVISION_STATUS == "true" ]]
then
  echo "Dataset revision completed successfully"
  echo ""

  while true; do
      echo "Do you want use this script to update the CloudFormation stack? If you enter 'n' your CloudFormation stack will be destroyed:"
      read -p "('y' to update / 'n' to destroy): " Y_N
      case $Y_N in
          [Yy]* ) update; exit;;
          [Nn]* ) delete; break;;
          * ) echo "Enter 'y' or 'n'.";;
      esac
  done

  echo "Manually create the ADX product and manually re-run the pre-processing CloudFormation template using the following params:"
  echo ""
  echo "S3Bucket: $S3_BUCKET"
  echo "DataSetName: $DATASET_NAME"
  echo "DataSetArn: $DATASET_ARN"
  echo "Region: $REGION"
  echo "S3Bucket: $S3_BUCKET"
  echo ""
  echo "For the ProductId param use the Product ID of the ADX product"

else
  echo "Dataset revision failed"
  cat response.json
fi