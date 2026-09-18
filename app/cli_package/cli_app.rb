require "tty-prompt"
require "net/http"
require "json"
require "uri"
require_relative "definitions"

prompt = TTY::Prompt.new(interrupt: :exit)

# METHOD TO KEEP INSTRUCTIONS FIXED AT THE TOP ---
def draw_header(screen_title)
  print "\e[H\e[2J" # Clears the screen completely
  puts "=================================================="
  puts "            ACCOUNT MANAGEMENT SYSTEM             "
  puts "=================================================="
  puts " Instructions:"
  puts "  • Use [↑/↓] to navigate | [ENTER] to confirm"
  puts "  • Type your text and press [ENTER] when prompted"
  puts "--------------------------------------------------"
  puts " CURRENT PAGE: #{screen_title.upcase}"
  puts "--------------------------------------------------"
  puts ""
end

# User must enter a new account or select an existing one
draw_header("Welcome Screen")

# prompt to ask user to selct account or create new account
action = prompt.select("ACCOUNT:", {
  "Select existing account" => :select_account,
  "Create new account" => :create_account
})

if action == :select_account
  account = select_account
else
  # Ask them to type a brand new name
  account = create_account
  sleep 1 # Quick pause so they see the success message
end

puts "Account ID: #{account["account_id"]}"


# ==================================================
# STEP 3: THE FINAL SELECTION MENU
# ==================================================
draw_header("Dashboard for #{account["name"]}")

final_choices = {
  "Create Expense"     => :create_exp,
  "View  All Expenes" => :view_all,
  "Create a Budget"        => :create_budget,
  "View Expenses by Month"        => :date_filter,
  "View Expenses by Category"        => :category_filter
}

# The user is now locked in this final menu loop
loop do
  draw_header("Dashboard for #{account["account_name"]}")

  selection = prompt.select(" Choose an option:", final_choices)

  case selection
  when :create_exp
    # create an expense for an account
  when :view_all
    # view all of the expenses
  when :create_budget
    # use create_budget route
  when :date_filter
    # show the expenses within a given month
  when :category_filter
    # show the expenses within a given category
  end
end
