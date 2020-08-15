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
# Setting up the Linux EC2 instance.
# ----------------------------------------------------------------------------

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

# Components version (Maven)
export COMPONENTS_VERSION="0.1.0-SNAPSHOT"

# Directories
export HOME_DIR="/home/ubuntu"
export BALLERINA_DIR="/home/ubuntu/ballerina"
export JMETER_DIR="/home/ubuntu/jmeter"

# Install required tools and packages
source $SCRIPTS_DIR/setup/install-tools.sh
source $SCRIPTS_DIR/docker/install-docker.sh
source $SCRIPTS_DIR/java/install-java.sh
source $SCRIPTS_DIR/ballerina/install-ballerina.sh
source $SCRIPTS_DIR/jmeter/install-jmeter.sh

# Build components package
$SCRIPTS_DIR/setup/build-components.sh

ballerina_test_scenario="h1c-h1c-passthrough"

# Create Docker images and push to ECR
$SCRIPTS_DIR/netty/make-netty-image.sh
$SCRIPTS_DIR/ballerina/make-ballerina-image.sh -t $ballerina_test_scenario
$SCRIPTS_DIR/jmeter/make-jmeter-image.sh

# Create ECS cluster
$SCRIPTS_DIR/cloudformation/ecs-cfn.sh -t $ballerina_test_scenario
