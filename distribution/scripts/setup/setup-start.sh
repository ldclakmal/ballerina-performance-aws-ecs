#!/bin/bash -e

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

export repo_directory="/home/ubuntu/ballerina-performance-aws-ecs"
export script_directory="$repo_directory/distribution/scripts"
export bal_directory=""

# Start by cloning the performance test repository
git clone https://daksithj:85351a39913458d12edb15f8f9ad0ed576d8251e@github.com/ldclakmal/ballerina-performance-aws-ecs.git $repo_directory
if [ ! -d $repo_directory ]; then
  echo "Could not pull the ecs performance test repository."
  exit 1
fi
if [ ! -d $script_directory ]; then
  echo "Script directory not available"
  exit 1
fi

# Install docker
chmod +x $script_directory/docker/install-docker.sh
$script_directory/docker/install-docker.sh


# Install Java
chmod +x $script_directory/java/install-java.sh
$script_directory/java/install-java.sh

# Install Ballerina
chmod +x $script_directory/ballerina/install-ballerina.sh
$script_directory/ballerina/install-ballerina.sh
$bal_directory="/home/ubuntu/bal-directory/bin"
