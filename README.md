# AWS S3 empty versioned bucket
A command to completely empty an AWS S3 Version enabled bucket, including objects, versions and delete markers

# Installation

Once you have checked out the git repo, you need to ensure the script is executable.

````bash
$ chmod +x ./empty_versioned_bucket.sh
````

# Usage

````bash
$ python ./emptyVersionedBucket.sh -b bucket-to-empty -p my-creds
````

usage: emptyVersionedBucket.py [-h] -b BUCKET [-p PROFILE] [-d]

Delete all objects and versions from Version Enabled S3 Bucket

optional arguments:
  -h, --help            show this help message and exit
  -b BUCKET, --bucket BUCKET
                        A valid s3 bucket name
  -p PROFILE, --profile PROFILE
                        A AWS profile name located in ~/.aws/config
  -d, --delete_bucket   Remove the bucket after emptying


You can pass a `profile` to authenticate with, or export your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to the env before running the command.
