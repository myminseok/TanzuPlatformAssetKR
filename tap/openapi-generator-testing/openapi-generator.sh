#!/bin/bash
rm -rf ./apis
rm -rf ./apis-openapi

docker run --rm \
  -v ${PWD}:/local openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/openapitools/openapi-generator/master/modules/openapi-generator/src/test/resources/3_0/petstore.yaml \
  -g html2  \
  -o /local/apis

docker run --rm \
  -v ${PWD}:/local openapitools/openapi-generator-cli generate \
  -i https://raw.githubusercontent.com/openapitools/openapi-generator/master/modules/openapi-generator/src/test/resources/3_0/petstore.yaml \
  -g openapi \
  -o /local/apis-openapi

sudo chown -R ubuntu:ubuntu ./apis
sudo chown -R ubuntu:ubuntu ./apis-openapi
cp apis-openapi/openapi.json ./apis/openapi.json


  ## openapi
  ## nodejs-express-server
  ## javascript

#sudo chown -R ubuntu:ubuntu apis
