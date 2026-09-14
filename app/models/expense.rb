class Expense < ApplicationRecord
  belongs_to :account
  belongs_to :category

  # US-5. belongs_to is required by default in Rails 5+, so a missing account or
  # category already fails with "must exist"; these cover the free-text fields.
  # An expense of zero is not a purchase, and a negative one would quietly
  # subtract from every total that includes it.
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  # US-1: the date is the one field a user is likely to skip, and "today" is
  # almost always what they mean. Done as a callback rather than a column
  # default so it also applies when the field is submitted blank, not only when
  # the attribute is never set.
  before_validation :default_date_to_today

  # Newest first: the expense a user just recorded should be the one they see.
  scope :recent_first, -> { order(date: :desc, created_at: :desc) }

  # US-3. Filters are scopes so they compose: a scope whose body returns nil is
  # a no-op, so a blank filter drops out and the remaining ones still chain.
  # The alternative - stacking `if` blocks in the controller - needs a branch
  # per combination and cannot be unit-tested without a request.
  scope :for_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :for_account, ->(account_id) { where(account_id: account_id) if account_id.present? }

  # Accepts "YYYY-MM". An unparseable value filters nothing rather than raising,
  # so a hand-edited URL cannot produce a 500.
  scope :in_month, lambda { |month|
    next if month.blank?

    start = begin
      Date.strptime(month.to_s, "%Y-%m")
    rescue Date::Error
      next
    end

    where(date: start.beginning_of_month..start.end_of_month)
  }

  # US-2. Defined on the relation so it totals whatever is currently selected:
  # Expense.total, Expense.for_category(3).total, and category.expenses.total
  # all work without a separate code path. Summed in the database, and 0 rather
  # than nil when nothing matches.
  def self.total
    sum(:price)
  end

  private

    def default_date_to_today
      self.date ||= Date.current
    end
end
