require "tty-prompt"

prompt = TTY::Prompt.new(interrupt: :exit)

# --- METHOD TO KEEP INSTRUCTIONS FIXED AT THE TOP ---
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

# ==================================================
# STEP 1: THE FIRST SELECTION MENU
# ==================================================
draw_header("Welcome Screen")

first_choices = {
  "1. Select Existing Account" => :select_account,
  "2. Create New Account"     => :create_account
}

action = prompt.select("ACCOUNT:", first_choices)


#Here, the user will type in the new account name or and existing name
draw_header("Account Setup")

if action == :select_account
  # Ask them to type their existing name
  username = prompt.ask("Enter your existing Account Name:")
else
  # Ask them to type a brand new name
  username = prompt.ask("Type a name for your new account:")
  puts "\nAccount '#{username}' created successfully!"
  sleep 1 # Quick pause so they see the success message
end


# ==================================================
# STEP 3: THE FINAL SELECTION MENU
# ==================================================
draw_header("Dashboard for #{username}")

final_choices = {
  "Create Expense"     => :create_exp,
  "View  All Expenes" => :view_all,
  "Create a Budget"        => :create_budget,
  "View Expenses by Month"        => :date_filter,
  "View Expenses by Category"        => :category_filter
}

# The user is now locked in this final menu loop
loop do
  draw_header("Dashboard for #{username}")
  
  selection = prompt.select("Welcome back, #{username}! Choose an option:", final_choices)
  
  case selection
  when :create_exp
    #create an expense for an account
  when :view_all
    #view all of the expenses
  when :create_budget
    #use create_budget route
  when :date_filter
    #show the expenses within a given month
  when :category_filter
    #show the expenses within a given category
  end
end
