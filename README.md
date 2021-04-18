# Ballerina Performance Tests on Amazon ECS

Ballerina performance artifacts are used to continuously test the performance of Ballerina language versions.

These performance test scripts make use of Apache JMeter and a simple Netty Backend Service, which can echo back any 
requests and also add a configurable delay to the response.

In order to support a large number of concurrent users, two or more JMeter Servers can be used.

Use AWS Cloudformation, AWS EC2 (Amazon Elastic Compute Cloud) which acts as a local machine and AWS ECS (Amazon Elastic Container Service) for Netty echo server and Ballerina service.

To fully automate the performance tests on amazon ECS, an AWS CloudFormation template is used to create a deployment of an EC2 
instance and an ECS cluster compromising a Ballerina and a Netty Backend Service.

## Run Ballerina Performance Tests on Amazon ECS

You can run Ballerina Performance Tests from the source using the following instructions.

### Prerequisites

* [AWS CLI](https://aws.amazon.com/cli/) - Please make sure to [configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
and set the output format to `text`.
* File of an existing EC2 KeyPair to enable SSH access to the instance.

#### Steps to run performance tests.

1. Clone this repository using the following command.

```
git clone https://github.com/ldclakmal/ballerina-performance-aws-ecs.git
```

2. Change directory to `/../ballerina-performance-aws-ecs/distribution/scripts/cloudformation` and copy the key pair file to that directory.

3. Run the following command to make ec2-cfn.sh executable.

```
chmod +x ec2-cfn.sh
```

4. In the current directory ( `/../ballerina-performance-aws-ecs/distribution/scripts/cloudformation` ) use following command to run tests. Make sure to change the values of the parameters according to your preferences.

```
./ec2-cfn.sh -c /home/shamith/Documents/Upgrade/ec2.yaml -f key-pair-name -g c5.xlarge -j 8192 -n 4096 -p test-branch -r "-m 2G -u 50 -b 50" -s user@example.com -k swan-lake-alpha4 -y user@example.com -x SmithAbey -v #####
```
Usage of above command: 

```
-c: Location of the ec2 cloudformation template.
-f: Name of an existing EC2 KeyPair to enable SSH access to the instance.
-g: WebServer EC2 instance type.
-j: Memory Constraint for the test.
-n: CPU Constraint for the test.
-p: Branch of the github repo of the ballerina performance tests.
-x: Username of GitHub account.
-v: Password of GitHub account.
-r: Options for JMeter. You should give the jmeter options in the inverted comma.
-s: Email address of the user creating this stack.
-k: Version for the Ballerina deb file.
-y: Value of the IAM user.
-h: Display this help and exit.
```

5. You can change values of the JMeterOptions Parameter as below examples. You should provide Jmeter options values in the inverted commas.

To do the test for two message sizes.
```
-r "-m 2G -u 100 -b 50 -b 100"
```
To do the test for two message sizes and two concurrent users.
```
-r "-m 2G -u 100 -u 150 -b 50 -b 100"
```

Usage of JMeterOptions: 

```
-u: Concurrent Users to test. Multiple users must be separated by spaces. Default "50 100 150 500 1000".
-b: Message sizes in bytes. Multiple message sizes must be separated by spaces. Default "50 1024 10240".
-m: Application heap memory sizes. Multiple heap memory sizes must be separated by spaces. Default "2g".
-d: Test Duration in seconds. Default 900.
-w: Warm-up time in minutes. Default 5.
-j: Heap Size of JMeter Server. Default 4g.
-k: Heap Size of JMeter Client. Default 2g.
-l: Heap Size of Netty Service. Default 4g.
-i: Scenario name to to be included. You can give multiple options to filter scenarios.
-e: Scenario name to to be excluded. You can give multiple options to filter scenarios.
-t: Estimate time without executing tests.
-p: Estimated processing time in between tests in seconds. Default 60.
-h: Display this help and exit.
```

6. After completing the test, end of the terminal gives output as below.

```
Finished the ballerina performane aws ecs test
EC2 instance is deleting...
Completed the ballerina performane aws ecs test

```

7. Check whether the cloudformation stacks are deleted completely. By using following aws cli command you can figure it out all stacks are deleted or not.

```
aws cloudformation describe-stacks
```

## Notes

- Before changing the BallerinaMemory and BallerinaCPU values refer [this](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)

## Implementation

- Run task in the cluster for particular test scenario without creating whole cluster from the bottom level.

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. To start contributing, read these [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md) for information on how you should go about contributing to our project.

Check the issue tracker for open issues that interest you. We look forward to receiving your contributions.

## License

Ballerina code is distributed under [Apache license 2.0](https://github.com/ballerina-platform/ballerina-lang/blob/master/LICENSE).

## Useful links

* The ballerina-dev@googlegroups.com mailing list is for discussing code changes to the Ballerina project.
* Chat live with us on our [Slack channel](https://ballerina-platform.slack.com/).
* Technical questions should be posted on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.