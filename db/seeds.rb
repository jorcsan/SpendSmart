# Seeds the records the app needs to be usable, plus a body of realistic demo
# data for manual and CLI testing.
#
#   bin/rails db:seed                      baseline + demo data (if empty)
#   SEED_EXPENSES=500 bin/rails db:seed    a specific volume of demo data
#   FORCE_SEED=1 bin/rails db:seed         add another batch to a populated db
#   SEED_RANDOM=1 bin/rails db:seed        different data each run
#
# The baseline is idempotent, so `db:seed` is always safe to re-run. The demo
# data is not generated again on a database that already has expenses, because
# repeated runs would otherwise pile up and make totals meaningless.
#
# There is no sign-in yet, so the primary account is implicit. See docs/design.md.

# Same data on every machine unless asked otherwise: a bug someone hits while
# testing should be reproducible by the other person. Both generators have to be
# seeded - Faker has its own RNG, while Array#sample uses Ruby's global one, and
# seeding only Faker leaves the category and account choices varying per run.
unless ENV["SEED_RANDOM"]
  SEED_VALUE = 20_260_924
  Faker::Config.random = Random.new(SEED_VALUE)
  srand(SEED_VALUE)
end

DEFAULT_ACCOUNT_NAME = "My Account".freeze

# Each category carries the generator that produces a plausible description for
# it, so a Dining expense reads like a restaurant and a Transport one does not.
CATEGORY_SOURCES = {
  "Groceries" => -> { "#{Faker::Company.name} grocery run" },
  "Rent" => -> { "#{Faker::Address.community} monthly rent" },
  "Transport" => -> { [ "Bus pass", "Fuel", "Rideshare", "Parking", "Train ticket" ].sample },
  "Dining" => -> { "Dinner at #{Faker::Restaurant.name}" },
  "Utilities" => -> { "#{[ 'Electricity', 'Water', 'Internet', 'Gas' ].sample} bill" },
  "Other" => -> { Faker::Commerce.product_name }
}.freeze

# Realistic ranges, so totals and budget warnings look like real spending
# rather than uniform noise.
PRICE_RANGES = {
  "Groceries" => 15.00..190.00,
  "Rent" => 900.00..1850.00,
  "Transport" => 2.50..85.00,
  "Dining" => 8.00..120.00,
  "Utilities" => 35.00..240.00,
  "Other" => 5.00..300.00
}.freeze

EXTRA_ACCOUNTS = 2
MONTHS_OF_HISTORY = 6
DEFAULT_EXPENSE_COUNT = 150

def money(range)
  # Rounded to cents: price is a decimal column and a seeded value with more
  # precision than that would not survive a round trip.
  Faker::Number.between(from: range.first, to: range.last).round(2)
end

# --- Baseline -------------------------------------------------------------

primary = Account.find_or_create_by!(name: DEFAULT_ACCOUNT_NAME)

categories = CATEGORY_SOURCES.keys.index_with do |name|
  Category.find_or_create_by!(name: name)
end

puts "Baseline: account #{primary.name.inspect}, #{categories.size} categories."

# --- Demo data ------------------------------------------------------------

if Expense.exists? && !ENV["FORCE_SEED"]
  puts "Demo data skipped: #{Expense.count} expenses already exist."
  puts "Use FORCE_SEED=1 to add more, or bin/rails db:reset to start clean."
  return
end

accounts = [ primary ]
EXTRA_ACCOUNTS.times do
  accounts << Account.find_or_create_by!(name: "#{Faker::Name.first_name}'s Account")
end

expense_count = Integer(ENV.fetch("SEED_EXPENSES", DEFAULT_EXPENSE_COUNT))
earliest = MONTHS_OF_HISTORY.months.ago.to_date

# Weighted so the spread looks like real spending: a lot of small everyday
# purchases, and rent only about once a month.
weighted_categories =
  ([ "Groceries" ] * 8) + ([ "Dining" ] * 7) + ([ "Transport" ] * 6) +
  ([ "Other" ] * 4) + ([ "Utilities" ] * 3) + [ "Rent" ]

created = Expense.transaction do
  Array.new(expense_count) do
    category_name = weighted_categories.sample
    category = categories.fetch(category_name)

    Expense.create!(
      account: accounts.sample,
      category: category,
      description: CATEGORY_SOURCES.fetch(category_name).call,
      price: money(PRICE_RANGES.fetch(category_name)),
      date: Faker::Date.between(from: earliest, to: Date.current)
    )
  end
end

# --- Budgets --------------------------------------------------------------
# Deliberately mixed, so the over-budget warning can be seen without having to
# arrange the data by hand: one comfortably under, one already blown, and an
# overall limit for the whole account.

groceries_spent = primary.expenses.for_category(categories["Groceries"].id).total
dining_spent = primary.expenses.for_category(categories["Dining"].id).total

Budget.find_or_create_by!(account: primary, category: categories["Groceries"]) do |budget|
  budget.max_amount = (groceries_spent * 1.4).ceil            # under its limit
end

Budget.find_or_create_by!(account: primary, category: categories["Dining"]) do |budget|
  budget.max_amount = [ (dining_spent * 0.6).floor, 1 ].max   # already exceeded
end

Budget.find_or_create_by!(account: primary, category: nil) do |budget|
  budget.max_amount = (primary.expenses.total * 0.9).ceil     # overall, exceeded
end

# --- Summary --------------------------------------------------------------

puts "Created #{created.size} expenses across #{accounts.size} accounts, #{earliest} to #{Date.current}."
# Rounded for display: price is a decimal column, but SQLite stores it with
# REAL affinity, so SUM() is a float sum and can come back as 6817.099999999999.
puts "Primary account #{primary.name.inspect}: #{primary.expenses.count} expenses totalling $#{primary.expenses.total.round(2)}."
puts "Budgets:"
Budget.for_account(primary.id).each do |budget|
  state = budget.exceeded? ? "OVER by $#{(budget.spent - budget.max_amount).round(2)}" : "ok, $#{budget.remaining.round(2)} left"
  puts "  #{budget.label.ljust(12)} limit $#{budget.max_amount}  spent $#{budget.spent.round(2)}  (#{state})"
end
