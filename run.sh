REARC_DATA_PLATFORM_ROLE_ARN='arn:aws:iam::412981388937:role/CrossAccountRole-796406704065-796406704065'
REARC_DATA_PLATFORM_EXTERNAL_ID='Rearc-Data-Platform-796406704065'
ASSET_BUCKET='rearc-data-provider'
MANIFEST_BUCKET='rearc-control-plane-manifest'
CUSTOMER_ID='796406704065'
DATASET_NAME='covid-19-deutschland-robert-koch-institut'
DATASET_ARN='arn:aws:dataexchange:us-east-1:796406704065:data-sets/bf2291eefaee2fdb12700a03e1e3257d'
PRODUCT_NAME='COVID-19 Deutschland | Robert Koch-Institut (RKI) | COVID-19 Germany'
PRODUCT_ID='prod-iakpotwzflj5e'
SCHEDULE_CRON="cron(0 9 * * ? *)"
REGION='us-east-1'
PROFILE='default'

echo "------------------------------------------------------------------------------"
echo "RearcDataPlatformRoleArn: $REARC_DATA_PLATFORM_ROLE_ARN"
echo "RearcDataPlatformExternalId: $REARC_DATA_PLATFORM_EXTERNAL_ID"
echo "CustomerId: $CUSTOMER_ID"
echo "AssetBucket: $ASSET_BUCKET"
echo "ManifestBucket: $MANIFEST_BUCKET"
echo "DataSetName: $DATASET_NAME"
echo "DataSetArn: $DATASET_ARN"
echo "ProductName: $PRODUCT_NAME"
echo "ProductID: $PRODUCT_ID"
echo "ScheduleCron: $SCHEDULE_CRON"
echo "Region: $REGION"
echo "PROFILE: $PROFILE"
echo "------------------------------------------------------------------------------"


# python pre-processing/pre-processing-code/source_data.py

./init.sh \
    --rdp-role-arn "${REARC_DATA_PLATFORM_ROLE_ARN}" \
    --rdp-external-id "${REARC_DATA_PLATFORM_EXTERNAL_ID}" \
    --customer-id "${CUSTOMER_ID}" \
    --schedule-cron "${SCHEDULE_CRON}" \
    --asset-bucket "${ASSET_BUCKET}" \
    --manifest-bucket "${MANIFEST_BUCKET}" \
    --dataset-name "${DATASET_NAME}" \
    --product-name "${PRODUCT_NAME}" \
    --product-id "${PRODUCT_ID}" \
    --dataset-arn "${DATASET_ARN}" \
    --region "${REGION}" \
    --first-revision "false" \
    --profile "${PROFILE}"
