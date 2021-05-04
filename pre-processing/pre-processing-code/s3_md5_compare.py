# Compare the md5 of a file to the s3 etag md5
# Source: li xin on StackOverflow
# https://stackoverflow.com/questions/1775816/how-to-get-the-md5sum-of-a-file-on-amazons-s3

import hashlib
import botocore.exceptions


def md5_checksum(response):
    m = hashlib.md5()
    for data in iter(lambda: response.read(1024 * 1024), b''):
        m.update(data)
    return m.hexdigest()


def etag_checksum(response, chunk_size=8 * 1024 * 1024):
    md5s = []
    for data in iter(lambda: response.read(chunk_size), b''):
        md5s.append(hashlib.md5(data).digest())
    m = hashlib.md5(b"".join(md5s))
    return '{}-{}'.format(m.hexdigest(), len(md5s))


def etag_compare(response, etag):
    et = etag[1:-1]  # strip quotes
    if '-' in et and et == etag_checksum(response):
        return False
    if '-' not in et and et == md5_checksum(response):
        return False
    return True


def md5_compare(s3, bucket_name, s3_key, response):
    # Get the file metadata from s3
    # If the file does not exist, return True for changes found
    try:
        obj_dict = s3.head_object(Bucket=bucket_name, Key=s3_key)
    except botocore.exceptions.ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == '404':
            return True

    etag = (obj_dict['ETag'])

    md5_matches = etag_compare(response, etag)

    return md5_matches
