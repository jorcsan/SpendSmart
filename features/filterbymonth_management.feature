Feature: filter by month management
    Given an account named "Checking" exists
    And the "Checking" account has an expense dated "2026-09-20"
    And the "Checking" account has an expense dated "2026-08-20"
    When I view expenses for month "09-2026"
    Then I should see the expense dated "2026-09-20"
    And I should not see the expense dated "2026-08-20"

