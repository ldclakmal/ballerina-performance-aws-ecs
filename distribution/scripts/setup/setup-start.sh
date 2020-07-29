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

# Git repo link
git_repo="https://daksithj:85351a39913458d12edb15f8f9ad0ed576d8251e@github.com/ldclakmal/ballerina-performance-aws-ecs.git"

# Component versions (maven)
export version="0.1.0-SNAPSHOT"

# Download Links
export bal_download_link="https://dist.ballerina.io/downloads/swan-lake-preview2/ballerina-swan-lake-preview2.zip"
export JMeter_download_link="https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.3.tgz"
export aws_cli_download_link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

# AWS components
export aws_ecr_link="134633749276.dkr.ecr.us-east-2.amazonaws.com"
export aws_region="us-east-2"

# Directories
export home_directory="/home/ubuntu"
export repo_directory="/home/ubuntu/ballerina-performance-aws-ecs"
export script_directory="$repo_directory/distribution/scripts"
export bal_directory=="/home/ubuntu/bal-directory/bin"

# Options for the JMeter client
    # -m: Application heap memory sizes. You can give multiple options to specify multiple heap memory sizes. Allowed suffixes: M, G.
    # -u: Concurrent Users to test. You can give multiple options to specify multiple users.
    # -b: Message sizes in bytes. You can give multiple options to specify multiple message sizes.
    # -d: Test Duration in seconds. Default 900s.
    # -w: Warm-up time in seconds. Default 300s.
    # -k: Heap Size of JMeter Client. Allowed suffixes: M, G. Default 2G.
    # -l: Heap Size of Netty Service. Allowed suffixes: M, G. 4G.
    # -i: Scenario name to to be included. You can give multiple options to filter scenarios.
    # -e: Scenario name to to be excluded. You can give multiple options to filter scenarios.
    # -t: Estimate time without executing tests.
    # -p: Estimated processing time in between tests in seconds. Default $default_estimated_processing_time_in_between_tests.
    # -h: Display this help and exit.
export JMeter_options="-u 50 -u 100 -b 50 -b 1024 -m 2G -d 30 -w 10"

# Start by cloning the performance test repository
git clone $git_repo $repo_directory
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
$script_directory/docker/install-docker.sh

# Install Java
chmod +x $script_directory/java/install-java.sh
$script_directory/java/install-java.sh
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre

# Install Ballerina
chmod +x $script_directory/ballerina/install-ballerina.sh
$script_directory/ballerina/install-ballerina.sh
export PATH="/home/ubuntu/bal-directory/bin:$PATH"

# Insall the AWS CLI
chmod +x $script_directory/setup/install-awscli.sh
$script_directory/setup/install-awscli.sh

# Install maven and build project
chmod +x $script_directory/setup/build-components.sh
$script_directory/setup/build-components.sh

# Create netty backend image and push to ECR
chmod +x $script_directory/netty/netty-make-image.sh
$script_directory/netty/netty-make-image.sh

# Create h1c_h1c_passthrough test
chmod +x $script_directory/ballerina/bal-make-image.sh
$script_directory/ballerina/bal-make-image.sh -t h1c_h1c_passthrough

# Create JMeter client
chmod +x $script_directory/jmeter/jmeter-make-image.sh
$script_directory/jmeter/jmeter-make-image.sh