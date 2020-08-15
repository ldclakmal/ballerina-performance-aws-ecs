#!/bin/bash -e
# Copyright (c) 2020, WSO2 Inc. (http://wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# ----------------------------------------------------------------------------
# Installation script for setting up JMeter on Linux.
# ----------------------------------------------------------------------------

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

echo "Installing JMeter..."
jmeter_url="https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.3.tgz"
mkdir $JMETER_DIR
wget -O apache-jmeter.tgz $jmeter_url
bsdtar -C $JMETER_DIR -xvf apache-jmeter.tgz
export PATH="$JMETER_DIR/apache-jmeter-5.3/bin:$PATH"
echo "JMeter version:"
JVM_ARGS="-Xms512m -Xmx512m" jmeter -v
