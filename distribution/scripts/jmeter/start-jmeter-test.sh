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
# Script to run JMeter test inside the Docker image.
# ----------------------------------------------------------------------------

# Application heap Sizes
declare -a heap_sizes_array
# Concurrent users (will be divided among JMeter servers)
declare -a concurrent_users_array
# Message Sizes
declare -a message_sizes_array

# Test Duration in seconds
default_test_duration=900
test_duration=$default_test_duration
# Warm-up time in seconds
default_warmup_time=300
warmup_time=$default_warmup_time
# Heap size of JMeter Client
default_jmeter_client_heap_size=2G
jmeter_client_heap_size=$default_jmeter_client_heap_size

# Version used for the splitter and the payload generator
export version=""
# IP or hostname for the Ballerina server
export hostname=""

# Heap size of Netty Service
default_netty_service_heap_size=4G
netty_service_heap_size=$default_netty_service_heap_size

# Scenario names to include
declare -a include_scenario_names
# Scenario names to exclude
declare -a exclude_scenario_names

payload_type=ARRAY
# Estimate flag
estimate=false
# Estimated processing time in between tests
default_estimated_processing_time_in_between_tests=60
estimated_processing_time_in_between_tests=$default_estimated_processing_time_in_between_tests

# Start time of the test
test_start_time=$(date +%s)
# Scenario specific counters
declare -A scenario_counter
# Scenario specific durations
declare -A scenario_duration

function usage() {
    echo ""
    echo "Usage: "
    echo "$0 -m <heap_sizes> -u <concurrent_users> -b <message_sizes>"
    echo "   [-d <test_duration>] [-w <warmup_time>]"
    echo "   [-i <include_scenario_name>] [-e <include_scenario_name>] [-t] [-p <estimated_processing_time_in_between_tests>] [-h]"
    echo ""
    echo "-m: Application heap memory sizes. You can give multiple options to specify multiple heap memory sizes. Allowed suffixes: M, G."
    echo "-u: Concurrent Users to test. You can give multiple options to specify multiple users."
    echo "-b: Message sizes in bytes. You can give multiple options to specify multiple message sizes."
    echo "-d: Test Duration in seconds. Default $default_test_duration."
    echo "-w: Warm-up time in seconds. Default $default_warmup_time."
    echo "-k: Heap Size of JMeter Client. Allowed suffixes: M, G. Default $default_jmeter_client_heap_size."
    echo "-l: Heap Size of Netty Service. Allowed suffixes: M, G. Default $default_netty_service_heap_size."
    echo "-i: Scenario name to to be included. You can give multiple options to filter scenarios."
    echo "-e: Scenario name to to be excluded. You can give multiple options to filter scenarios."
    echo "-t: Estimate time without executing tests."
    echo "-p: Estimated processing time in between tests in seconds. Default $default_estimated_processing_time_in_between_tests."
    echo "-h: Display this help and exit."
    echo ""
}

# Reset getopts
OPTIND=0
while getopts "u:b:m:d:w:k:l:i:e:tp:a:v:h" opts; do
    case $opts in
    u)
        concurrent_users_array+=("${OPTARG}")
        ;;
    b)
        message_sizes_array+=("${OPTARG}")
        ;;
    m)
        heap_sizes_array+=("${OPTARG}")
        ;;
    d)
        test_duration=${OPTARG}
        ;;
    w)
        warmup_time=${OPTARG}
        ;;
    k)
        jmeter_client_heap_size=${OPTARG}
        ;;
    l)
        netty_service_heap_size=${OPTARG}
        ;;
    i)
        include_scenario_names+=("${OPTARG}")
        ;;
    e)
        exclude_scenario_names+=("${OPTARG}")
        ;;
    t)
        estimate=true
        ;;
    p)
        estimated_processing_time_in_between_tests=${OPTARG}
        ;;
    a)
        hostname=${OPTARG}
        ;;
    v)
        version=${OPTARG}
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

# Validate options
number_regex='^[0-9]+$'
float_number_regex="^[0-9]+\.?[0-9]*$"
heap_regex='^[0-9]+[MG]$'

if [ ${#heap_sizes_array[@]} -eq 0 ]; then
    echo "Please provide application heap memory sizes."
    exit 1
fi

if [ ${#concurrent_users_array[@]} -eq 0 ]; then
    echo "Please provide concurrent users to test."
    exit 1
fi

if [ ${#message_sizes_array[@]} -eq 0 ]; then
    echo "Please provide message sizes."
    exit 1
fi

if [[ -z $test_duration ]]; then
    echo "Please provide the test duration."
    exit 1
fi

if ! [[ $test_duration =~ $number_regex ]]; then
    echo "Test duration must be a positive number."
    exit 1
fi

if [[ -z $warmup_time ]]; then
    echo "Please provide the warmup time."
    exit 1
fi

if [[ -z $hostname ]]; then
    echo "Please provide the IP or DNS of server/loadbalancer."
    exit 1
fi

if [[ -z $COMPONENTS_VERSION ]]; then
    echo "Please provide the version for the performance test."
    exit 1
fi

if ! [[ $warmup_time =~ $number_regex ]]; then
    echo "Warmup time must be a positive number."
    exit 1
fi

if [[ $warmup_time -ge $test_duration ]]; then
    echo "The warmup time must be less than the test duration."
    exit 1
fi

for heap in ${heap_sizes_array[@]}; do
    if ! [[ $heap =~ $heap_regex ]]; then
        echo "Please specify a valid heap size for the application."
        exit 1
    fi
done

for users in ${concurrent_users_array[@]}; do
    if ! [[ $users =~ $number_regex ]]; then
        echo "Please specify a valid number for concurrent users."
        exit 1
    fi
done

for msize in ${message_sizes_array[@]}; do
    if ! [[ $msize =~ $number_regex ]]; then
        echo "Please specify a valid number for message size."
        exit 1
    fi
done

if ! [[ $jmeter_client_heap_size =~ $heap_regex ]]; then
    echo "Please specify a valid heap for JMeter Client."
    exit 1
fi

if ! [[ $netty_service_heap_size =~ $heap_regex ]]; then
    echo "Please specify a valid heap for Netty Service."
    exit 1
fi


# Get the test configuration
source ./ballerina-test-config.sh

# Get the test utils
source ./jmeter-test-util.sh


function initialize_test() {
    # Filter scenarios
    if [[ ${#include_scenario_names[@]} -gt 0 ]] || [[ ${#exclude_scenario_names[@]} -gt 0 ]]; then
        declare -n scenario
        for scenario in ${!test_scenario@}; do
            scenario[skip]=true
            for name in ${include_scenario_names[@]}; do
                if [[ ${scenario[name]} =~ $name ]]; then
                    scenario[skip]=false
                fi
            done
            for name in ${exclude_scenario_names[@]}; do
                if [[ ${scenario[name]} =~ $name ]]; then
                    scenario[skip]=true
                fi
            done
        done
    fi

    # Save test metadata
    declare -n scenario
    local all_scenarios=""
    for scenario in ${!test_scenario@}; do
        local skip=${scenario[skip]}
        if [ $skip = true ]; then
            continue
        fi
        all_scenarios+=$(jq -n \
            --arg name "${scenario[name]}" \
            --arg display_name "${scenario[display_name]}" \
            --arg description "${scenario[description]}" \
            --arg jmx "${scenario[jmx]}" \
            '. | .["name"]=$name | .["display_name"]=$display_name | .["description"]=$description | .["jmx"]=$jmx')
    done

    local test_parameters_json='.'
    test_parameters_json+=' | .["test_duration"]=$test_duration'
    test_parameters_json+=' | .["warmup_time"]=$warmup_time'
    test_parameters_json+=' | .["jmeter_client_heap_size"]=$jmeter_client_heap_size'
    test_parameters_json+=' | .["netty_service_heap_size"]=$netty_service_heap_size'
    test_parameters_json+=' | .["test_scenarios"]=$test_scenarios'
    test_parameters_json+=' | .["heap_sizes"]=$heap_sizes | .["concurrent_users"]=$concurrent_users'
    jq -n \
        --arg test_duration "$test_duration" \
        --arg warmup_time "$warmup_time" \
        --arg jmeter_client_heap_size "$jmeter_client_heap_size" \
        --arg netty_service_heap_size "$netty_service_heap_size" \
        --argjson test_scenarios "$(echo "$all_scenarios" | jq -s '.')" \
        --argjson heap_sizes "$(printf '%s\n' "${heap_sizes_array[@]}" | jq -nR '[inputs]')" \
        --argjson concurrent_users "$(printf '%s\n' "${concurrent_users_array[@]}" | jq -nR '[inputs]')" \
        --argjson message_sizes "$(printf '%s\n' "${message_sizes_array[@]}" | jq -nR '[inputs]')" \
        "$test_parameters_json" >test-metadata.json

    if [ "$estimate" = false ]; then
        jmeter_dir=""
        for dir in ./apache-jmeter*; do
            [ -d "${dir}" ] && jmeter_dir="${dir}" && break
        done
        if [[ -d $jmeter_dir ]]; then
            export JMETER_HOME="${jmeter_dir}"
            export PATH=$JMETER_HOME/bin:$PATH
        else
            echo "WARNING: Could not find JMeter directory."
        fi

        if [[ -d results ]]; then
            echo "Results directory already exists. Please backup."
            #exit 1
        fi
        if [[ -f results.zip ]]; then
            echo "The results.zip file already exists. Please backup."
            exit 1
        fi
        #mkdir results
        cp $0 results/
        mv test-metadata.json results/

        declare -a payload_sizes
        for msize in ${message_sizes_array[@]}; do
            payload_sizes+=("-s" "$msize")
        done

        # Payloads should be created in the $HOME directory
        chmod +x ./generate-payload.sh
        if ! ./generate-payload.sh -p $payload_type ${payload_sizes[@]}; then
            echo "WARNING: Failed to generate payloads!"
        fi
    fi
}

function exit_handler() {
    if [[ "$estimate" == false ]] && [[ -d results ]]; then
        echo "Zipping results directory..."
        # Create zip file without JTLs first (in case of limited disc space)
        zip -9qr results-without-jtls.zip results/ -x '*jtls.zip'
        zip -9qr results.zip results/
    fi
    print_durations
}

trap exit_handler EXIT

function test_scenarios() {
    initialize_test
    local test_counter=0
    for heap in ${heap_sizes_array[@]}; do
        declare -ng scenario
        for scenario in ${!test_scenario@}; do
            local skip=${scenario[skip]}
            if [ $skip = true ]; then
                continue
            fi
            local scenario_name=${scenario[name]}
            local jmx_file=${scenario[jmx]}
            for users in ${concurrent_users_array[@]}; do
                for msize in ${message_sizes_array[@]}; do
                    if [ "$estimate" = true ]; then
                        record_scenario_duration $scenario_name $(($test_duration + $estimated_processing_time_in_between_tests))
                        continue
                    fi
                    local start_time=$(date +%s)

                    test_counter=$((test_counter + 1))
                    local scenario_desc="Test No: ${test_counter}, Scenario Name: ${scenario_name}, Duration: $test_duration"
                    scenario_desc+=", Concurrent Users ${users}, Msg Size: ${msize}"
                    echo -n "# Starting the performance test."
                    echo " $scenario_desc"

                    report_location=$PWD/results/${scenario_name}/${heap}_heap/${users}_users/${msize}B

                    echo "Report location is ${report_location}"
                    mkdir -p $report_location

                    declare -ag jmeter_params=("users=${users}" "duration=$test_duration")

                    before_execute_test_scenario

                    export JVM_ARGS="-Xms$jmeter_client_heap_size -Xmx$jmeter_client_heap_size -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$report_location/jmeter_gc.log $JMETER_JVM_ARGS"

                    local jmeter_command="jmeter -n -t ./${jmx_file} -j $report_location/jmeter.log $jmeter_remote_args"

                    for param in ${jmeter_params[@]}; do
                        jmeter_command+=" -J$param"
                    done
                    jmeter_command+=" -l ${report_location}/results.jtl"

                    echo "Starting JMeter Client with JVM_ARGS=$JVM_ARGS"
                    echo "$jmeter_command"

                    # Start timestamp
                    test_start_timestamp=$(date +%s)
                    echo "Start timestamp: $test_start_timestamp"
                    # Run JMeter in background
                    $jmeter_command &
                    local jmeter_pid="$!"
                    if ! wait $jmeter_pid; then
                        echo "WARNING: JMeter execution failed."
                    fi
                    # End timestamp
                    test_end_timestamp="$(date +%s)"
                    echo "End timestamp: $test_end_timestamp"

                    local test_duration_file="${report_location}/test_duration.json"
                    if jq -n --arg start_timestamp "$test_start_timestamp" \
                        --arg end_timestamp "$test_end_timestamp" \
                        --arg test_duration "$(($test_end_timestamp - $test_start_timestamp))" \
                        '. | .["start_timestamp"]=$start_timestamp | .["end_timestamp"]=$end_timestamp | .["test_duration"]=$test_duration' >$test_duration_file; then
                        echo "Wrote test start timestamp, end timestamp and test duration to $test_duration_file."
                    fi

                    if [[ -f ${report_location}/results.jtl ]]; then
                        # Delete the original JTL file to save space.
                        # Can merge files using the command: awk 'FNR==1 && NR!=1{next;}{print}'
                        # However, the merged file may not be same as original and that should be okay
                        chmod +x ./jtl-splitter.sh
                        ./jtl-splitter.sh -- -f ${report_location}/results.jtl -d -t $warmup_time -u SECONDS -s
                        echo "Zipping JTL files in ${report_location}"
                        zip -jm ${report_location}/jtls.zip ${report_location}/results*.jtl
                    fi

                    local current_execution_duration="$(measure_time $start_time)"
                    echo -n "# Completed the performance test."
                    echo " $scenario_desc"
                    echo -e "Test execution time: $(format_time $current_execution_duration)\n"
                    record_scenario_duration $scenario_name $current_execution_duration
                done
            done
        done
    done
}

test_scenarios
