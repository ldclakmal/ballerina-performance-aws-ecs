#!/bin/bash
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
# Installation script for setting up Java on Linux.
# This is a simplified version of the script in
# https://github.com/chrishantha/install-java
# ----------------------------------------------------------------------------

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

# Install Java
apt-get -y install openjdk-8-jdk

# Create system preferences directory
java_system_prefs_dir="/etc/.java/.systemPrefs"
extracted_dirname="/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre"
if [[ ! -d $java_system_prefs_dir ]]; then
    echo "Creating $java_system_prefs_dir and changing ownership to $user:$user"
    mkdir -p $java_system_prefs_dir
    chown -R $user:$user $java_system_prefs_dir
fi

user_bashrc_file=/home/$user/.bashrc

if [[ ! -f $user_bashrc_file ]]; then
    echo "Creating $user_bashrc_file"
    touch $user_bashrc_file
fi

if grep -q "export JAVA_HOME=.*" $user_bashrc_file; then
    sed -i "s|export JAVA_HOME=.*|export JAVA_HOME=$extracted_dirname|" $user_bashrc_file
else
    echo "export JAVA_HOME=$extracted_dirname" >>$user_bashrc_file
fi
source $user_bashrc_file

