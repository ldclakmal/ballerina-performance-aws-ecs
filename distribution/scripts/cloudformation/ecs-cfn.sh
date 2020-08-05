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
#
# ----------------------------------------------------------------------------
# Create a cloudformation stack for ECS
# ----------------------------------------------------------------------------

template_body_location="file://$script_directory/cloudformation/templates/ecs_cfn.yaml"

aws cloudformation create-stack --stack-name ecs-stack --template-body $template_body_location --parameters \
ParameterKey=UserEmail,ParameterValue=$user_email \
ParameterKey=PrivateSubnet,ParameterValue=$private_subnet \
ParameterKey=NettyImage,ParameterValue=$aws_ecr_link/netty-backend:latest \
ParameterKey=TestImage,ParameterValue=$aws_ecr_link/h1c_h1c_passthrough:latest \
ParameterKey=SecurityGroup,ParameterValue=$security_group \
ParameterKey=VPC,ParameterValue=$vpc_id \
ParameterKey=BallerinaMemory,ParameterValue=$ballerina_memory \
ParameterKey=BallerinaCPU,ParameterValue=$ballerina_cpu \
--capabilities CAPABILITY_IAM
