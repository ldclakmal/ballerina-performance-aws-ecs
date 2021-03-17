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

import ballerina/http;
import ballerina/log;
import ballerina/xmlutils;
import ballerina/config;

http:Client nettyEP = new("http://" + config:getAsString("b7a.netty")+ ":8688");
@http:ServiceConfig { basePath: "/transform" }
service transformationService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }
    resource function transform(http:Caller caller, http:Request req) {
        json|error payload = req.getJsonPayload();

        if (payload is json) {
            xml|error xmlPayload = xmlutils:fromJSON(payload);

            if (xmlPayload is xml) {
                http:Request clinetreq = new;
                clinetreq.setXmlPayload(<@untainted> xmlPayload);

                var response = nettyEP->post("/service/EchoService", clinetreq);

                if (response is http:Response) {
                    var result = caller->respond(<@untainted>response);
                } else {
                    log:printError("Error at h1c_transformation", <error>response);
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload((<@untainted error>response).message());
                    var result = caller->respond(res);
                }
            } else {
                log:printError("Error at h1c_transformation", err = xmlPayload);
                http:Response res = new;
                res.statusCode = 400;
                res.setPayload(<@untainted> xmlPayload.message());
                var result = caller->respond(res);
            }
        } else {
            log:printError("Error at h1c_transformation", err = payload);
            http:Response res = new;
            res.statusCode = 400;
            res.setPayload(<@untainted> payload.message());
            var result = caller->respond(res);
        }
    }
}
