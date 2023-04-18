#!/bin/bash

# Create the Lambda layer
rm -rf lambda_layer
mkdir lambda_layer
bundle install --path=lambda_layer/gems --deployment
cd lambda_layer
zip -r ../lambda_layer.zip *
cd ..

# Create the Lambda function
rm -f lambda_function.zip
zip -r lambda_function.zip lambda_function.rb -x "*.git*" "*.DS_Store*"

# Print the SHA256 hashes of the ZIP files
shasum -a 256 lambda_function.zip
shasum -a 256 lambda_layer.zip
