require_relative "../../bin/cli_package/definitions"
require_relative "../support/fake_prompt"
Given("an account named {string} exists") do |name|
  @account = Account.find_or_create_by!(name: name)
end

When("I select the {string} account") do |account_name|
  @prompt = FakePrompt.new([ account_name ])

  @selected_account = select_account(@prompt)
end

Then("the selected account should be {string}") do |expected_name|
  expect(@selected_account["name"]).to eq(expected_name)
end

When("I create an account named {string}") do |account_name|
    @prompt = FakePrompt.new([ account_name ])

    @created_account = create_account(@prompt)
end

Then("the created account should be named {string}") do |expected_name|
    expect(@created_account["name"]).to eq(expected_name)
end
