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
# Create Ballerina test Docker image and push to ECR.
# ----------------------------------------------------------------------------

test_name=""

function usage() {
    echo ""
    echo "Usage: "
    echo "$0 [-t <Name of the test>] [-h]"
    echo ""
    echo "-t: Name of the test"
    echo ""
}

while getopts "t:h" opt; do
    case "${opt}" in
    t)
        test_name=${OPTARG}
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done

if [[ -z $test_name ]]; then
    echo "Please provide the name of the test to start building image."
    exit 1
else
    echo "Starting to build $test_name."
fi

mkdir -p $BALLERINA_DOCKER_DIR
cd $BALLERINA_DOCKER_DIR

cp $SCRIPTS_DIR/ballerina/start-ballerina-test.sh .
cp $SCRIPTS_DIR/ballerina/tests/$test_name/* .
cp $SCRIPTS_DIR/ballerina/resources/ballerinaKeystore.p12 .
cp $SCRIPTS_DIR/ballerina/resources/ballerinaTruststore.p12 .
rm -rf ~/.ballerina
bal build --offline $test_name.bal

touch Dockerfile

echo "FROM alpine:3.12.0" >> Dockerfile
echo "USER root" >> Dockerfile
echo "RUN apk add openjdk11=11.0.9_p11-r0" >> Dockerfile
echo "ENV NETTY_HOST \"\"" >> Dockerfile
echo "COPY $test_name.jar ." >> Dockerfile
echo "COPY start-ballerina-test.sh ." >> Dockerfile
echo "COPY ballerinaKeystore.p12 ." >> Dockerfile
echo "COPY ballerinaTruststore.p12 ." >> Dockerfile
echo "ENTRYPOINT ./start-ballerina-test.sh -n \$NETTY_HOST -t $test_name" >> Dockerfile

cd $HOME_DIR

# Push image to ECR
$SCRIPTS_DIR/docker/push-docker-image.sh -d $BALLERINA_DOCKER_DIR -i $test_name
