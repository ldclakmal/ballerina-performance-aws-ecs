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

# Component versions (maven)
export version="0.1.0-SNAPSHOT"

# Download Links
export JMeter_download_link="https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.3.tgz"
export aws_cli_download_link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"

# AWS components
export aws_ecr_link="134633749276.dkr.ecr.us-east-2.amazonaws.com"
export aws_region="us-east-2"

# Directories
export home_directory="/home/ubuntu"
export bal_directory=="/home/ubuntu/bal-directory/bin"

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