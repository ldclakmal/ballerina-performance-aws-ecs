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
export DOWNLOADS_DIR="$HOME_DIR/downloads"
export BALLERINA_DIR="$HOME_DIR/ballerina"
export JMETER_DIR="$HOME_DIR/jmeter"
export NETTY_DOCKER_DIR="$HOME_DIR/docker-images/netty"
export BALLERINA_DOCKER_DIR="$HOME_DIR/docker-images/ballerina"
export JMETER_DOCKER_DIR="$HOME_DIR/docker-images/jmeter"

export AWS_ECR_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

mkdir $DOWNLOADS_DIR
cd $HOME_DIR

# Install required tools and packages
source $SCRIPTS_DIR/setup/install-tools.sh
source $SCRIPTS_DIR/docker/install-docker.sh
source $SCRIPTS_DIR/java/install-java.sh
source $SCRIPTS_DIR/ballerina/install-ballerina.sh
source $SCRIPTS_DIR/jmeter/install-jmeter.sh

# Build components package
$SCRIPTS_DIR/setup/build-components.sh

# Run Jmeter test
chmod +x $SCRIPTS_DIR/jmeter/start-jmeter-test.sh
source $SCRIPTS_DIR/jmeter/start-jmeter-test.sh $JMETER_OPTIONS

# Create csv file
cd $GITHUB_REPO_DIR/testresults
sudo chmod +x create-summary-csv.sh
sudo ./create-summary-csv.sh -n Passthrough HTTP service -x

# Create markdown file
echo "y" | apt-get install python3.8
echo "y" | apt-get install -y python3-humanize
sudo python3 create-summary-markdown.py --column-names "Scenario Name" "Heap Size" "Concurrent Users" "Message Size (Bytes)" "Back-end Service Delay (ms)" "Label" "# Samples" "Error Count" "Error %" "Throughput (Requests/sec)" "Average Response Time (ms)" "Average Users in the System" "Standard Deviation of Response Time (ms)" "Minimum Response Time (ms)" "75th Percentile of Response Time (ms)" "90th Percentile of Response Time (ms)" "95th Percentile of Response Time (ms)" "98th Percentile of Response Time (ms)" "99th Percentile of Response Time (ms)" "99.9th Percentile of Response Time (ms)" "Received (KB/sec)" "Sent (KB/sec)" --json-parameters parameters=/home/ubuntu/results/test-metadata.json

# Push results to the git repo
git add summary.md
git add summary.csv
git commit -m "Update performance results"
git push https://$GIT_USERNAME:$GIT_PASSWORD@github.com/ballerina-platform/ballerina-performance-aws-ecs.git --all

echo "Finished the Ballerina performance AWS ECS tests."
