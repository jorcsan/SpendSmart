Feature: Account management

  Scenario: Select an existing account
    Given an account named "Checking" exists
    When I select the "Checking" account
    Then the selected account should be "Checking"

  Scenario: Create a new account
    When I create an account named "Savings"
    Then the created account should be named "Savings"