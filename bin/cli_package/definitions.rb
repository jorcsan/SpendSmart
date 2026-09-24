require "net/http"
require "json"
require "uri"
require "date"
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

  # Look the category up, creating it when it is new, so the user never has to
  # set one up before recording an expense. Shared with edit_expense.
  category_id = find_or_create_category_id(category_name)
  return nil if category_id.nil?

  category = { "id" => category_id }

  # Automatically use today's date. Date.today, not Date.current: the latter is
  # ActiveSupport, and this CLI runs as plain Ruby outside the Rails process.
  # It only appeared to work under Cucumber because features/support/env.rb
  # loads config/environment first.
  date = Date.today

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

# Expense edit / delete definitions
# ---------------------------------
# Both need the user to pick an existing expense first, so the listing and the
# picker live here rather than being duplicated in each one.

def api_request(request)
  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{API_TOKEN}"

  uri = request.uri
  Net::HTTP.new(uri.host, uri.port).request(request)
end

# Every expense belonging to one account, newest first (the server orders it).
def fetch_expenses(account_id)
  uri = URI("http://localhost:3000/expenses?account_id=#{account_id}")
  response = api_request(Net::HTTP::Get.new(uri))

  unless response.is_a?(Net::HTTPSuccess)
    puts "\nCould not load expenses."
    return []
  end

  JSON.parse(response.body)
end

# Returns the chosen expense, or nil when there is nothing to choose from.
def choose_expense(account_id, prompt, action)
  expenses = fetch_expenses(account_id)

  if expenses.empty?
    puts "\nThere are no expenses to #{action} for this account."
    return nil
  end

  choices = {}
  expenses.each do |expense|
    label = format("%s  %-24s $%-9s %s",
                   expense["date"],
                   expense["description"].to_s[0, 24],
                   expense["price"],
                   expense["category_name"])
    choices[label] = expense
  end

  choices[prompt.select("Choose an expense to #{action}:", choices.keys)]
end

def edit_expense(account_id, prompt = TTY::Prompt.new)
  expense = choose_expense(account_id, prompt, "edit")
  return nil if expense.nil?

  puts "\nPress ENTER without typing anything to keep the current value."

  # Single-argument ask, so the FakePrompt used by the Cucumber steps keeps
  # working. Blank means "unchanged" rather than "clear it".
  description = prompt.ask("Description [#{expense["description"]}]:")
  price       = prompt.ask("Price [#{expense["price"]}]:")
  category    = prompt.ask("Category [#{expense["category_name"]}]:")

  changes = {}
  changes[:description] = description.strip unless description.to_s.strip.empty?
  changes[:price] = price.strip unless price.to_s.strip.empty?

  unless category.to_s.strip.empty?
    category_id = find_or_create_category_id(category.strip)
    return nil if category_id.nil?

    changes[:category_id] = category_id
  end

  if changes.empty?
    puts "\nNothing changed."
    return expense
  end

  uri = URI("http://localhost:3000/expenses/#{expense["id"]}")
  request = Net::HTTP::Patch.new(uri)
  request.body = { expense: changes }.to_json
  response = api_request(request)

  if response.is_a?(Net::HTTPSuccess)
    updated = JSON.parse(response.body)
    puts "\nUpdated: #{updated["description"]} - $#{updated["price"]} (#{updated["category_name"]})"
    updated
  else
    puts "\nCould not update the expense."
    report_errors(response)
    nil
  end
end

def delete_expense(account_id, prompt = TTY::Prompt.new)
  expense = choose_expense(account_id, prompt, "delete")
  return nil if expense.nil?

  # select rather than yes?, so the Cucumber FakePrompt can drive it too.
  answer = prompt.select(
    "Delete '#{expense["description"]}' ($#{expense["price"]})? This cannot be undone.",
    [ "No, keep it", "Yes, delete it" ]
  )

  if answer != "Yes, delete it"
    puts "\nNothing was deleted."
    return nil
  end

  uri = URI("http://localhost:3000/expenses/#{expense["id"]}")
  response = api_request(Net::HTTP::Delete.new(uri))

  if response.is_a?(Net::HTTPSuccess)
    puts "\nDeleted '#{expense["description"]}'."
    expense
  else
    puts "\nCould not delete the expense."
    report_errors(response)
    nil
  end
end

# Rails answers a failed save with a JSON hash of field => [messages].
def report_errors(response)
  errors = JSON.parse(response.body)
  errors.each { |field, messages| puts "  #{field}: #{Array(messages).join(", ")}" }
rescue JSON::ParserError
  puts "  #{response.code} #{response.message}"
end

# Returns the id of the category with this name, creating it when it does not
# exist yet. Matching is case-insensitive to line up with the uniqueness rule
# on the model, so "grocery" will not create a second "Grocery".
def find_or_create_category_id(name)
  uri = URI("http://localhost:3000/categories")
  response = api_request(Net::HTTP::Get.new(uri))

  unless response.is_a?(Net::HTTPSuccess)
    puts "\nCould not retrieve categories."
    return nil
  end

  existing = JSON.parse(response.body).find { |cat| cat["name"]&.casecmp(name)&.zero? }
  return existing["id"] if existing

  puts "\nCategory '#{name}' does not exist - creating it."

  request = Net::HTTP::Post.new(uri)
  request.body = { category: { name: name } }.to_json
  create_response = api_request(request)

  unless create_response.is_a?(Net::HTTPSuccess)
    puts "\nCould not create category."
    report_errors(create_response)
    return nil
  end

  JSON.parse(create_response.body)["id"]
end
