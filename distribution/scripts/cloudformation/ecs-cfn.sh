#!/bin/bash -e
# Copyright 2020 WSO2 Inc. (http://wso2.org)
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

# ----------------------------------------------------------------------------
# Create a Cloudformation stack for ECS.
# ----------------------------------------------------------------------------

template_body_location="file://$SCRIPTS_DIR/cloudformation/templates/ecs.yaml"
test_name=""
health_check_protocol=""

function usage() {
    echo ""
    echo "Usage: "
    echo "$0 [-t <Name of the test>] [-i <Type of the health check protocol>] [-h]"
    echo ""
    echo "-t: Name of the test"
    echo "-i: Type of the health check protocol"
    echo ""
}

while getopts "t:i:h" opt; do
    case "${opt}" in
    t)
        test_name=${OPTARG}
        ;;
    i)
        health_check_protocol=${OPTARG}
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done

if [[ -z $test_name ]]; then
    echo "Please provide the name of the test to start ECS cluster."
    exit 1
fi
if [[ -z $health_check_protocol ]]; then
    echo "Please provide the type of the health check protocol for the test to start ECS cluster."
    exit 1
else
    echo "Starting ECS cluster for $test_name."
fi

aws cloudformation create-stack --stack-name ecs-stack --template-body $template_body_location --parameters \
ParameterKey=UserEmail,ParameterValue=$USER_EMAIL \
ParameterKey=PrivateSubnet,ParameterValue=$PRIVATE_SUBNET \
ParameterKey=NettyImage,ParameterValue=$AWS_ECR_URL/netty-echo-backend:latest \
ParameterKey=BallerinaTestImage,ParameterValue=$AWS_ECR_URL/$test_name:latest \
ParameterKey=SecurityGroup,ParameterValue=$SECURITY_GROUP \
ParameterKey=VPC,ParameterValue=$VPC \
ParameterKey=BallerinaMemory,ParameterValue=$BALLERINA_MEMORY \
ParameterKey=BallerinaCPU,ParameterValue=$BALLERINA_CPU \
ParameterKey=Protocol,ParameterValue=$health_check_protocol \
--capabilities CAPABILITY_IAM --tags Key=User,Value=$USER_EMAIL
