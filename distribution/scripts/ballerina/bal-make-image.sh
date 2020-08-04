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
# Create ballerina docker image
# ----------------------------------------------------------------------------
bal_script_directory="$script_directory/ballerina"
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
    echo "Please provide the name of the test $test_name to start building image."
else
    echo "Starting to build $test_name."
fi

test_directory="$bal_script_directory/tests/$test_name"

cd $test_directory

ballerina build $test_name.bal

touch Dockerfile

echo "FROM alpine:3.12.0" >> Dockerfile

echo "USER root" >> Dockerfile

echo "RUN apk add openjdk8=8.242.08-r2" >> Dockerfile

echo "ENV NETTY_HOST \"\"" >> Dockerfile

echo "COPY $test_name.jar ." >> Dockerfile

cp $bal_script_directory/start-test.sh .

echo "COPY start-test.sh ." >> Dockerfile

echo "ENTRYPOINT ./start-test.sh -n \$NETTY_HOST -t $test_name" >> Dockerfile

cd $home_directory

# Push image to ECR
chmod +x $script_directory/docker/push-image.sh
$script_directory/docker/push-image.sh -d $test_directory -i $test_name
