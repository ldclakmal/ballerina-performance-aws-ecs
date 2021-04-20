#!/bin/bash -e
# Copyright 2017 WSO2 Inc. (http://wso2.org)
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
# Create Netty backend Docker image and push to ECR.
# ----------------------------------------------------------------------------

netty_service_name="netty-http-echo-service"
netty_image_name="netty-echo-backend"
netty_flags="$@"

echo "$netty_flags"
mkdir -p $NETTY_DOCKER_DIR
cd $NETTY_DOCKER_DIR

cp $GITHUB_REPO_DIR/components/netty-http-echo-service/target/$netty_service_name-$COMPONENTS_VERSION.jar .
cp $SCRIPTS_DIR/netty/start-netty.sh .
cp $SCRIPTS_DIR/ballerina/resources/ballerinaKeystore.p12 .

touch Dockerfile

echo "FROM alpine:3.12.0" >> Dockerfile
echo "USER root" >> Dockerfile
echo "RUN apk add openjdk8=8.275.01-r0" >> Dockerfile
echo "COPY $netty_service_name-$COMPONENTS_VERSION.jar ." >> Dockerfile
echo "COPY start-netty.sh ." >> Dockerfile
echo "COPY ballerinaKeystore.p12 ." >> Dockerfile
echo "ENTRYPOINT ./start-netty.sh -j $netty_service_name-$COMPONENTS_VERSION.jar $netty_flags" >> Dockerfile

cd $HOME_DIR

# Push image to ECR
$SCRIPTS_DIR/docker/push-docker-image.sh -d $NETTY_DOCKER_DIR -i $netty_image_name
