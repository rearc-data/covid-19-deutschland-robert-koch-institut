import time
import json
from source_data import source_dataset
import os
import logging
from datetime import date, datetime
from multiprocessing.dummy import Pool

from rearc_data_utils.platform.sts_helper import get_data_plane_client

logger = logging.getLogger(__name__)

os.environ['AWS_DATA_PATH'] = '/opt/'

rdp_role_arn = os.getenv("RDP_ROLE_ARN")
rdp_external_id = os.getenv("RDP_EXTERNAL_ID")

product_id = os.getenv("PRODUCT_ID", "blank")
dataset_arn = os.getenv("DATASET_ARN")
dataset_id = dataset_arn.split('/', 1)[1]
dataset_name = os.getenv("DATASET_NAME")

asset_bucket = os.getenv("ASSET_BUCKET")
manifest_bucket = os.getenv("MANIFEST_BUCKET")
customer_id = os.getenv("CUSTOMER_ID")

timestamp = datetime.now().strftime("%Y-%m-%d-%H%M%S")
revision_comment = 'Revision Updates v' + timestamp

required_env_vars = [ rdp_role_arn, rdp_external_id, product_id, dataset_arn, dataset_name, asset_bucket, manifest_bucket, customer_id ]
for v in required_env_vars:
	if not v:
		raise Exception(f"'{v.upper()}' environment variable must be defined!")

logger.info(f"rdp_role_arn: {rdp_role_arn} ; rdp_external_id: {rdp_external_id}")

s3 = get_data_plane_client(rdp_role_arn, rdp_external_id, service_name='s3')


def upload_manifest_file(asset_list):
    """ 
        Generates and uploads a manifest file to the MANIFEST_BUCKET of the 
        Rearc Data Platform or AWS Data Exchange Publisher Coordinator
        https://github.com/rearc-data/aws-data-exchange-publisher-coordinator
    """
    manifest_file_data = {
        "product_id": product_id,
        "dataset_id": dataset_id,
        "asset_list": asset_list
    }

    manifest_file_name = f"manifest-{timestamp}.json"
    manifest_object_key = os.path.join(customer_id, product_id, dataset_id, manifest_file_name)

    s3.put_object(Body=json.dumps(manifest_file_data), Bucket=manifest_bucket, Key=manifest_object_key, ACL="bucket-owner-full-control")


def lambda_handler(event, context):
    asset_list = source_dataset()

    if asset_list:
        try:
            upload_manifest_file(asset_list)
        except Exception as e:
            raise Exception(f"Something went wrong when uploading manifest file to manifest bucket: {e}")
