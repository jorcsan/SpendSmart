Feature: Account management

  Scenario: Select an existing account
    Given an account named "Checking" exists
    When I select the "Checking" account
    Then the selected account should be "Checking"