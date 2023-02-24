#!/bin/bash

uuid="a$(cat /proc/sys/kernel/random/uuid)"
if [ ! -z "$INPUT_PARAMETERS" ]; then
  PARAMETERS="--parameters ${INPUT_PARAMETERS}"
fi

aws cloudformation create-change-set --stack-name $INPUT_STACK_NAME $PARAMETERS --template-body file://$INPUT_TEMPLATE_BODY --change-set-name=$uuid --capabilities CAPABILITY_IAM
if [ $? -ne 0 ]; then
  echo "[ERROR] failed to create change set."
  exit 1
fi

for i in `seq 1 15`; do
  aws cloudformation describe-change-set --change-set-name=$uuid --stack-name=$INPUT_STACK_NAME --output=json > $uuid.json
  status=$(cat $uuid.json | jq -r '.Status')
  if [ ${status} = "CREATE_COMPLETE" ] || [ ${status} = "FAILED" ]; then
    break
  else
    echo "change set is now creating..."
    sleep 3
  fi
done

aws cloudformation delete-change-set --change-set-name=$uuid --stack-name=$INPUT_STACK_NAME
if [ $? -ne 0 ]; then
  echo "[ERROR] failed to delete change set."
fi

if [ ${status} != "CREATE_COMPLETE" ] && [ ${status} != "FAILED" ]; then
  echo "[ERROR] failed to create change set."
  exit 1
fi

echo "change_set_name=$uuid >> $GITHUB_OUTPUT"
echo "result_file_path=$uuid.json >> $GITHUB_OUTPUT"

python /pretty_format.py $uuid $INPUT_STACK_NAME
echo "::set-output name=diff_file_path::$uuid.html"
result=$(cat $uuid.html)
echo "::set-output name=result::$result"
