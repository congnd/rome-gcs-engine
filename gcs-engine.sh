#!/usr/bin/env python3

import argparse
import os
import zipfile

from google.cloud import storage
from google.api_core.exceptions import NotFound


from pathlib import Path
from shutil import rmtree

# Commands
COMMAND_UPLOAD = 'upload'
COMMAND_DOWNLOAD = 'download'
COMMAND_LIST = 'list'

# GCS info
BUCKET = 'YOUR_BUCKET_ID'

# Colors
class bcolors:
  OKBLUE = '\033[94m'
  OKGREEN = '\033[92m'
  FAIL = '\033[91m'
  ENDC = '\033[0m'

parser = argparse.ArgumentParser()
subparsers = parser.add_subparsers(dest='command', required=True)

upload_parser = subparsers.add_parser(COMMAND_UPLOAD)
upload_parser.add_argument('local_path', help='local file to upload')
upload_parser.add_argument('remote_path', help='remote path to upload to')

download_parser = subparsers.add_parser(COMMAND_DOWNLOAD)
download_parser.add_argument('remote_path', help='remote path to download')
download_parser.add_argument('local_path', help='destination local path')

list_parser = subparsers.add_parser(COMMAND_LIST)
list_parser.add_argument('local_path', help='remote path for the local file')

kwargs = vars(parser.parse_args())
command = kwargs['command']

# Check for credentials
credential_path = str(Path.home()) + '/.gcp/rome.json'
if os.path.exists(credential_path) == False:
  print(f"{bcolors.FAIL}No credential found at {credential_path}{bcolors.ENDC}\n")
  exit(1)

# Instantiate the client
gcs_client = storage.Client.from_service_account_json(credential_path)
bucket = gcs_client.bucket(BUCKET)

if command == COMMAND_UPLOAD:
  local_path = kwargs['local_path']
  remote_path = kwargs['remote_path']
  
  print(f'{bcolors.OKBLUE}Uploading {local_path}{bcolors.ENDC}')

  blob = bucket.blob(remote_path)
  try:
    blob.upload_from_filename(local_path)
    print(f"{bcolors.OKGREEN}Upload done.{bcolors.ENDC}")
  except Exception as e:
    print(f"{bcolors.FAIL}Upload failed.{bcolors.ENDC}")
    print(f"{bcolors.FAIL}{e}{bcolors.ENDC}")
      
  # Cleanup
  path = Path(local_path)
  os.remove(local_path)
  rmtree(path.parents[0])
elif command == COMMAND_DOWNLOAD:
  remote_path = kwargs['remote_path']
  local_path = Path(kwargs['local_path'])

  print(f'{bcolors.OKBLUE}Downloading {remote_path}{bcolors.ENDC}')

  local_dir = os.path.dirname(local_path)
  Path(local_dir).mkdir(parents=True, exist_ok=True)

  blob = bucket.blob(remote_path)
  try:
    blob.download_to_filename(local_path)
    print(f"{bcolors.OKGREEN}Download done.{bcolors.ENDC}")
  except Exception as e:
    print(f"{bcolors.FAIL}Download failed.{bcolors.ENDC}")
    print(f"{bcolors.FAIL}{e}{bcolors.ENDC}")
elif command == COMMAND_LIST:
  local_path = kwargs['local_path']
  print(f'{bcolors.OKBLUE}Finding {local_path}.{bcolors.ENDC}')

  blob = bucket.get_blob(local_path)
  if not blob:
    print(f'{bcolors.FAIL}{local_path} does not exist.{bcolors.ENDC}')

print('')
