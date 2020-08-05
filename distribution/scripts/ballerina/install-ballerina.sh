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
# Installation script for setting up Ballerina on Linux.
# ----------------------------------------------------------------------------

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

echo "Installing Ballerina..."
mkdir $BALLERINA_DIR
wget -O ballerina-distribution.zip $BALLERINA_ZIP_URL
bsdtar --strip-components=1 -C $BALLERINA_DIR -xvf ballerina-distribution.zip
export PATH="$BALLERINA_DIR/bin:$PATH"
echo "Ballerina version:"
ballerina -v
