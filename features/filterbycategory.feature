Feature: Filter by category management

  Scenario: View expenses by category
    Given an account named "Checking" exists
    And the "Checking" account has an expense in category "Grocery"
    And the "Checking" account has an expense in category "Entertainment"
    When I view expenses by category "Grocery"
    Then I should see the "Grocery" expense
    And I should not see the "Entertainment" expense