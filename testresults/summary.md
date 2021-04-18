# Ballerina Performance Test Results
**Ballerina Version: swan-lake-alpha4**

During each release, we execute various automated performance test scenarios and publish the results.

| Test Scenarios | Description |
| --- | --- |
| Passthrough HTTP service (h1c -> h1c) | An HTTP Service, which forwards all requests to an HTTP back-end service. |
| Passthrough HTTPS service (h1 -> h1) | An HTTPS Service, which forwards all requests to an HTTPS back-end service. |

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
| Concurrent Users | The number of users accessing the application at the same time. | 50 |
| Message Size (Bytes) | The request payload size in Bytes. | 50 |
| Back-end Delay (ms) | The delay added by the back-end service. | 0 |

The duration of each test is **900 seconds**. The warm-up period is **300 seconds**.
The measurement results are collected after the warm-up period.

Ballerina Test CPU: **4096 MB**

Ballerina Test Memory: **8192 MB**

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
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 50_users | 50B | No | HTTP Request | 3833878 | 0 | 0 | 6390.41 | 7.8 | 49 | 2.15 | 1 | 9 | 11 | 12 | 13 | 14 | 16 | 1104.59 | 1447.83 |
|  Passthrough HTTPS service (h1 -> h1) | 2G_heap | 50_users | 50B | No | HTTP Request | 3228243 | 0 | 0 | 5380.89 | 9.26 | 49 | 2.58 | 1 | 11 | 13 | 14 | 16 | 17 | 23 | 930.1 | 1219.11 |
