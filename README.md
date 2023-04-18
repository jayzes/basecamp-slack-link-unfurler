# Basecamp Slack Link Unfurler

This is an AWS Lambda function written in Ruby that listens for Slack `link_shared` events that contain Basecamp links and uses the `chat.unfurl` API to augment the corresponding messages with card previews. This project is also an experiment to see how to build a project from scratch using ChatGPT.

## Prerequisites

- [Terraform](https://www.terraform.io/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Ruby 2.7](https://www.ruby-lang.org/en/downloads/)

## Installation

1. Clone this repository: `git clone https://github.com/example/basecamp-slack-link-unfurler.git`
2. Navigate to the `terraform` directory: `cd basecamp-slack-link-unfurler/terraform`
3. Initialize Terraform: `terraform init`
4. Configure your AWS credentials: `aws configure`
5. Apply the Terraform configuration: `terraform apply`
6. Set the following environment variables:
   - `SLACK_ACCESS_TOKEN`: Your Slack app's OAuth access token
   - `BASECAMP_CLIENT_ID`: Your Basecamp app's client ID
   - `BASECAMP_CLIENT_SECRET`: Your Basecamp app's client secret

## Usage

After installation, the Lambda function will listen for `link_shared` events in your Slack workspace that contain Basecamp links. When it detects a qualifying event, it will use the `chat.unfurl` API to augment the corresponding message with a card preview of the linked Basecamp item.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Note

The `aws_lambda_function_url` output variable is not included in the Terraform configuration since it is not recognized by ChatGPT. However, you can retrieve the URL of the Lambda function from the AWS Console or by using the AWS CLI.
