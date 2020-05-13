
import os
import boto3
from urllib.request import urlopen
from urllib.error import URLError, HTTPError
import csv
import json

def source_dataset(new_filename, s3_bucket, new_s3_key):

	source_dataset_url = 'https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv'
	file_location = '/tmp/' + new_filename

	try:
		response = urlopen(source_dataset_url)

	except HTTPError as e:
		raise Exception('HTTPError: ', e.code, source_dataset_url)

	except URLError as e:
		raise Exception('URLError: ', e.reason, source_dataset_url)

	else:

		with open(file_location + '.csv', 'wb') as c:
			c.write(response.read())

		with open(file_location + '.csv', 'r', encoding='utf-8-sig') as r, open(file_location + '.json', 'w', encoding='utf-8') as j:
			reader = csv.DictReader(r)
			j.write('[')
			j.write(',\n'.join(json.dumps(row, ensure_ascii=False) for row in reader))
			j.write(']')

	asset_list = []

	# Creates S3 connection
	s3 = boto3.client('s3')

	# Looping through filenames, uploading to S3
	for filename in os.listdir('/tmp'):

		s3.upload_file('/tmp/' + filename, s3_bucket, new_s3_key + filename)

		asset_list.append({'Bucket': s3_bucket, 'Key': new_s3_key + filename})

	return asset_list