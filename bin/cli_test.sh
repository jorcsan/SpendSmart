#!/bin/bash

# Go to the Rails project root
cd "$(dirname "$0")/.."

# Set the API token used by the CLI and Rails
export SPENDSMART_API_TOKEN="my-secret-token-123"

echo "Starting Rails server for Cucumber..."

# Start Rails in the background
bin/rails server -d

# Give Rails a moment to start
sleep 3

echo "Running Cucumber tests..."
bundle exec cucumber

# Stop the Rails server after the tests finish
echo "Stopping Rails server..."
bin/rails server -d 2>/dev/null
bin/rails runner 'puts "cli test complete"' 2>/dev/null