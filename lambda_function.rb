require 'json'
require 'net/http'
require 'uri'

def handler(event:, context:)
  # Check if the event is a "link_shared" event
  return unless event['type'] == 'link_shared'

  event['links'].each do |link|
    # Check if the link is a Basecamp link
    next unless link['url'].start_with?('https://3.basecamp.com')

    # Extract the project ID and card ID from the link URL
    _, project_id, _, card_id = link['url'].split('/')

    # Call the Basecamp 3 API to get information about the card table
    uri = URI.parse("https://3.basecampapi.com/#{project_id}/buckets/#{card_id}/cards/#{card_id}.json")
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(ENV['BASECAMP_CLIENT_ID'], ENV['BASECAMP_CLIENT_SECRET'])
    request['User-Agent'] = 'MyLambdaFunction'

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Parse the response from the Basecamp 3 API
    card = JSON.parse(response.body)

    # Call the chat.unfurl API to augment the corresponding message with a card preview
    uri = URI.parse('https://slack.com/api/chat.unfurl')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{ENV['SLACK_ACCESS_TOKEN']}"
    request.body = {
      channel: event['channel'],
      ts: link['ts'],
      unfurls: {
        link['url'] => {
          title: card['name'],
          text: card['description'],
          color: '#36a64f', # green
          fields: [
            {
              title: 'Table',
              value: card['bucket']['name'],
              short: true
            },
            {
              title: 'Column',
              value: card['column_name'],
              short: true
            }
          ],
          unfurl_media: true
        }
      }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    # Log the response from the chat.unfurl API
    puts "Response from chat.unfurl API: #{response.body}"
  end
end
