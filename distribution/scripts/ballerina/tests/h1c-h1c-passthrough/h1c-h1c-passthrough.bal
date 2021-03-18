// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/config;
import ballerina/http;
import ballerina/log;

http:Client nettyEP = new("http://" + config:getAsString("b7a.netty")+ ":8688");

@http:ServiceConfig { basePath: "/passthrough" }
service passthroughService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request clientRequest) {
        var response = nettyEP->forward("/service/EchoService", clientRequest);
	
        if (response is http:Response) {
            var clientResponse2=test(response);
            var result = caller->respond(clientResponse2);
    }}
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/health-check"
    }
    resource function healthCheck(http:Caller caller, http:Request clientRequest) {
        http:Response response = new;
        response.statusCode = 200;
        response.setTextPayload("Health check passed!");
        var result = caller->respond(response);
        if (result is error) {
           log:printError("Error in responding", result);
        }
    }
}
function test (http:Response res) returns @untainted http:Response {
    return res;
} 
