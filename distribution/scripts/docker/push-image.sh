#!/bin/sh
# Copyright 2017 WSO2 Inc. (http://wso2.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# Script to push a docker image to the Amazon Elastic Container Registry
# ----------------------------------------------------------------------------

dockerfile_location=""
image_name=""
default_tag="latest"
tag_name=$default_tag

function usage() {
    echo ""
    echo "Usage: "
    echo "$0 [-d <docker_file_location>] [-r <Name for ecr repo>] [-i <Name for image>] [-t <Tag for image>] [-h]"
    echo ""
    echo "-d: The location of the dockerfile."
    echo "-i: Name for the image."
    echo "-t: Tag for the image. Default: $default_tag"
    echo ""
}

while getopts "d:i:t:h" opts; do
    case $opts in
    d)
        dockerfile_location=${OPTARG}
        ;;
    i)
        image_name=${OPTARG}
        ;;
    t)
        tag_name=${OPTARG}
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done

if [[ -z $dockerfile_location ]]; then
    echo "Please specify the location of the dockerfile."
    exit 1
fi

if [[ -z $image_name ]]; then
    echo "Please specify the name for the image."
    exit 1
fi

if [! -f "$dockerfile_location/dockerfile" ]; then
    echo "Dockerfile missing in directory."
    exit 1
fi

docker build -t $aws_ecr_link/$image_name:$tag_name $dockerfile_location

if ! command docker inspect --type=image $aws_ecr_link/$image_name:$tag_name
then
    echo "Docker image was not created properly"
    exit 1
fi

if command aws ecr get-login-password --region $aws_region | docker login --username AWS --password-stdin $aws_ecr_link
then
    echo "Logged into ecr succesfully"
else
    echo "Problem logging into ecr"
    exit 1
fi

if ! command aws ecr describe-repositories --repository-names $image_name
then	
    aws ecr create-repository \
        --repository-name $image_name \
        --image-scanning-configuration scanOnPush=true \
        --region $aws_region
fi

if command docker push $aws_ecr_link/$image_name:$tag_name
then
    echo "$image_name pushed to ECR succesfully"
else
    echo "Could not push $image_name to ECR"
    exit
fi







