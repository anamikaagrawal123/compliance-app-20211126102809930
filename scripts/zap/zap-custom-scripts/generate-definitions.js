/**
 * Licensed Materials - Property of IBM
 * (c) Copyright IBM Corporation 2021. All Rights Reserved.
 *
 * Note to U.S. Government Users Restricted Rights:
 * Use, duplication or disclosure restricted by GSA ADP Schedule
 * Contract with IBM Corp.
 */
 'use strict';

/*
 * Given Swagger or OpenAPI JSON file path as input, prints out the complete definition as expected by
 * the ZAP API scanner, with apisToScan.
 * 
 * https://github.ibm.com/owasp-tools/api-dynamic-scans/tree/onePipelinev2UBI#api-details
 */

function generateDefinition(swaggerJsonFile) {
    if (!swaggerJsonFile) {
        console.error('Error: You must provide a JSON Swagger or OpenAPI file to generate definitions, e.g. node generate-definition myswagger.json');
        process.exit(1);
    }
    const swagger = require(swaggerJsonFile);
    const definition = {
        excludeScanTypes: [],
        apisToScan: generateApisToScan(swagger),
        apiDefinitionJson: swagger
    };
    console.log(JSON.stringify(definition, null, 4));
}

function generateApisToScan(swagger) {
    let apisToScan = [];
    for (let path in swagger.paths) {
        const pathEntry = swagger.paths[path];
        for (let method in pathEntry) {
            const methodEntry = pathEntry[method];
            let entry = {
                path: path,
                method: method
            };
            if (methodEntry.parameters) {
                let parameters = {};
                for (let param of methodEntry.parameters) {
                    parameters[param.name] = '';
                }
                entry.parameters = parameters;
            }
            if (methodEntry.requestBody) {
                entry.body = {};
            }
            apisToScan.push(entry);
        }
    }
    return apisToScan;
}

generateDefinition(process.argv[2]);