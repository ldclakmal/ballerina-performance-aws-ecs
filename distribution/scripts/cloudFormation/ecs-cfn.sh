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

template_body_location="file://$script_directory/cloudFormation/templates/ecs_cfn.yaml"

aws cloudformation create-stack --stack-name ecs-stack --template-body $template_body_location --parameters \
ParameterKey=UserEmail,ParameterValue=daksith@wso2.com \
ParameterKey=PrivateSubnet,ParameterValue=subnet-09c7fc5a5ffe5dec3 \
ParameterKey=PublicSubnet,ParameterValue=subnet-08b639feb926b17d1 \
ParameterKey=NettyImage,ParameterValue=134633749276.dkr.ecr.us-east-2.amazonaws.com/netty-backend:latest \
ParameterKey=TestImage,ParameterValue=134633749276.dkr.ecr.us-east-2.amazonaws.com/h1c_h1c_passthrough:latest \
ParameterKey=SecurityGroup,ParameterValue=sg-039f7aaaa9d23b73f \
ParameterKey=VPC,ParameterValue=vpc-0aa8a1b7aac565211 \
ParameterKey=BalMemory,ParameterValue=2048 \
ParameterKey=BalCPU,ParameterValue=1024 \
--capabilities CAPABILITY_IAM
