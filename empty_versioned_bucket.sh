#!/bin/bash

set -e

function usage {
    echo "usage: empty_versioned_bucket.sh -b bucket [-p profile | -h help]"
    echo "   ";
    echo "  -p | --profile              : The local aws config profile name";
    echo "  -b | --bucket               : The bucket name to empty";
    echo "  -h | --help                 : Print this message";
}


while [ "$1" != "" ]; do
    case "$1" in
        -p | --profile )            shift
                                    profile="--profile $1"
                                    ;;
        -b | --bucket )             shift
                                    bucket="$1"
                                    ;;
        -h | --help )               usage
                                    exit
                                    ;;
        * )                         usage
                                    exit 1
    esac
    shift
done


if [[ -z "$bucket" ]]; then
    usage
    exit;
fi



function removeObjects() {
  echo "Preparing batch of 100 objects to delete"
  echo ""

  cmd="aws s3api list-object-versions --bucket $bucket --max-items 100 $profile"
  echo $cmd
  objects=`$cmd`

  versions=`echo $objects |jq '.Versions'`
  markers=`echo $objects |jq '.DeleteMarkers'`
  next=`echo $objects |jq '.NextToken'`

  echo "removing files"
  delete "${versions[@]}"

  echo "removing delete markers"
  delete "${markers[@]}"

  if [ -z "$next" ]
  then
    echo "Delete Done"
  else
    removeObjects
  fi
}



function delete() {
  srcObjects=("$@")
  objects=""

  total=$(echo ${srcObjects} |jq 'length')

  echo "found $total objects to delete"
  echo " "

  if [[ $total == 0 ]] ; then
    return 0
  fi

  index=0
  count=0

  for srcObj in $(echo "${srcObjects}" | jq -r '.[] | @base64'); do

    ((count+=1))
    ((index+=1))

    version=$(echo ${srcObj} | base64 --decode)
    key=`echo $version | jq -r .Key`
    versionId=`echo $version | jq -r .VersionId `

    clearLastLine
    echo "Preparing to remove $key at version $versionId"

    obj="\"Key\":\"$key\""
    if [ "$versionId" != "null" ]
    then
      obj="$obj,\"VersionId\":\"$versionId\""
    fi

    objects="$objects{$obj},"

    if [[ -n "$objects" ]] && (( $count == 100 || $index == $total))  ; then

      #trim the traling comma
      objects=${objects%?}

      #build the JSON doc
      json="{\"Objects\": [$objects],\"Quiet\":false}"
      echo $json > "delete.json"
      cmd="aws s3api delete-objects --bucket ${bucket} --delete file://delete.json $profile"
      $cmd

      exit_status=$?
      if [[ $exit_status -ne 0 ]]; then
        echo "Failed to delete objects with the following command"
        echo $cmd
        enableVersioning
        exit $exit_status
      else
        objects=""
        count=0
      fi
    fi
  done
}




function disableVersioning() {
  echo "Disabling versioning..."
  cmd="aws s3api put-bucket-versioning --bucket $bucket $profile --versioning-configuration Status=Suspended"
  echo $cmd
  $cmd
}

function enableVersioning() {
  echo "Enabling versioning..."
  cmd="aws s3api put-bucket-versioning --bucket $bucket $profile --versioning-configuration Status=Enabled"
  echo $cmd
  $cmd
}

function clearLastLine() {
  tput cuu 1 && tput el
}

function deleteAll() {
  echo "Removing all versions from $bucket"
  echo ""
  disableVersioning
  removeObjects
  enableVersioning
  rm ./delete.json
}



deleteAll
