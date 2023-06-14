#!/bin/bash

DEF_STS_PROFILE="terra"
DEF_STS_REGION="ap-northeast-2"

set -euo pipefail

if ! command -v jq &> /dev/null
then
    JQ_PATH="${PWD}/jq"
    curl -sL -o ${JQ_PATH} "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"
    chmod +x ${JQ_PATH}
else
    JQ_PATH=$(which jq)
fi

read -p 'Enter the MFA code : ' MFA_CODE
export PROFILE="terra"
export MFA_ARN="arn:aws:iam::438916407893:mfa/seonbo.shim@bespinglobal.com"

if [  $# -ge 1 ]
  then
    export PROFILE=$1
fi

if [ $# -ge 2 ]
  then
    export MFA_ARN=$2
fi

echo "aws sts get-session-token --serial-number ${MFA_ARN} --token-code ${MFA_CODE} --profile ${PROFILE}"

CRED_DATA=$(aws sts get-session-token --serial-number ${MFA_ARN} --token-code ${MFA_CODE} --profile ${PROFILE})

AWS_ACCESS_KEY_ID=$(${JQ_PATH} -r '.Credentials.AccessKeyId' <<< "${CRED_DATA}")
AWS_SECRET_ACCESS_KEY=$(${JQ_PATH} -r '.Credentials.SecretAccessKey' <<< "${CRED_DATA}")
AWS_SESSION_TOKEN=$(${JQ_PATH} -r '.Credentials.SessionToken' <<< "${CRED_DATA}")

aws configure set region ${DEF_STS_REGION} --profile ${DEF_STS_PROFILE}
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID} --profile ${DEF_STS_PROFILE}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY} --profile ${DEF_STS_PROFILE}
aws configure set aws_session_token ${AWS_SESSION_TOKEN} --profile ${DEF_STS_PROFILE}


echo "USAGE"
echo "./mfa.sh"
echo "./mfa.sh <YOUR_AWS_PROFILE>"
echo "./mfa.sh <YOUR_AWS_PROFILE> <YOUR_AWS_MFA_ARN>"

echo ""
echo "Now you have got STS Token and registration AWS Profile to '${DEF_STS_PROFILE}'"
echo "You can check access by profile ${DEF_STS_PROFILE}"
echo "ex) aws s3 ls --profile ${DEF_STS_PROFILE}"
echo ""
