#!/bin/bash -e
# Copyright 2021 WSO2 Inc. (http://wso2.org)
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
# Start the ballerina performance test
# ----------------------------------------------------------------------------
# Create the EC2 instance 

# User inputs

aws cloudformation create-stack --stack-name ec2-stack \
--template-body file:///home/shamith/Documents/Final/ballerina-performance-aws-ecs/distribution/scripts/cloudformation/templates/ec2.yaml \
--parameters \
ParameterKey=KeyName,ParameterValue=ballerina-performance-ecs \
ParameterKey=InstanceType,ParameterValue=c5.xlarge \
ParameterKey=BallerinaMemory,ParameterValue=8192 \
ParameterKey=BallerinaCPU,ParameterValue=4096 \
ParameterKey=GitHubRepoBranch,ParameterValue=infrastructure-env-creation \
ParameterKey=GitUsername,ParameterValue= \
ParameterKey=GitPassword,ParameterValue= \
ParameterKey=JMeterOptions,ParameterValue="-m 2G -u 100 -b 50 -b 100" \
ParameterKey=UserEmail,ParameterValue=shamith@wso2.com \
ParameterKey=BallerinaVersion,ParameterValue=swan-lake-alpha3 \
--capabilities CAPABILITY_IAM --tags Key=User,Value=shamith@wso2.com

# Wait until EC2 stack creation
aws cloudformation wait stack-create-complete --stack-name ec2-stack

# Connect to the EC2 instance
chmod 400 ballerina-performance-ecs.pem
ec2_public_dns=$(aws ec2 describe-instances --query 'Reservations[*].Instances[].PublicDnsName |[-1]' --output text)
echo "tail -f /var/log/cloud-init-output.log" | ssh -i "ballerina-performance-ecs.pem" $ec2_public_dns -l ubuntu
