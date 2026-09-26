require "stringio"
require_relative "../../bin/cli_package/definitions"

class MonthFakePrompt
  def initialize(month)
    @month = month
  end

  def ask(_message)
    @month
  end
end

# steps definition for filter by month

When('I view expenses for month {string}') do |month|
  prompt = MonthFakePrompt.new(month)

  @output = capture_stdout do
    @month_expenses = filter_date(@account.id, prompt)
  end
end

Then('I should see the expense dated {string}') do |date|
  expect(@output).to include("Test Expense #{date}")
end

Then('I should not see the expense dated {string}') do |date|
  expect(@output).not_to include("Test Expense #{date}")
end
