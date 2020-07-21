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
            var result = caller->respond(response);
        } else {
            log:printError("Error at h1c_h1c_passthrough", err = response);
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(response.message());
            var result = caller->respond(res);
        }
    }
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
