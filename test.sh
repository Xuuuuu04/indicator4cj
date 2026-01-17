#!/bin/bash
# Indicator4CJ Test Runner
# This script ensures tests run in a clean environment

# Set terminal width to avoid IllegalArgumentException
export COLUMNS=120

# Set terminal type
export TERM=xterm-256color

# Change to script directory
cd "$(dirname "$0")"

echo "========================================"
echo "Running Indicator4CJ Test Suite"
echo "========================================"
echo ""

# Run tests
cjpm test

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "All tests passed successfully!"
    echo "========================================"
    exit 0
else
    echo ""
    echo "========================================"
    echo "Tests failed with exit code: $?"
    echo "========================================"
    exit $?
fi
