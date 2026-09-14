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

  private

    def default_date_to_today
      self.date ||= Date.current
    end
end
