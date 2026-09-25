require_relative "../../bin/cli_package/definitions"

class ExpenseFakePrompt
  def initialize(description, price, category)
    @answers = [ description, price, category ]
  end

  def ask(_message)
    @answers.shift
  end
end

# happy path test
Given('a category named {string} exists') do |category_name|
  @category = Category.where("LOWER(name) = ?", category_name.downcase).first

  unless @category
    @category = Category.create!(name: category_name)
  end
end

When('I create an expense for {string} with description {string} price {string} and category {string}') do |account_name, description, price, category_name|
  prompt = ExpenseFakePrompt.new(description, price, category_name)

  @expense = create_expense(@account.id, prompt)
end

Then('the expense should have description {string}') do |description|
  expect(@expense["description"]).to eq(description)
end

Then('the expense should have price {string}') do |price|
  expect(@expense["price"].to_f).to eq(price.to_f)
end

Then('the expense should belong to the {string} account') do |account_name|
  expect(@expense["account_id"]).to eq(@account.id)
end

Then('the expense should belong to the {string} category') do |category_name|
  expect(@expense["category_id"]).to eq(@category.id)
end

# sad path test
Given('I enter the expense details:') do |table|
  details = table.rows_hash

  @expense_prompt = ExpenseFakePrompt.new(
    details["Description"],
    details["Price"],
    details["Category"]
  )
end

When('I try to create the expense with empty category') do
 @output = capture_stdout do 
    @expense = create_expense(@account.id, @expense_prompt) 
    end 
end

Then('the expense should not be created') do
  expect(@expense).to be_nil
end

#test for view all expenses
Given('the account has an expense with description {string}, price {string}, and category {string}') do |description, price, category_name|
  category = Category.find_or_create_by!(name: category_name)

  Expense.create!(
    account: @account,
    description: description,
    price: price,
    category: category,
    date: Date.current
  )
end

When('I view all expenses') do
  @output = capture_stdout do
    view_expenses(@account.id)
  end
end

Then('I should see {string}') do |text|
  expect(@output).to include(text)
end



