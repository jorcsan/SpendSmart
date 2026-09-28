require "stringio"
require_relative "../../bin/cli_package/definitions"

class CategoryFilterFakePrompt
  def initialize(category)
    @category = category
  end

  def select(_message, _choices)
    @category
  end
end

Given('the {string} account has an expense in category {string}') do |account_name, category_name|
  @account = Account.find_by!(name: account_name)

  category = Category.where("LOWER(name) = ?", category_name.downcase).first

  unless category
    category = Category.create!(name: category_name)
  end

  Expense.create!(
    account_id: @account.id,
    description: "#{category_name} Expense",
    price: 20.00,
    category_id: category.id,
    date: Date.today
  )
end

When('I view expenses by category {string}') do |category|
  prompt = CategoryFilterFakePrompt.new(category)

  @output = capture_stdout do
    filter_by_category(@account.id, prompt)
  end
end

Then('I should see the {string} expense') do |category|
  expect(@output).to include("#{category} Expense")
end

Then('I should not see the {string} expense') do |category|
  expect(@output).not_to include("#{category} Expense")
end