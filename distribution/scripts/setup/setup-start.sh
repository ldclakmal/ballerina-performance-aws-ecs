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
# Setting up the EC2 Linux machine
# ----------------------------------------------------------------------------

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

export repo_directory="/home/ubuntu/ballerina-performance-aws-ecs"
export script_directory="$repo_directory/distribution/scripts"
export bal_directory=="/home/ubuntu/bal-directory/bin"
export aws_ecr_link="134633749276.dkr.ecr.us-east-2.amazonaws.com"
export aws_region="us-east-2"
export home_directory="/home/ubuntu"

# Start by cloning the performance test repository
git clone https://daksithj:85351a39913458d12edb15f8f9ad0ed576d8251e@github.com/ldclakmal/ballerina-performance-aws-ecs.git $repo_directory
if [ ! -d $repo_directory ]; then
  echo "Could not pull the ecs performance test repository."
  exit 1
fi
if [ ! -d $script_directory ]; then
  echo "Script directory not available"
  exit 1
fi

# Install docker
chmod +x $script_directory/docker/install-docker.sh
source $script_directory/docker/install-docker.sh

# Install Java
chmod +x $script_directory/java/install-java.sh
source $script_directory/java/install-java.sh

# Install Ballerina
chmod +x $script_directory/ballerina/install-ballerina.sh
source $script_directory/ballerina/install-ballerina.sh

# Insall the AWS CLI
chmod +x $script_directory/setup/install-awscli.sh
source $script_directory/setup/install-awscli.sh

# Run h1c_h1c_passthrough test
chmod +x $script_directory/ballerina/bal-make-image.sh
source $script_directory/ballerina/bal-make-image.sh -t h1c_h1c_passthrough

