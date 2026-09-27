# User Stories

## 1. Create an Expense

**As a user, I want to be able to save an expense with a name, price, and category to a specific account.**

- The user must create a new account or select an existing one.
- The user must enter a description, price, and category.
___

## 2. Handle Invalid Expense Input

**As a user, I want to receive an error message when I enter invalid expense information so that I know what needs to be corrected.**

### Acceptance Criteria

- The user cannot create an expense without entering a category.
- The cli displays an appropriate error message when the category is empty.
- The invalid expense is not saved to the account.
___

## 3. Filter by Category

**As a user, I want to be able to filter my expenses by category.**

### Acceptance Criteria

- The user must select an existing account or create a new one
- the user can select to filter by category
- user must select which category to use
___

## 4. Budget Message

**As a user, I want to be able to see the budget in a message across the application.**

### Acceptance Criteria

- The user must select an existing account or create a new one
- the user must select to create a budget
- user must add an expense to an account that makes the total exceed the budget
___

## 5. Edit or Delete Expense

**As a user, I want to be able to edit and delete expenses from the CLI.**

### Acceptance Criteria

- The user must select an existing account or create a new one
- the user must select to edit or delete an expense
- user must select the account they wish to edit or delete
- if edit, user must enter new valid information
___

## 6. Filter By Month

**As a user, I want to be able to filter my expenses by the month they were made in.**

### Acceptance Criteria

- The user must select an existing account or create a new one
- the user must select filter by month
- user must enter the month and year of the expenses they want to view
  
___

## 7. View total

**As a spender, I want to be able to view the total of all my expenses.**

### Acceptance Criteria

- The user must select an existing account or create a new one
- the user must select to view all expenses
- total will be shown at the bottom
___
