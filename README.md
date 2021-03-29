# Ballerina Performance Tests on Amazon ECS

Ballerina performance artifacts are used to continuously test the performance of Ballerina services.

These performance test scripts make use of Apache JMeter and a simple Netty Backend Service, which can echo back any 
requests and also add a configurable delay to the response.

In order to support a large number of concurrent users, two or more JMeter Servers can be used.

Using Amazon Cloudformation, an EC2(Amazon Elastic Compute Cloud) stack which acts as a local machine and an ECS (Amazon Elastic Container Service) stack compromising of a Netty server and Ballerina service are created.

To fully automate the performance tests on amazon ECS, an AWS CloudFormation template is used to create a deployment of an EC2 
instance and an ECS cluster compromising a Ballerina and a Netty Backend Service.

## About Ballerina

Ballerina makes it easy to write microservices that integrate APIs.

#### Integration Syntax
A compiled, transactional, statically and strongly typed programming language with textual and graphical syntaxes. Ballerina incorporates fundamental concepts of distributed system integration and offers a type safe, concurrent environment to implement microservices.

#### Networked Type System
A type system that embraces network payload variability with primitive, object, union, and tuple types.

#### Concurrency
An execution model composed of lightweight parallel worker units that are non-blocking where no function can lock an executing thread manifesting sequence concurrency.

## Run Ballerina Performance Tests on Amazon ECS

You can run Ballerina Performance Tests from the source using the following instructions.

### Prerequisites

* [AWS CLI](https://aws.amazon.com/cli/) - Please make sure to [configure the AWS Cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
and set the output format to `text`.
* ballerina-performance-ecs.pem key file.

#### Steps to run performance tests.

1. Clone this repository using the following command.

```
git clone https://github.com/ldclakmal/ballerina-performance-aws-ecs.git
```

2. Change directory to `/../ballerina-performance-aws-ecs/distribution/scripts/cloudformation` and copy the ballerina-performance-ecs.pem file to that directory.

3. Change the path of `ballerina-performance-aws-ecs` file in the `ec2-cfn.sh` file

4. Change values of ParameterValue according to the ParameterKey in the `ec2-cfn.sh` file as required for the test.

```
--parameters \
ParameterKey=KeyName,ParameterValue=ballerina-performance-ecs \
ParameterKey=InstanceType,ParameterValue=c5.xlarge \
ParameterKey=BallerinaMemory,ParameterValue=8192 \
ParameterKey=BallerinaCPU,ParameterValue=4096 \
ParameterKey=GitHubRepoBranch,ParameterValue=master \
ParameterKey=JMeterOptions,ParameterValue="-m 2G -u 100 -b 50 -b 100" \
ParameterKey=UserEmail,ParameterValue=user@example.com \
ParameterKey=BallerinaVersion,ParameterValue=swan-lake-alpha3 \
--capabilities CAPABILITY_IAM --tags Key=User,Value=user@wso2.com
```

You can change values of the JMeterOptions ParameterKey as below examples.

To do the test for two message sizes.
```
"-m 2G -u 100 -b 50 -b 100"
```
To do the test for two message sizes and two concurrent users.
```
"-m 2G -u 100 -u 150 -b 50 -b 100"
```

Usage of JMeterOptions: 

```
   [-u <concurrent_users>] [-b <message_sizes>] [-m <heap_sizes>] [-d <test_duration>] [-w <warmup_time>]
   [-j <jmeter_server_heap_size>] [-k <jmeter_client_heap_size>] [-l <netty_service_heap_size>]
   [-i <include_scenario_name>] [-e <exclude_scenario_name>] [-t] [-p <estimated_processing_time_in_between_tests>] [-h]

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

5. In the current directory ( `/../ballerina-performance-aws-ecs/distribution/scripts/cloudformation` ) use `sh ./ec2-cfn.sh` to run tests. 

```
sh ./ec2-cfn.sh
```

6. If you are going to log in to the EC2 instance which is created by `ec2-cfn.sh` first time, give yes for the following question in the terminal.

```
{
    "StackId": "arn:aws:cloudformation:us-east-2:134633749276:stack/ec2-stack/37bb8f30-9034-11eb-8239-06f2546a4124"
}
Pseudo-terminal will not be allocated because stdin is not a terminal.
The authenticity of host 'ec2-3-135-215-193.us-east-2.compute.amazonaws.com (3.135.215.193)' can't be established.
ECDSA key fingerprint is SHA256:6nLGsDczrl4YniGcjk1wCf4B7+xhWqDBaYv/yLS7b/M.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

7. After completing the test, end of the terminal gives output as below according to your test.

```
Actual execution times:
Scenario                                        Combination(s)                                         Actual Time
h1c-h1c-passthrough                                          2                       30 minute(s) and 27 second(s)
                                   Total                     2                       30 minute(s) and 27 second(s)
Script execution time: 41 minute(s) and 52 second(s)
Cloud-init v. 20.2-45-g5f7825e2-0ubuntu1~18.04.1 running 'modules:final' at Mon, 29 Mar 2021 02:21:12 +0000. Up 19.83 seconds.
Cloud-init v. 20.2-45-g5f7825e2-0ubuntu1~18.04.1 finished at Mon, 29 Mar 2021 03:07:03 +0000. Datasource DataSourceEc2Local.  Up 2770.40 seconds.
```

8. Come back to local machine terminal and check whether the cloudformation stacks are deleted cpmpletely.

## Notes

- This test build only for h1c-h1c passthrough.
- Before changing the BallerinaMemory and BallerinaCPU values refer [this](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)

## Implementation

- Add other test scenarios. (In HTTPS tests, You have to change the Healthcheck protocols in ecs-stack)
- Run task in the cluster for particular test scenario without creating whole cluster from the bottom.
- Multiply the jmeter clients.

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. To start contributing, read these [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md) for information on how you should go about contributing to our project.

Check the issue tracker for open issues that interest you. We look forward to receiving your contributions.

## License

Ballerina code is distributed under [Apache license 2.0](https://github.com/ballerina-platform/ballerina-lang/blob/master/LICENSE).

## Useful links

* The ballerina-dev@googlegroups.com mailing list is for discussing code changes to the Ballerina project.
* Chat live with us on our [Slack channel](https://ballerina-platform.slack.com/).
* Technical questions should be posted on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.