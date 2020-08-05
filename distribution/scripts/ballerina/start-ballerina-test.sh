#!/bin/sh
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
# Start Ballerina test inside Docker image.
# ----------------------------------------------------------------------------

netty_host=""
test_name=""

function usage() {
    echo ""
    echo "Usage: "
    echo "$0 [-n <Address of netty host>] [-t <Name of the test>] [-h]"
    echo ""
    echo "-n: Address of the netty backend"
    echo "-t: Name of the test"
    echo "-h: Display this help and exit."
    echo ""
}

while getopts "t:n:h" opt; do
    case "${opt}" in
    t)
        test_name=${OPTARG}
        ;;
    n)
        netty_host=${OPTARG}
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

if [[ -z $netty_host ]]; then
    echo "Please provide the hostname of Netty Service."
    exit 1
fi

if [[ -z $test_name ]]; then
    echo "Please provide the name of the test."
    exit 1
fi

java -jar $test_name.jar --b7a.netty=$netty_host
