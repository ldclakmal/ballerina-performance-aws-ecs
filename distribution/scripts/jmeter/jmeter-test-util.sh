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
# Utils for JMeter.
# ----------------------------------------------------------------------------

function format_time() {
    # Duration in seconds
    local duration="$1"
    local minutes=$(echo "$duration/60" | bc)
    local seconds=$(echo "$duration-$minutes*60" | bc)
    if [[ $minutes -ge 60 ]]; then
        local hours=$(echo "$minutes/60" | bc)
        minutes=$(echo "$minutes-$hours*60" | bc)
        printf "%d hour(s), %02d minute(s) and %02d second(s)\n" $hours $minutes $seconds
    elif [[ $minutes -gt 0 ]]; then
        printf "%d minute(s) and %02d second(s)\n" $minutes $seconds
    else
        printf "%d second(s)\n" $seconds
    fi
}

function measure_time() {
    local end_time=$(date +%s)
    local start_time=$1
    local duration=$(echo "$end_time - $start_time" | bc)
    echo "$duration"
}

function record_scenario_duration() {
    local scenario_name="$1"
    local duration="$2"
    # Increment counter
    local current_scenario_counter="${scenario_counter[$scenario_name]}"
    if [[ ! -z $current_scenario_counter ]]; then
        scenario_counter[$scenario_name]=$(echo "$current_scenario_counter+1" | bc)
    else
        # Initialize counter
        scenario_counter[$scenario_name]=1
    fi
    # Save duration
    current_scenario_duration="${scenario_duration[$scenario_name]}"
    if [[ ! -z $current_scenario_duration ]]; then
        scenario_duration[$scenario_name]=$(echo "$current_scenario_duration+$duration" | bc)
    else
        # Initialize counter
        scenario_duration[$scenario_name]="$duration"
    fi
}

function print_durations() {
    local time_header=""
    if [ "$estimate" = true ]; then
        time_header="Estimated"
    else
        time_header="Actual"
    fi

    echo "$time_header execution times:"
    local sorted_names=($(
        for name in "${!scenario_counter[@]}"; do
            echo "$name"
        done
    ))
    # Count scenarios
    local total_counter=0
    local total_duration=0
    if [[ ${#sorted_names[@]} -gt 0 ]]; then
        printf "%-40s  %20s  %50s\n" "Scenario" "Combination(s)" "$time_header Time"
        for name in "${sorted_names[@]}"; do
            let total_counter=total_counter+${scenario_counter[$name]}
            let total_duration=total_duration+${scenario_duration[$name]}
            printf "%-40s  %20s  %50s\n" "$name" "${scenario_counter[$name]}" "$(format_time ${scenario_duration[$name]})"
        done
        printf "%40s  %20s  %50s\n" "Total" "$total_counter" "$(format_time $total_duration)"
    else
        echo "WARNING: None of the test scenarios were executed."
        exit 1
    fi
    local test_total_duration_json='.'
    test_total_duration_json+=' | .["test_scenarios"]=$test_scenarios'
    test_total_duration_json+=' | .["total_duration"]=$total_duration'
    jq -n \
        --arg test_scenarios "$total_counter" \
        --arg total_duration "$total_duration" \
        "$test_total_duration_json" >test-duration.json
    printf "Script execution time: %s\n" "$(format_time $(measure_time $test_start_time))"
}
