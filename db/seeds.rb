# Seeds the records the app needs to be usable on a fresh checkout. Idempotent,
# so `bin/rails db:seed` can be re-run safely.
#
# There is no sign-in yet, so every expense belongs to one implicit account.
# See docs/design.md.

DEFAULT_ACCOUNT_NAME = "My Account".freeze
DEFAULT_CATEGORIES = [
  "Groceries",
  "Rent",
  "Transport",
  "Dining",
  "Utilities",
  "Other"
].freeze

account = Account.find_or_create_by!(name: DEFAULT_ACCOUNT_NAME)

DEFAULT_CATEGORIES.each do |name|
  Category.find_or_create_by!(name: name)
end

puts "Seeded account #{account.name.inspect} and #{Category.count} categories."
