require "net/http"
require "json"
require "uri"
require "tty-prompt"
API_TOKEN = ENV["SPENDSMART_API_TOKEN"]
# definition for selecting an already existing account
# and returning its id
def select_account(prompt = TTY::Prompt.new)
  uri = URI("http://localhost:3000/accounts")


  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)

  # here we state that we wish to recieve the data in java form
  # we use the API_Token to be able to access data and make request
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{API_TOKEN}"


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

  account_name = prompt.select("ACCOUNT:", account_choices.keys)

  account = account_choices[account_name]

  puts "Selected account: #{account["name"]}"

  account
end

# Definition to create a new account and return its ID
def create_account(prompt = TTY::Prompt.new)
  # Ask the user for the account name first
  account_name = prompt.ask("Type a name for your new account:")

  uri = URI("http://localhost:3000/accounts")
  http = Net::HTTP.new(uri.host, uri.port)
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

  if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPCreated)
    account = JSON.parse(response.body)

    puts "\nAccount '#{account["name"]}' created successfully!"
    puts "Account ID: #{account["id"]}"

    sleep 1

    account
  else
    puts "\nCould not create account."
    puts response.body
    exit
  end
end

# Expense Definitions
# Definition to create a new account and return its ID
def create_account(prompt = TTY::Prompt.new)
  account_name = prompt.ask("Type a name for your new account:")

  uri = URI("http://localhost:3000/accounts")
  http = Net::HTTP.new(uri.host, uri.port)
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


  response = http.request(request)


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

def create_expense(account_id, prompt = TTY::Prompt.new)
  description = prompt.ask("Description:")
  price = prompt.ask("Price:")
  category_name = prompt.ask("Category:")

  if description.nil? || description.strip.empty?
    puts "Description cannot be empty."
    return nil
  end

  if price.nil? || price.strip.empty?
    puts "Price cannot be empty."
    return nil
  end

  if category_name.nil? || category_name.strip.empty?
    puts "Category cannot be empty."
    return nil
  end

  # check that the category does exist
  uri = URI("http://localhost:3000/categories")
  http = Net::HTTP.new(uri.host, uri.port)

  request = Net::HTTP::Get.new(uri.request_uri)
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{API_TOKEN}"

  response = http.request(request)

  unless response.is_a?(Net::HTTPSuccess)
    puts "\nCould not retrieve categories."
    puts response.body
    return nil
  end

  categories = JSON.parse(response.body)

category = categories.find do |cat|
  cat["name"]&.casecmp(category_name) == 0
end

  # Create category if it doesn't exist
  # this is the way categories will be created so user does
  # not have to create one before entering an expense
  unless category
    puts "\nCategory '#{category_name}' does not exist."

    create_request = Net::HTTP::Post.new(uri.request_uri)
    create_request["Content-Type"] = "application/json"
    create_request["Accept"] = "application/json"
    create_request["Authorization"] = "Bearer #{API_TOKEN}"

    create_request.body = {
      category: {
        name: category_name
      }
    }.to_json

    create_response = http.request(create_request)

    unless create_response.is_a?(Net::HTTPSuccess) ||
           create_response.is_a?(Net::HTTPCreated)
      puts "\nCould not create category."
      puts create_response.body
      return nil
    end

    category = JSON.parse(create_response.body)

    puts "Category '#{category["name"]}' created successfully!"
  end

  # Automatically use today's date
  date = Date.current

  uri = URI("http://localhost:3000/expenses")
  http = Net::HTTP.new(uri.host, uri.port)

  request = Net::HTTP::Post.new(uri.request_uri)
  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{API_TOKEN}"

  request.body = {
    expense: {
      account_id: account_id,
      category_id: category["id"],
      price: price,
      description: description,
      date: date
    }
  }.to_json

  response = http.request(request)

  if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPCreated)
    expense = JSON.parse(response.body)

    puts "\nExpense created successfully!"
    puts "Description: #{expense["description"]}"
    puts "Price: #{expense["price"]}"
    puts "Category: #{category["name"]}"
    puts "Date: #{expense["date"]}"

    expense
  else
    puts "\nCould not create expense."
    puts response.body
    nil
  end
end
