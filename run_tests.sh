#!/bin/bash
# run_tests.sh
# This script runs file access tests on all generated large files and collects the results.

OUTPUT_DIR="large_files"
TEST_PROGRAM="./file_access_test"

echo "Running file access tests..."

for file in $OUTPUT_DIR/*; do
    echo "Testing file: $file"
    $TEST_PROGRAM $file sequential
    $TEST_PROGRAM $file random
done

echo "Tests completed."
