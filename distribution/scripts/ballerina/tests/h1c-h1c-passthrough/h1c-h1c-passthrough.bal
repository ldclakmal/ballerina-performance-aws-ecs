// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/http;
import ballerina/log;
import ballerina/os;

http:Client nettyEP = checkpanic new("http://" + os:getEnv("netty")+ ":8688");

service /passthrough on new http:Listener(9090) {
    
    resource function post .(http:Request req) returns http:Response|http:InternalServerError {
        var response = nettyEP->forward("/service/EchoService", req);
        if (response is http:Response) {
            return response;
        } else {
            log:printError("Error at h1c-h1c-passthrough", 'error = response);
            http:InternalServerError internalServerError = {
                body: response.message()
            };
            return internalServerError;
        }
    }

    resource function get healthcheck() returns http:Ok {
        http:Ok Ok = {
            body: "Health check passed!"
        };
        return Ok;
    }
}
