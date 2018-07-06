import ballerina/http;

endpoint http:Listener listener {
    port:9090
};

// InstTwi REST service
@http:ServiceConfig { basePath: "/trend-analyzer" }
service<http:Service> InstTwi bind listener {

    // Resource that handles the HTTP POST requests that are directed to
    // the path `/operation` to execute a given calculate operation
    // Sample requests for add operation in JSON format
    // `{ "operation": "activate"}`
    // `{ "operation": "act"}`

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/operation"
    }
    executeOperation(endpoint client, http:Request req) {
        json operationReq = check req.getJsonPayload();
        string operation = operationReq.operation.toString();

        boolean result = false;

        if(operation == "activate" || operation == "act") {
            result = activate();
        }

        // Create response message.
        json payload = { status: "Result of " + operation, result: "false" };
        payload["result"] =result;
        http:Response response;
        response.setJsonPayload(payload);

        // Send response to the client.
        _ = client->respond(response);
    }
}
