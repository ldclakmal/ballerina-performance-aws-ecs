#!/bin/bash -e
# Copyright (c) 2020, WSO2 Inc. (http://wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# ----------------------------------------------------------------------------
# Declaration of tests for JMeter
# ----------------------------------------------------------------------------

declare -A test_scenario0=(
    [name]="h1c-h1c-passthrough"
    [display_name]="Passthrough HTTP service (h1c -> h1c)"
    [description]="An HTTP Service, which forwards all requests to an HTTP back-end service."
    [bal]="h1c-h1c-passthrough.jar"
    [bal_flags]=""
    [path]="/passthrough"
    [jmx]="http-post-request.jmx"
    [protocol]="http"
    [port]="9090"
    [skip]=false
)

function before_execute_test_scenario() {
    local bal_file=${scenario[bal]}
    local bal_flags=${scenario[bal_flags]}
    local service_path=${scenario[path]}
    local protocol=${scenario[protocol]}
    local port=${scenario[port]}
    jmeter_params+=("host=$hostname" "port=$port" "path=$service_path")
    jmeter_params+=("payload=./${msize}B.json" "response_size=${msize}B" "protocol=$protocol")
    JMETER_JVM_ARGS="-Xbootclasspath/p:/opt/alpnboot/alpnboot.jar"
}
