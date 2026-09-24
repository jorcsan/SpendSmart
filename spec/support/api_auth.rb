# ApplicationController#authenticate_cli rejects any request whose Accept header
# asks for JSON unless it carries the matching bearer token, so a JSON request
# spec has to supply both. Without this, every such spec gets a 401 body instead
# of the payload it asserts on.
module ApiAuth
  TOKEN = "test-api-token".freeze

  def json_headers
    { "Accept" => "application/json", "Authorization" => "Bearer #{TOKEN}" }
  end
end

RSpec.configure do |config|
  config.include ApiAuth, type: :request

  # Set for every request spec, not only the JSON ones: an HTML request never
  # reaches the filter, so there is nothing to opt out of.
  config.around(:each, type: :request) do |example|
    previous = ENV["SPENDSMART_API_TOKEN"]
    ENV["SPENDSMART_API_TOKEN"] = ApiAuth::TOKEN
    example.run
  ensure
    ENV["SPENDSMART_API_TOKEN"] = previous
  end
end
