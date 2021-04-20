# Ballerina Performance Test Results

Ballerina Version: **swan-lake-alpha4**

| Test Scenarios | Description |
| --- | --- |
| Passthrough HTTP service (h1c -> h1c) | An HTTP Service, which forwards all requests to an HTTP back-end service. |
| Passthrough HTTPS service (h1 -> h1) | An HTTPS Service, which forwards all requests to an HTTPS back-end service. |

Our test client is [Apache JMeter](https://jmeter.apache.org/index.html). We test each scenario for a fixed duration of
time. We split the test results into warmup and measurement parts and use the measurement part to compute the
performance metrics.

All the test scenarios use a [Netty](https://netty.io/) based back-end service which echoes back any request
posted to it after a specified period of time.

We run the performance tests under different numbers of concurrent users, message sizes (payloads) and back-end service
delays. Also, we can change the infrastructure (CPU and memory) of the Ballerina services.

The main performance metrics:

1. **Throughput**: The number of requests that the Ballerina service processes during a specific time interval (e.g. per second).
2. **Response Time**: The end-to-end latency for an operation of invoking a Ballerina service. The complete distribution of response times was recorded.

In addition to the above metrics, we measure the load average and several memory-related metrics.

The following are the test parameters.

| Test Parameter | Description | Values |
| --- | --- | --- |
| Scenario Name | The name of the test scenario. | Refer to the above table. |
| Heap Size | The amount of memory allocated to the application | 2G |
| Concurrent Users | The number of users accessing the application at the same time. | 100, 300, 1000 |
| Message Size (Bytes) | The request payload size in Bytes. | 50, 1024 |
| Back-end Delay (ms) | The delay added by the back-end service. | 0 |
| Ballerina CPU (MB) | The CPU allocation for Ballerina service. | 4096 |
| Ballerina Memory (MB) | The Memory allocation for Ballerina service. | 8192 |

The duration of each test is **900 seconds**. The warm-up period is **300 seconds**.
The measurement results are collected after the warm-up period.

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
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 100_users | 50B | No | HTTP Request | 3808277 | 0 | 0 | 6347.33 | 15.71 | 99 | 3.52 | 1 | 18 | 21 | 22 | 24 | 26 | 29 | 1097.15 | 1431.87 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 100_users | 1024B | No | HTTP Request | 3784612 | 0 | 0 | 6307.81 | 15.81 | 99 | 3.27 | 1 | 18 | 20 | 22 | 23 | 25 | 28 | 7102.45 | 7435.09 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 300_users | 50B | No | HTTP Request | 2670154 | 0 | 0 | 4449.45 | 67.36 | 299 | 22.86 | 3 | 76 | 91 | 123 | 133 | 139 | 153 | 769.09 | 1003.73 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 300_users | 1024B | No | HTTP Request | 2773803 | 0 | 0 | 4622.19 | 64.84 | 299 | 22.56 | 1 | 74 | 86 | 121 | 131 | 136 | 147 | 5204.48 | 5448.22 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 1000_users | 50B | No | HTTP Request | 2010133 | 0 | 0 | 3332.48 | 299.46 | 997 | 81.88 | 1 | 363 | 419 | 445 | 465 | 483 | 547 | 576.02 | 751.76 |
|  Passthrough HTTP service (h1c -> h1c) | 2G_heap | 1000_users | 1024B | No | HTTP Request | 2047449 | 0 | 0 | 3397.54 | 293.92 | 998 | 79.23 | 2 | 357 | 409 | 435 | 457 | 475 | 535 | 3825.55 | 4004.72 |
|  Passthrough HTTPS service (h1 -> h1) | 2G_heap | 100_users | 50B | No | HTTP Request | 5328839 | 0 | 0 | 8880.98 | 11.2 | 99 | 2.94 | 0 | 13 | 15 | 17 | 18 | 19 | 25 | 1535.09 | 2012.1 |
|  Passthrough HTTPS service (h1 -> h1) | 2G_heap | 100_users | 1024B | No | HTTP Request | 5075154 | 0 | 0 | 8458.98 | 11.77 | 99 | 2.94 | 0 | 14 | 16 | 17 | 19 | 20 | 26 | 9524.62 | 9978.96 |
|  Passthrough HTTPS service (h1 -> h1) | 2G_heap | 300_users | 50B | No | HTTP Request | 3718971 | 0 | 0 | 6196.88 | 48.32 | 299 | 19.74 | 0 | 55 | 62 | 69 | 126 | 131 | 142 | 1071.14 | 1403.98 |
|  Passthrough HTTPS service (h1 -> h1) | 2G_heap | 300_users | 1024B | No | HTTP Request | 3972498 | 0 | 0 | 6618.45 | 45.23 | 299 | 17.44 | 1 | 52 | 59 | 64 | 121 | 129 | 143 | 7452.22 | 7807.7 |
|  Passthrough HTTPS service (h1 -> h1) | 2G_heap | 1000_users | 50B | No | HTTP Request | 2337273 | 0 | 0 | 3847.12 | 257.92 | 992 | 89.89 | 0 | 303 | 405 | 425 | 447 | 461 | 531 | 664.98 | 871.61 |
|  Passthrough HTTPS service (h1 -> h1) | 2G_heap | 1000_users | 1024B | No | HTTP Request | 2369784 | 0 | 0 | 3889.56 | 254.69 | 990 | 93.59 | 1 | 305 | 405 | 433 | 457 | 473 | 567 | 4379.55 | 4588.46 |
