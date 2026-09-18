require "net/http"
require "json"
require "uri"
require "tty-prompt"
API_TOKEN = ENV["SPENDSMART_API_TOKEN"]
#definition for selecting an already existing account 
#and returning its id
def select_account
  uri = URI("http://localhost:3000/accounts")

   # Create an HTTP connection
  http = Net::HTTP.new(uri.host, uri.port)

  # Create a GET request
  request = Net::HTTP::Get.new(uri.request_uri)

  #here we state that we wish to recieve the data in java form
  #we use the API_Token to be able to access data and make request
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{API_TOKEN}"

  # Send the request
  response = http.request(request)

  account_choices = {}

  if response.is_a?(Net::HTTPSuccess)
    accounts = JSON.parse(response.body)

    accounts.each do |account|
      account_choices[account["name"]] = account
    end
  else
    puts "Could not connect to the Rails server."
    exit
  end

  prompt = TTY::Prompt.new

  account_name = prompt.select("ACCOUNT:", account_choices.keys)

  account = account_choices[account_name]

  puts "Selected account: #{account["name"]}"

  return account
end

# Definition to create a new account and return its ID
def create_account
  prompt = TTY::Prompt.new

  # Ask the user for the account name first
  account_name = prompt.ask("Type a name for your new account:")

  # Set the address where our Rails routes are hosted
  uri = URI("http://localhost:3000/accounts")

  # Create an HTTP connection
  http = Net::HTTP.new(uri.host, uri.port)

  # Create a POST request
  request = Net::HTTP::Post.new(uri.path)

  # Tell Rails we are sending JSON
  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{API_TOKEN}"
  # Put the account name into the request
  request.body = {
    account: {
      name: account_name
    }
  }.to_json

  # Send the request
  response = http.request(request)

  # Check whether the account was created successfully
  if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPCreated)
    account = JSON.parse(response.body)

    puts "\nAccount '#{account["name"]}' created successfully!"
    puts "Account ID: #{account["id"]}"

    sleep 1

    # Return the new account's ID
    account
  else
    puts "\nCould not create account."
    puts response.body
    exit
  end
end