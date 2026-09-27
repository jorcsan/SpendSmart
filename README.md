# Project 1: SpendSmart

## Description:

SpendSmart is an expense-tracking application app that allows the user to create an account where they can stoe expenses. Each expense consist of price, description, category_id, and account_id. The user can create, view, edit, and delete expenses. expenses can be viewed using the filter by month or filter by category functionality. A budget can be set for a given account so the user will be alrted when the total of the expenses haas exceed the set budget.

We used rails to create our project and we created our api using rails. The command line interface communicates with the rails backend through http requests.

## Installation and Setup Instructions

Install: Ruby, Ruby on Rails, & Bundler

you can clone the repo with this: 
```bash
git clone https://github.com/jorcsan/SpendSmart.git
cd SpendSmart/bank_app
```

Install Dependencies
```bash
bundle install
```

Set up DB
```bash
bin/rails db:create
bin/rails db:migrate
```

Run the app
Run executable file
```bash
./bin/cli_package/start_app.sh
```

Run test

```bash
./bin/rails test
```
```bash
./bin/cli_test.sh
```

Open Coverage
```bash
open coverage/index.html
```

List of Features
1, Creates and stores a new expense with a price, description, category, and date.
2. Automatically categorizes expenses based on the category assigned when the expense is created.
3. View expenses and filter the list by category.
4. Edit the details of an existing expense.
5. Delete an existing expense.
6. Organize and view expenses by a specific timeframe, such as by month.
7. Setting a budget for a specific category or overall spending.
8. Alerts the user when a new expense causes spending to reach or exceed the budget.

Limitations

Team Members: Ivan Reyes and Jorge Santos

