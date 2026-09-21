require_relative "../../bin/cli_package/definitions"
require_relative "../support/fake_prompt"
Given("an account named {string} exists") do |name|
  Account.create!(name: name)
end

When("I select the {string} account") do |account_name|
  @prompt = FakePrompt.new([account_name])

  @selected_account = select_account(@prompt)
end

Then("the selected account should be {string}") do |expected_name|
  expect(@selected_account["name"]).to eq(expected_name)
end