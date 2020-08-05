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
# Create JMeter Docker image and push to ECR.
# ----------------------------------------------------------------------------

cd $JMETER_DIR

# Copy all required files
cp $GITHUB_REPO_DIR/components/jtl-splitter/target/jtl-splitter-$COMPONENTS_VERSION.jar .
cp $GITHUB_REPO_DIR/components/payload-generator/target/payload-generator-$COMPONENTS_VERSION.jar .
cp $SCRIPTS_DIR/ballerina/ballerina-test-config.sh .
cp $SCRIPTS_DIR/jmeter/start-jmeter-test.sh .
cp $SCRIPTS_DIR/jmeter/jtl-splitter.sh .
cp $SCRIPTS_DIR/jmeter/generate-payload.sh .
cp $SCRIPTS_DIR/jmeter/http-post-request.jmx .
cp $SCRIPTS_DIR/jmeter/jmeter-test-util.sh .

touch Dockerfile

echo "FROM alpine:3.12.0" >> Dockerfile
echo "USER root" >> Dockerfile
echo "RUN apk add openjdk8=8.252.09-r0 && \\" >> Dockerfile
echo "apk add bash && \\" >> Dockerfile
echo "apk add jq && \\" >> Dockerfile
echo "apk add zip" >> Dockerfile
echo "ENV HOST_NAME \"\"" >> Dockerfile
echo "COPY . ." >> Dockerfile
echo "CMD ./start-jmeter-test.sh $JMETER_OPTIONS -a \$HOST_NAME -v $COMPONENTS_VERSION" >> Dockerfile

cd $HOME_DIR

# Push image to ECR
$SCRIPTS_DIR/docker/push-docker-image.sh -d $JMETER_DIR -i jmeter-client
