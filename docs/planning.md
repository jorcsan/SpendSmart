# SpendSmart

## App Description

SpendSmart is an expense-tracking application that stores each expense's price, description, category, and date. Users can create accounts where their expenses are stored and can view and filter their expenses in different ways.

---

## Essential Features

- Create and store a new expense with a price, description, category, and date.
- Automatically categorize expenses based on the category assigned when the expense is created.
- View expenses and filter the list by category.
- Edit the details of an existing expense.
- Delete an existing expense.
- Organize and view expenses by a specific timeframe, such as by month.
- Set a budget for a specific category or overall spending.
- Alert the user when a new expense causes spending to reach or exceed the budget.

---

## Optional Features

- Organize expenses by smaller timeframes, such as:
  - Day
  - Week

---

## Main Classes / Modules

### Expense
Represents a single expense.

**Attributes:**
- Price
- Description
- Category
- Date

### Account
Represents a user's account and owns their collection of expenses.

### Category
Represents an expense category and groups expenses for filtering and organization.

### Budget
Tracks a spending limit and checks new expenses against the budget to trigger alerts.

---

## Test Cases

### Create and Store a New Expense

- Start with no expenses.
- Add one expense.
- Search for the expense.
- Expect the expense to be found.

### Account Creation

- Create an account named `savings`.
- Enter `savings` as the account.
- Expect the `savings` account to exist.

### Duplicate Account Creation

- Create an account named `savings`.
- Try to create another account named `savings`.
- Expect an error because account names must be unique.

### Categorize Expenses

- Start with no expenses.
- Add two expenses with the same category.
- Filter by that category.
- Expect both expenses to appear and no expenses from other categories.

### View / Filter Expenses

- Start with expenses in multiple categories.
- Apply a category filter.
- Expect only expenses matching that category to be displayed.

### View / Filter Expenses by Month

**Scenario 1: Expenses exist**

- Create two expenses in September.
- Filter by September.
- Expect both expenses to be displayed.

**Scenario 2: No expenses exist**

- Filter by October when there are no October expenses.
- Expect a message saying:

> No expenses this month.

### Edit an Expense

- Start with one expense at price **X**.
- Edit the expense and change the price to **Y**.
- View the expense.
- Expect the displayed price to be **Y**.

### Delete an Expense

- Start with one expense.
- Delete the expense.
- Search for the expense.
- Expect the expense to not be found.

---

## Team Collaboration

The team will mostly program individually because of conflicting schedules.

We will attempt to pair program when possible.

---

## Definition of Done

The project will be considered complete when:

- All essential features are implemented correctly and tested thoroughly.
- The CLI interface is functioning correctly.
- The CLI interface meets our aesthetic standards.
- The CLI interface is intuitive for the user.
- Documentation is completed.
- Sufficient instructions are provided for the grader to use the application without difficulty.
