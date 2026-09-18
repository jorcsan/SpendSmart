#!/bin/bash

# Move to the Rails project root
cd "$(dirname "$0")/../.."


export SPENDSMART_API_TOKEN="my-secret-token-123"

echo "Starting Rails server..."

bin/rails server &
RAILS_PID=$!

echo "Rails PID: $RAILS_PID"
echo "Waiting for Rails..."

# Wait until Rails responds
until curl -s http://localhost:3000/up > /dev/null; do
    # Check whether Rails process is still alive
    if ! kill -0 $RAILS_PID 2>/dev/null; then
        echo "Rails server stopped unexpectedly."
        exit 1
    fi

    sleep 1
done

echo "Rails is ready!"
echo "Starting SpendSmart CLI..."

ruby app/cli_package/cli_app.rb

echo "Stopping Rails server..."
kill $RAILS_PID