#!/bin/bash
# Copyright 2021 WSO2 Inc. (http://wso2.org)
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
# Start the Ballerina performance tests by creating ECS instance.
# ----------------------------------------------------------------------------

# User inputs
template_location=""
key_pair_name="ballerina-performance-ecs-new"
instance_type="c5.xlarge"
ballerina_memory="8192"
ballerina_cpu="4096"
github_repo_branch="master"
jmeter_options=""
user_email=""
ballerina_version="swan-lake-alpha4"
user_value=""
git_username=""
git_password=""

function usage() {
    echo ""
    echo "Usage: "
    echo "-c: Location of the ec2 cloudformation template "
    echo "-f: Name of an existing EC2 KeyPair to enable SSH access to the instance."
    echo "-g: WebServer EC2 instance type."
    echo "-j: Memory Constraint for the test."
    echo "-n: CPU Constraint for the test."
    echo "-p: Branch of the GitHub repo of the Ballerina performance tests."
    echo "-x: Username of GitHub account"
    echo "-v: Password of GitHub account"
    echo "-r: Options for JMeter. You should give the jmeter options in the inverted comma"
    echo "-s: Email address of the user creating this stack."
    echo "-k: Version for the Ballerina deb file."
    echo "-y: Value of the IAM user."
    echo "-h: Display this help and exit."
    echo ""
}

while getopts "c:f:g:j:n:p:x:v:r:s:k:y:h" opts; do
    case $opts in
    c)
        template_location=${OPTARG}
        ;;
    f)
        key_pair_name=${OPTARG}
        ;;
    g)
        instance_type=${OPTARG}
        ;;
    j)
        ballerina_memory=${OPTARG}
        ;;
    n)
        ballerina_cpu=${OPTARG}
        ;;
    p)
        github_repo_branch=${OPTARG}
        ;;
    x)
        git_username=${OPTARG}
        ;;
    v)
        git_password=${OPTARG}
        ;;
    r)
        jmeter_options=${OPTARG}
        ;;
    s)
        user_email=${OPTARG}
        ;;
    k)
        ballerina_version=${OPTARG}
        ;;
    y)
        user_value=${OPTARG}
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

if [[ -z $template_location ]]; then
    echo "Please specify the location of the ec2 cloudformation template."
    exit 1
fi

if [[ -z $key_pair_name ]]; then
    echo "Please specify the name of the key pair."
    exit 1
fi

if [[ -z $instance_type ]]; then
    echo "Please specify the type of the ec2 instance."
    exit 1
fi

if [[ -z $ballerina_memory ]]; then
    echo "Please specify the memory Constraint for the test. "
    exit 1
fi

if [[ -z $ballerina_cpu ]]; then
    echo "Please specify the CPU Constraint for the test."
    exit 1
fi

if [[ -z $github_repo_branch ]]; then
    echo "Please specify the branch of the GitHub repo."
    exit 1
fi

if [[ -z $git_username ]]; then
    echo "Please provide the username of the GitHub account."
    exit 1
fi

if [[ -z $git_password ]]; then
    echo "Please provide the password of the GitHub account."
    exit 1
fi

if [[ -z $jmeter_options ]]; then
    echo "Please specify the Jmeter options."
    exit 1
fi

if [[ -z $user_email ]]; then
    echo "Please specify the user email."
    exit 1
fi

if [[ -z $ballerina_version ]]; then
    echo "Please specify the Ballerina version."
    exit 1
fi

if [[ -z $user_value ]]; then
    echo "Please specify the tag value of the IAM user."
    exit 1
fi

# Find the latest ubuntu AMI ID
ec2_ami_id=$(aws ec2 describe-images  --filters Name=name,Values=ubuntu/images/hvm-ssd/ubuntu*-amd64*  --query 'Images[*].[ImageId,CreationDate]' --output text  | sort -k2 -r  | head -n1 | cut -f 1)
ec2_ami_id=ami-042e8287309f5df03

echo "aws cloudformation create-stack --stack-name ec2-stack \
--template-body file://$template_location \
--parameters \
ParameterKey=KeyName,ParameterValue=$key_pair_name \
ParameterKey=InstanceType,ParameterValue=$instance_type \
ParameterKey=BallerinaMemory,ParameterValue=$ballerina_memory \
ParameterKey=BallerinaCPU,ParameterValue=$ballerina_cpu \
ParameterKey=GitHubRepoBranch,ParameterValue=$github_repo_branch \
ParameterKey=GitUsername,ParameterValue=$git_username \
ParameterKey=GitPassword,ParameterValue=##### \
ParameterKey=JMeterOptions,ParameterValue="$jmeter_options" \
ParameterKey=UserEmail,ParameterValue=$user_email \
ParameterKey=LatestAmiId,ParameterValue=$ec2_ami_id \
ParameterKey=BallerinaVersion,ParameterValue=$ballerina_version \
--capabilities CAPABILITY_IAM --tags Key=User,Value=$user_value"

echo "Creating EC2 instance..."

aws cloudformation create-stack --stack-name ec2-stack \
--template-body file://$template_location \
--parameters \
ParameterKey=KeyName,ParameterValue=$key_pair_name \
ParameterKey=InstanceType,ParameterValue=$instance_type \
ParameterKey=BallerinaMemory,ParameterValue=$ballerina_memory \
ParameterKey=BallerinaCPU,ParameterValue=$ballerina_cpu \
ParameterKey=GitHubRepoBranch,ParameterValue=$github_repo_branch \
ParameterKey=GitUsername,ParameterValue=$git_username \
ParameterKey=GitPassword,ParameterValue=$git_password \
ParameterKey=JMeterOptions,ParameterValue="$jmeter_options" \
ParameterKey=UserEmail,ParameterValue=$user_email \
ParameterKey=LatestAmiId,ParameterValue=$ec2_ami_id \
ParameterKey=BallerinaVersion,ParameterValue=$ballerina_version \
--capabilities CAPABILITY_IAM --tags Key=User,Value=$user_value

# Wait until EC2 instance created
aws cloudformation wait stack-create-complete --stack-name ec2-stack

# Connect to the EC2 instance
chmod 400 $key_pair_name.pem
ec2_public_dns=$(aws ec2 describe-instances --query 'Reservations[*].Instances[].PublicDnsName |[-1]' --output text)
ssh-keyscan -H $ec2_public_dns >> ~/.ssh/known_hosts
echo "tail -f /var/log/cloud-init-output.log | sed '/^Finished the Ballerina performance AWS ECS tests$/ q'" | ssh -i "$key_pair_name.pem" $ec2_public_dns -l ubuntu

# Delete ec2-stack and end the test
echo "Deleting EC2 instance..."
aws cloudformation delete-stack --stack-name ec2-stack

# Wait until ec2-stack deleted
aws cloudformation wait stack-delete-complete --stack-name ec2-stack

echo -e "\eCompleted the Ballerina performance AWS ECS tests."
