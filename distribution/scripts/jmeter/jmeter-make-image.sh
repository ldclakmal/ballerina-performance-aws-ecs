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
# Create jmeter docker image
# ----------------------------------------------------------------------------
JMeter_directory="$script_directory/jmeter"
jtl_directory="$repo_directory/components/jtl-splitter/target"
payload_gen_directory="$repo_directory/components/payload-generator/target"

# Download JMeter and extract
wget -O apache-jmeter.tgz $JMeter_download_link
bsdtar -C $JMeter_directory -xvf apache-jmeter.tgz

cd $JMeter_directory

# Copy all required files
cp $jtl_directory/jtl-splitter-$version.jar .
cp $payload_gen_directory/payload-generator-$version.jar .
cp $script_directory/ballerina/test-config.sh .

touch Dockerfile

echo "FROM alpine:3.12.0" >> Dockerfile

echo "USER root" >> Dockerfile

echo "RUN apk add openjdk8=8.242.08-r2 && \\" >> Dockerfile

echo "apk add bash && \\" >> Dockerfile

echo "apk add jq && \\" >> Dockerfile

echo "apk add zip" >> Dockerfile

echo "ENV HOST_NAME \"\"" >> Dockerfile

echo "COPY . ." >> Dockerfile

echo "CMD ./run-tests.sh $JMeter_options -a \$HOST_NAME -v $version" >> Dockerfile

cd $home_directory

# Push image to ECR
chmod +x $script_directory/docker/push-image.sh
$script_directory/docker/push-image.sh -d $JMeter_directory -i jmeter_client