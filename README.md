# AWS S3 empty versioned bucket
A command to completely empty an AWS S3 Version enabled bucket, including objects, versions and delete markers

# Intallation

You will need the AWS CLI installed to run the script.

````bash
pip install awscli --upgrade --user
````

Once you have checked out the git repo, you need to ensure the script is executable.

````bash
$ chmod +x ./empty_versioned_bucket.sh
````

# Usage

````bash
$./empty_versioned_bucket.sh -b bucket [-p profile | -h help]  
````

  -p | --profile              : The local aws config profile name  
  -b | --bucket               : The bucket name to empty  
  -h | --help                 : Print this message  


You can pass a `profile` to authenticate with, or export your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to the env before running the command.

If you have a very large bucket, you can run this on an EC2 box within AWS network to reduce the latency.
