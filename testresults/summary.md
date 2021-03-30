# Ballerina Performance Test Results

During each release, we execute various automated performance test scenarios and publish the results.

| Test Scenarios | Description |
| --- | --- |
| Passthrough HTTP service (h1c -> h1c) | An HTTP Service, which forwards all requests to an HTTP back-end service. |

Our test client is [Apache JMeter](https://jmeter.apache.org/index.html). We test each scenario for a fixed duration of
time. We split the test results into warmup and measurement parts and use the measurement part to compute the
performance metrics.

A majority of test scenarios use a [Netty](https://netty.io/) based back-end service which echoes back any request
posted to it after a specified period of time.

We run the performance tests under different numbers of concurrent users, message sizes (payloads) and back-end service
delays. And also we can change the infrastructure of the ballerina server.

The main performance metrics:

1. **Throughput**: The number of requests that the Ballerina service processes during a specific time interval (e.g. per second).
2. **Response Time**: The end-to-end latency for an operation of invoking a Ballerina service. The complete distribution of response times was recorded.

In addition to the above metrics, we measure the load average and several memory-related metrics.

The following are the test parameters.

| Test Parameter | Description | Values |
| --- | --- | --- |
| Scenario Name | The name of the test scenario. | Refer to the above table. |
| Heap Size | The amount of memory allocated to the application | 2G |
| Concurrent Users | The number of users accessing the application at the same time. | 50, 100 |
| Message Size (Bytes) | The request payload size in Bytes. |  |
| Back-end Delay (ms) | The delay added by the back-end service. |  |

The duration of each test is **900 seconds**. The warm-up period is **300 seconds**.
The measurement results are collected after the warm-up period.

The specific memory and cpu values(https://docs.amazonaws.cn/en_us/AmazonECS/latest/APIReference/API_TaskDefinition.html) were used to install Ballerina.

The following are the measurements collected from each performance test conducted for a given combination of
test parameters.

| Measurement | Description |
| --- | --- |
| Error % | Percentage of requests with errors |
| Average Response Time (ms) | The average response time of a set of results |
| Standard Deviation of Response Time (ms) | The “Standard Deviation” of the response time. |
| 99th Percentile of Response Time (ms) | 99% of the requests took no more than this time. The remaining samples took at least as long as this |
| Throughput (Requests/sec) | The throughput measured in requests per second. |
| Average Memory Footprint After Full GC (M) | The average memory consumed by the application after a full garbage collection event. |

The following is the summary of performance test results collected for the measurement period.

|  Scenario Name | Heap Size | Concurrent Users | Message Size (Bytes) | Back-end Service Delay (ms) | Label | # Samples | Error Count | Error % | Throughput (Requests/sec) | Average Response Time (ms) | Average Users in the System | Standard Deviation of Response Time (ms) | Minimum Response Time (ms) | 75th Percentile of Response Time (ms) | 90th Percentile of Response Time (ms) | 95th Percentile of Response Time (ms) | 98th Percentile of Response Time (ms) | 99th Percentile of Response Time (ms) | 99.9th Percentile of Response Time (ms) | Received (KB/sec) | Sent (KB/sec) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 50_users | 50B | No | HTTP Request | 3642896 | 0 | 0 | 6071.98 | 8.21 | 49 | 2.22 | 1 | 9 | 11 | 12 | 14 | 15 | 17 | 1049.55 | 1369.75 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 50_users | 1024B | No | HTTP Request | 3679257 | 0 | 0 | 6132.67 | 8.12 | 49 | 1.95 | 1 | 9 | 11 | 12 | 13 | 14 | 16 | 6905.24 | 7228.64 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 100_users | 50B | No | HTTP Request | 3582986 | 0 | 0 | 5971.95 | 16.71 | 99 | 4.1 | 1 | 19 | 22 | 24 | 27 | 28 | 31 | 1032.26 | 1347.19 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 100_users | 1024B | No | HTTP Request | 3633040 | 0 | 0 | 6055.25 | 16.48 | 99 | 3.84 | 1 | 19 | 22 | 23 | 25 | 27 | 30 | 6818.07 | 7137.39 |
