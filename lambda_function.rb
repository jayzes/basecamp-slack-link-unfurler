require 'aws-sdk-lambda'
require 'slack-ruby-client'
require 'dotenv'
require 'basecamp3'

Dotenv.load

lambda = Aws::Lambda::Client.new(region: ENV['AWS_REGION'])

Slack.configure do |config|
  config.token = ENV['SLACK_ACCESS_TOKEN']
end

client = Slack::Web::Client.new

Basecamp3.configure do |config|
  config.client_id     = ENV['BASECAMP_CLIENT_ID']
  config.client_secret = ENV['BASECAMP_CLIENT_SECRET']
end

def handler(event:, context:)
  payload = JSON.parse(event['body'])

  if payload['event']['type'] == 'link_shared' && payload['event']['links'][0]['url'].match(/basecamp\.com\/\d+\//)
    channel_id = payload['event']['channel']
    ts = payload['event']['message_ts']
    basecamp_url = payload['event']['links'][0]['url']
    basecamp_project_id = basecamp_url.match(/basecamp\.com\/(\d+)\//)[1]
    basecamp_todo_id = basecamp_url.match(/todos\/(\d+)/)[1]
    basecamp = Basecamp3::Client.new(access_token: ENV['BASECAMP_ACCESS_TOKEN'])
    todo = basecamp.todos.find(basecamp_todo_id, project_id: basecamp_project_id)
    creator_name = todo.creator.name
    assignees_names = todo.assignees.map(&:name).join(", ")
    due_date = Date.parse(todo.due_on).strftime("%B %d, %Y")

    attachment = {
      title: todo.content,
      title_link: basecamp_url,
      color: '#00bcd4',
      author_name: creator_name,
      fields: [
        {
          title: "Assignees",
          value: assignees_names,
          short: true
        },
        {
          title: "Due Date",
          value: due_date,
          short: true
        }
      ]
    }

    client.chat_unfurl(
      channel: channel_id,
      ts: ts,
      unfurls: {
        basecamp_url => attachment
      }
    )

    {
      statusCode: 200,
      body: "Success"
    }
  else
    {
      statusCode: 200,
      body: "Not a link to a Basecamp to-do"
    }
  end
end
