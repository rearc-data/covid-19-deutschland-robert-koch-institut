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
    "--rdp-role-arn") export REARC_DATA_PLATFORM_ROLE_ARN="$1"; shift;;
    "--rdp-external-id") export REARC_DATA_PLATFORM_EXTERNAL_ID="$1"; shift;;
    "--customer-id") export CUSTOMER_ID="$1"; shift;;
    "--schedule-cron") export SCHEDULE_CRON="$1"; shift;;
    "--asset-bucket") export ASSET_BUCKET="$1"; shift;;
    "--manifest-bucket") export MANIFEST_BUCKET="$1"; shift;;
    "--dataset-name") export DATASET_NAME="$1"; shift;;
    "--product-name") export PRODUCT_NAME="$1"; shift;;
    "--product-id") export PRODUCT_ID="$1"; shift;;
    "--dataset-arn") export DATASET_ARN="$1"; shift;;
    "--region") export REGION="$1"; shift;;
    "--first-revision") export FIRST_REVISION="$1"; shift;;
    "--products-info-file") export PRODUCTS_INFO_FILE="$1"; shift;;
    "--source-url") export SOURCE_URL="$1"; shift;;
    "--product-code") export PRODUCT_CODE="$1"; shift;;
    "--product-url") export PRODUCT_URL="$1"; shift;;
    "--profile") PROFILE=" --profile $1"; shift;;
    *) echo "ERROR: Invalid option: \""$opt"\"" >&2; exit 1;;
  esac
done

echo "------------------------------------------------------------------------------"
echo "REARC_DATA_PLATFORM_ROLE_ARN: $REARC_DATA_PLATFORM_ROLE_ARN"
echo "REARC_DATA_PLATFORM_EXTERNAL_ID: $REARC_DATA_PLATFORM_EXTERNAL_ID"
echo "CUSTOMER_ID: $CUSTOMER_ID"
echo "ASSET_BUCKET: $ASSET_BUCKET"
echo "MANIFEST_BUCKET: $MANIFEST_BUCKET"
echo "DATASET_NAME: $DATASET_NAME"
echo "DATASET_ARN: $DATASET_ARN"
echo "PRODUCT_NAME: $PRODUCT_NAME"
echo "PRODUCT_ID: $PRODUCT_ID"
echo "SCHEDULE_CRON: $SCHEDULE_CRON"
echo "REGION: $REGION"
echo "PROFILE: $PROFILE"
echo "PRODUCTS_INFO_FILE: $PRODUCTS_INFO_FILE"
echo "SOURCE_URL: $SOURCE_URL"
echo "PRODUCT_CODE: $PRODUCT_CODE"
echo "PRODUCT_URL: $PRODUCT_URL"
echo "FIRST_REVISION: $FIRST_REVISION"
echo "------------------------------------------------------------------------------"

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

echo "creating a pre-processing zip package, these commands may need to be adjusted depending on folder structure and dependencies"
(cd pre-processing/pre-processing-code && zip -r pre-processing-code.zip . -x "*.dist-info/*" -x "bin/*" -x "**/__pycache__/*")

echo "uploading pre-preprocessing.zip to s3"
aws s3 cp pre-processing/pre-processing-code/pre-processing-code.zip s3://$ASSET_BUCKET/$DATASET_NAME/automation/pre-processing-code.zip --region "$REGION" $PROFILE

if [[ "$FIRST_REVISION" == "true" ]]; then
  echo "creating dataset on ADX"
  DATASET_COMMAND="aws dataexchange create-data-set --asset-type "S3_SNAPSHOT" --description file://dataset-description.md --name \"${PRODUCT_NAME}\" --region $REGION --output json $PROFILE"
  DATASET_OUTPUT=$(eval $DATASET_COMMAND)
  DATASET_ARN=$(echo $DATASET_OUTPUT | tr '\r\n' ' ' | jq -r '.Arn')
  DATASET_ID=$(echo $DATASET_OUTPUT | tr '\r\n' ' ' | jq -r '.Id')

  if [[ -n "$PRODUCTS_INFO_FILE" ]]; then
    echo "{\"PRODUCT_CODE\":\"${PRODUCT_CODE}\",\"PRODUCT_URL\":\"${PRODUCT_URL}\",\"SOURCE_URL\": \"${SOURCE_URL}\",\"DATASET_NAME\":\"${DATASET_NAME}\",\"DATASET_ARN\":\"${DATASET_ARN}\",\"DATASET_ID\":\"${DATASET_ID}\",\"PRODUCT_NAME\":\"${PRODUCT_NAME}\",\"PRODUCT_ID\":\"${PRODUCT_ID}\",\"SCHEDULE_CRON\":\"${SCHEDULE_CRON}\"}" >> "$PRODUCTS_INFO_FILE"
  fi

  echo "Uploading intial assets to asset_bucket for the first revision"
  aws s3 cp product-description.md "s3://$ASSET_BUCKET/$DATASET_NAME/dataset/product-description.md"
  aws s3 cp dataset-description.md "s3://$ASSET_BUCKET/$DATASET_NAME/dataset/dataset-description.md"

  REVISION_COMMAND="aws dataexchange create-data-set --asset-type "S3_SNAPSHOT" --description file://dataset-description.md --name \"${PRODUCT_NAME}\" --region $REGION --output json $PROFILE"
  REVISION_OUTPUT=$(eval $REVISION_COMMAND)

  echo "Manually, from ADX console, create the first revision of the dataset using 
        product-description.md and dataset-description.md files and
        then create the ADX product. 
        Then manually re-run the pre-processing CloudFormation template using the following params:"
  echo ""
  echo "AssetBucket: $ASSET_BUCKET"
  echo "ManifestBucket: $MANIFEST_BUCKET"
  echo "CustomerId: $CUSTOMER_ID"
  echo "DataSetName: $DATASET_NAME"
  echo "DataSetArn: $DATASET_ARN"
  echo "Region: $REGION"
  echo "FIRST_REVISION: false"
  echo ""
  echo "For the ProductId param use the Product ID of the ADX product"

else
  DATASET_ID=$(echo $DATASET_ARN | awk -F/ '{print $NF}')

  echo "creating pre-processing cloudformation stack"
  CFN_STACK_NAME="producer-${DATASET_NAME}-preprocessing"
  aws cloudformation create-stack --stack-name "$CFN_STACK_NAME" --template-body file://pre-processing/pre-processing-cfn.yaml --parameters ParameterKey=RearcDataPlatformRoleArn,ParameterValue="$REARC_DATA_PLATFORM_ROLE_ARN" ParameterKey=RearcDataPlatformExternalId,ParameterValue="$REARC_DATA_PLATFORM_EXTERNAL_ID" ParameterKey=AssetBucket,ParameterValue="$ASSET_BUCKET" ParameterKey=ManifestBucket,ParameterValue="$MANIFEST_BUCKET" ParameterKey=CustomerId,ParameterValue="$CUSTOMER_ID" ParameterKey=DataSetName,ParameterValue="$DATASET_NAME" ParameterKey=DataSetArn,ParameterValue="$DATASET_ARN" ParameterKey=ProductId,ParameterValue="$PRODUCT_ID" ParameterKey=Region,ParameterValue="$REGION" ParameterKey=ScheduleCron,ParameterValue="'$SCHEDULE_CRON'" --region "$REGION" --capabilities "CAPABILITY_AUTO_EXPAND" "CAPABILITY_NAMED_IAM" "CAPABILITY_IAM" $PROFILE

  echo "waiting for cloudformation stack creation to complete"
  aws cloudformation wait stack-create-complete --stack-name "$CFN_STACK_NAME" --region "$REGION" $PROFILE

  if [[ $? -ne 0 ]]; then
    echo "Cloudformation stack creation failed"
    exit 1
  fi

  echo "invoking the pre-processing lambda function to upload manifest file to manifest bucket"
  LAMBDA_FUNCTION_NAME="source-for-${DATASET_NAME}"
  # AWS CLI version 2 changes require explicitly declairing `--cli-binary-format raw-in-base64-out` for the format of the `--payload`
  aws lambda invoke --function-name "$LAMBDA_FUNCTION_NAME" --invocation-type "RequestResponse" --payload '{ "test": "event" }' response.json --cli-binary-format raw-in-base64-out --region "$REGION" --query 'StatusCode' --output text $PROFILE

  if [[ $? -ne 0 ]]; then
    echo "Lambda invocation failed"
    exit 1
  fi

fi
