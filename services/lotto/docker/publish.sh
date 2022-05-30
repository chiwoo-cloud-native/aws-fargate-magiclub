#!/bin/bash
#
# Builds a Docker image and pushes to an AWS ECR repository
#
# Invoked by the terraform-aws-ecr-docker-image Terraform module.
#
# Usage:
#
# # Acquire an AWS session token
# $ ./publish.sh "111111111.dkr.ecr.ap-northeast-2.amazonaws.com/lotto" latest
#

set -e

repository_url="$1"
tag="$2"
region="$(echo "$repository_url" | cut -d. -f4)"

aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$repository_url"
docker push "$repository_url":"$tag"
