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
#
# ----------------------------------------------------------------------------
# Create netty backend docker image
# ----------------------------------------------------------------------------
jar_directory="$repo_directory/components/netty-http-echo-service/target"
netty_directory="$script_directory/netty"
netty_service_name="netty-http-echo-service"
netty_image_name="netty-backend"

cd $netty_directory

touch Dockerfile

echo "FROM alpine:3.12.0" >> Dockerfile

echo "USER root" >> Dockerfile

echo "RUN apk add openjdk8=8.242.08-r2" >> Dockerfile

cp $jar_directory/$netty_service_name-$version.jar .

echo "COPY $netty_service_name-$version.jar ." >> Dockerfile

echo "COPY start-netty.sh ." >> Dockerfile

echo "ENTRYPOINT ./start-netty.sh -j $netty_service_name-$version.jar" >> Dockerfile

cd $home_directory

# Push image to ECR
chmod +x $script_directory/docker/push-image.sh
$script_directory/docker/push-image.sh -d $netty_directory -i $netty_image_name






