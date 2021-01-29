import time
import json
from source_data import source_dataset
import boto3
import os
from datetime import date, datetime
from multiprocessing.dummy import Pool

os.environ['AWS_DATA_PATH'] = '/opt/'

dataexchange = boto3.client(
	service_name='dataexchange',
	region_name=os.environ['REGION']
)

marketplace = boto3.client(
	service_name='marketplace-catalog',
	region_name=os.environ['REGION']
)

s3_bucket = os.environ['S3_BUCKET']
data_set_arn = os.environ['DATA_SET_ARN']
data_set_id = data_set_arn.split('/', 1)[1]
product_id = os.environ['PRODUCT_ID']
data_set_name = os.environ['DATA_SET_NAME']
new_s3_key = data_set_name + '/dataset/'
cfn_template = data_set_name + '/automation/cloudformation.yaml'
post_processing_code = data_set_name + '/automation/post-processing-code.zip'

today = date.today().strftime('%Y-%m-%d')
revision_comment = 'Revision Updates v' + today

if not s3_bucket:
	raise Exception("'S3_BUCKET' environment variable must be defined!")

if not new_s3_key:
	raise Exception("'DATA_SET_NAME' environment variable must be defined!")

if not data_set_arn:
	raise Exception("'DATA_SET_ARN' environment variable must be defined!")

if not product_id:
	raise Exception("'PRODUCT_ID' environment variable must be defined! {}".format(product_id))


def start_change_set(describe_entity_response, revision_arn):

	# Call AWSMarketplace Catalog's start-change-set API to add revisions to the Product
	change_details = {
		'DataSetArn': data_set_arn,
		'RevisionArns': [
			revision_arn
		]
	}

	change_set = [
		{
			'ChangeType': 'AddRevisions',
			'Entity': {
				'Identifier': describe_entity_response['EntityIdentifier'],
				'Type': describe_entity_response['EntityType']
			},
			'Details': json.dumps(change_details)
		}
	]

	response = marketplace.start_change_set(
		Catalog='AWSMarketplace', ChangeSet=change_set)
	return response


def jobs_handler(data):

	# Used to store the Ids of the Jobs importing the assets to S3.
	job_ids = set()

	print('asset_list {} of {}:'.format(
		data['job_num'], data['total_jobs']), data['asset_list'])

	import_job = dataexchange.create_job(
		Type='IMPORT_ASSETS_FROM_S3',
		Details={
			'ImportAssetsFromS3': {
				'DataSetId': data_set_id,
				'RevisionId': data['revision_id'],
				'AssetSources': data['asset_list']
			}
		}
	)

	# Start the Job and save the JobId.
	dataexchange.start_job(JobId=import_job['Id'])
	job_ids.add(import_job['Id'])

	# Iterate until all remaining jobs have reached a terminal state, or an error is found.
	completed_jobs = set()

	while job_ids != completed_jobs:
		for job_id in job_ids:
			if job_id in completed_jobs:
				continue
			get_job_response = dataexchange.get_job(JobId=job_id)
			if get_job_response['State'] == 'COMPLETED':
				print('JobId: {}, Job {} of {} completed'.format(
					job_id, data['job_num'], data['total_jobs']))
				completed_jobs.add(job_id)
			if get_job_response['State'] == 'ERROR':
				job_errors = get_job_response['Errors']
				raise Exception(
					'JobId: {} failed with errors:\n{}'.format(job_id, job_errors))
			# Sleep to ensure we don't get throttled by the GetJob API.
			time.sleep(.5)


def lambda_handler(event, context):
	asset_list = source_dataset()
	asset_lists = [asset_list[i:i+100] for i in range(0,len(asset_list), 100)]

	if type(asset_lists) == list:

		if len(asset_lists) == 0:
			print(
				'No need for a revision, all datasets included with this product are up to date')
			return {
				'statusCode': 200,
				'body': json.dumps('No need for a revision, all datasets included with this product are up to date')
			}

		create_revision_response = dataexchange.create_revision(DataSetId=data_set_id)
		revision_id = create_revision_response['Id']
		revision_arn = create_revision_response['Arn']

		for idx in range(len(asset_lists)):
			asset_lists[idx] = {
				'asset_list': asset_lists[idx],
				'revision_id': revision_id,
				'job_num': str(idx + 1),
				'total_jobs': str(len(asset_lists))
			}

		with (Pool(10)) as p:
			p.map(jobs_handler, asset_lists)

		update_revision_response = dataexchange.update_revision(
			DataSetId=data_set_id,
			RevisionId=revision_id,
			Comment=revision_comment,
			Finalized=True
		)

		revision_state = update_revision_response['Finalized']

		if revision_state == True:
			if product_id and product_id != 'blank':
				# Call AWSMarketplace Catalog's APIs to add revisions
				describe_entity_response = marketplace.describe_entity(
					Catalog='AWSMarketplace', EntityId=product_id)
				start_change_set_response = start_change_set(
					describe_entity_response, revision_arn)
				if start_change_set_response['ChangeSetId']:
					print('Revision updated successfully and added to the dataset')
					return {
						'statusCode': 200,
						'body': json.dumps('Revision updated successfully and added to the dataset')
					}
				else:
					print('Something went wrong with AWSMarketplace Catalog API')
					return {
						'statusCode': 500,
						'body': json.dumps('Something went wrong with AWSMarketplace Catalog API')
					}
			else:
				print('Initial dataset revision Created.')
		else:
			print('Revision did not complete successfully')
			return {
				'statusCode': 500,
				'body': json.dumps('Revision did not complete successfully')
			}
	else:
		raise Exception('Something went wrong when uploading files to s3')