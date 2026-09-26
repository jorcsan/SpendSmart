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




