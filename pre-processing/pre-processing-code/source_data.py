import os
import boto3
import time
from urllib.request import urlopen
from urllib.error import URLError, HTTPError
from zipfile import ZipFile
from s3_md5_compare import md5_compare
from boto3.s3.transfer import TransferConfig
from io import BytesIO

def source_dataset(source_dataset_url):
    # source_dataset_url = "https://fred.stlouisfed.org/graph/fredgraph.csv?id=PERMIT"
    
    response = None
    retries = 5
    for attempt in range(retries):
        try:
            response = urlopen(source_dataset_url)
        except HTTPError as e:
            if attempt == retries:
                raise Exception('HTTPError: ', e.code)
            time.sleep(0.2 * attempt)
        except URLError as e:
            if attempt == retries:
                raise Exception('URLError: ', e.reason)
            time.sleep(0.2 * attempt)
        else:
            break
            
    if response is None:
        raise Exception('There was an issue downloading the dataset')
            
    data_set_name = os.environ['DATA_SET_NAME']

    data_dir = '/tmp'
    if not os.path.exists(data_dir):
        os.mkdir(data_dir)

    file_location = os.path.join(data_dir, data_set_name+'.csv')

    s3_bucket = os.environ['S3_BUCKET']
    s3 = boto3.client('s3')
    s3_resource = boto3.resource('s3')
    config = TransferConfig(multipart_threshold=1024*25, max_concurrency=10,
                            multipart_chunksize=1024*25, use_threads=True)

    s3_uploads = []
    asset_list = []

    obj_name = file_location.split('/', 3).pop().replace(' ', '_').lower()
    file_location = os.path.join(data_dir, obj_name)
    new_s3_key = data_set_name + '/dataset/' + obj_name
    filedata = response.read()

    has_changes = md5_compare(s3, s3_bucket, new_s3_key, BytesIO(filedata))
    if has_changes:
        s3_resource.Object(s3_bucket, new_s3_key).put(Body=filedata)
        # sys.exit(0)
        print('Uploaded: ' + file_location)
    else:
        print('No changes in: ' + file_location)

    asset_source = {'Bucket': s3_bucket, 'Key': new_s3_key}
    s3_uploads.append({'has_changes': has_changes, 'asset_source': asset_source})

    count_updated_data = sum(upload['has_changes'] == True for upload in s3_uploads)
    if count_updated_data > 0:
        asset_list = list(map(lambda upload: upload['asset_source'], s3_uploads))
        if len(asset_list) == 0:
            raise Exception('Something went wrong when uploading files to s3')

    # asset_list is returned to be used in lamdba_handler function
    # if it is empty, lambda_handler will not republish
    return asset_list

if __name__ == '__main__':
    source_dataset()