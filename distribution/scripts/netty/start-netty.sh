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
# Start netty server inside docker image
# ----------------------------------------------------------------------------

jar_name=""
default_heap_size="4g"
heap_size="$default_heap_size"
enable_ssl="false"

function usage() {
    echo ""
    echo "Usage: "
    echo "$0 [-m <heap_size>] [-h] -- [netty_service_flags]"
    echo ""
    echo "-m: The heap memory size of Netty Service. Default: $default_heap_size"
    echo "-j: Name of the netty jar."
    echo "-h: Display this help and exit."
    echo ""
}

while getopts "m:j:s:h" opts; do
    case $opts in
    m)
        heap_size=${OPTARG}
        ;;
    j)
        jar_name=${OPTARG}
        ;;
    s)
        enable_ssl=${OPTARG}
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done

if [[ -z $heap_size ]]; then
    echo "Please specify the heap size."
    exit 1
fi

if [[ -z $jar_name ]]; then
    echo "Please specify the name of the netty jar"
    exit 1
fi

gc_log_file=./logs/nettygc.log

if [[ -f $gc_log_file ]]; then
    echo "GC Log exists. Moving $gc_log_file to /tmp"
    mv $gc_log_file /tmp/
fi

mkdir -p logs

echo "Starting Netty"
if [ $enable_ssl = true ]; then
    nohup java -Xms${heap_size} -Xmx${heap_size} -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$gc_log_file \
    -jar $jar_name --ssl $enable_ssl --key-store-file /usr/lib/ballerina/distributions/ballerina-slp7/bre/security/ballerinaKeystore.p12 --key-store-password ballerina >netty.out 2>&1
else
    nohup java -Xms${heap_size} -Xmx${heap_size} -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$gc_log_file \
    -jar $jar_name >netty.out 2>&1
fi
