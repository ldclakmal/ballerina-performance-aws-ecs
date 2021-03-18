# Ballerina Performance Test Results

During each release, we execute various automated performance test scenarios and publish the results.

| Test Scenarios | Description |
| --- | --- |
| Passthrough HTTP service (h1c -> h1c) | An HTTP Service, which forwards all requests to an HTTP back-end service. |
| JSON to XML transformation HTTP service | An HTTP Service, which transforms JSON requests to XML and then forwards all requests to an HTTP back-end service. |

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
| Concurrent Users | The number of users accessing the application at the same time. | 100 |
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
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 100_users | 50B | No | HTTP Request | 3692152 | 0 | 0 | 6154.09 | 16.19 | 99 | 4.27 | 1 | 19 | 22 | 24 | 27 | 28 | 31 | 1063.74 | 1394.29 |
|  JSON to XML transformation HTTP service | 2G_heap | 100_users | 50B | No | HTTP Request | 822771 | 818857 | 99.52 | 1365.55 | 72.98 | 99 | 845.09 | 0 | 1 | 2 | 2 | 5 | 18 | 10047 | 3596.23 | 1.46 |
