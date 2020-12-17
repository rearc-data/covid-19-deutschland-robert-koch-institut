import os
import boto3
from urllib.request import urlopen
from urllib.error import URLError, HTTPError
import csv
import json

def source_dataset(new_filename, s3_bucket, new_s3_key):

	source_dataset_url = 'https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv'
	file_location = '/tmp/' + new_filename

	s3_resource = boto3.resource('s3')
	asset_list = []

	try:
		response = urlopen(source_dataset_url)

	except HTTPError as e:
		raise Exception('HTTPError: ', e.code, source_dataset_url)

	except URLError as e:
		raise Exception('URLError: ', e.reason, source_dataset_url)

	else:
		s3 = boto3.client('s3')
		
		filename_csv = file_location + '.csv'
		with open(filename_csv, 'wb') as c:
			c.write(response.read())
			
		s3.upload_file(filename_csv, s3_bucket, new_s3_key + filename_csv.split('/')[-1])
		asset_list.append({'Bucket': s3_bucket, 'Key': new_s3_key + filename_csv.split('/')[-1]})
		
		data_json = None
		with open(filename_csv, 'r', encoding='utf-8-sig') as r:
			reader = csv.DictReader(r)
			data_json = ',\n'.join(json.dumps(row, ensure_ascii=False) for row in reader)
		
		os.remove(filename_csv)
		
		filename_json = file_location + '.json'
		with open(filename_json, 'w', encoding='utf-8') as j:
			j.write('[')
			j.write(data_json)
			j.write(']')
			
		s3.upload_file(filename_json, s3_bucket, new_s3_key + filename_json.split('/')[-1])
		asset_list.append({'Bucket': s3_bucket, 'Key': new_s3_key + filename_json.split('/')[-1]})
		os.remove(filename_json)
		
		print(asset_list)

	return asset_list
