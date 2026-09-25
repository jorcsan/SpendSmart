Feature: Expense management

Feature: Expense management

  Scenario: Create an expense for a specific account
    Given an account named "Checking" exists
    And a category named "Grocery" exists
    When I create an expense for "Checking" with description "Walmart" price "20" and category "Grocery"
    Then the expense should have description "Walmart"
    And the expense should have price "20"
    And the expense should belong to the "Checking" account
    And the expense should belong to the "Grocery" category

  Scenario: Fail to create an expense without entering a category string
    Given an account named "Checking" exists
    And I enter the expense details:
    | Description | Walmart groceries |
    | Price       | 20.00             |
    | Category    |            |
    When I try to create the expense with empty category
    Then the expense should not be created
    And I should see "Category cannot be empty."

  Scenario: View all expenses in the Account
    Given an account named "Checking" exists
    And the account has an expense "Old Purchase" dated "2026-09-20"
    And the account has an expense "New Purchase" dated "2026-09-24"
    When I select the account "Checking"
    And I choose "View All Expenses"
    Then I should see all expenses, and the most recent should be first


  Scenario: View expenses by category
    Given the "Checking" account has an expense in category "Food"
    When I view expenses by category "Food"
    Then I should see the "Food" expense

  Scenario: View expenses by month
    Given the "Checking" account has an expense in September 2026
    When I view expenses for September 2026
    Then I should see the September expense
