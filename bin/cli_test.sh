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

# Stop the Rails server that this script started
echo "Stopping Rails server..."

if [ -f tmp/pids/server.pid ]; then
  kill "$(cat tmp/pids/server.pid)" 2>/dev/null
  rm -f tmp/pids/server.pid
fi

echo "CLI test complete"