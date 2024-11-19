#!/bin/bash
# run_tests.sh
# This script runs file access tests on all generated large files and collects the results.

OUTPUT_DIR="large_files"
TEST_PROGRAM="./file_access_test"
REPORT_FILE="performance_report.txt"

echo "Running file access tests..."
echo "Performance Report" > $REPORT_FILE
echo "==================" >> $REPORT_FILE

for file in $OUTPUT_DIR/*; do
    echo "Testing file: $file"
    SEQ_TIME=$($TEST_PROGRAM $file sequential | awk '{print $6}')
    RAND_TIME=$($TEST_PROGRAM $file random | awk '{print $6}')
    echo "File: $(basename $file)" >> $REPORT_FILE
    echo "  Sequential Read Time: $SEQ_TIME ms" >> $REPORT_FILE
    echo "  Random Read Time: $RAND_TIME ms" >> $REPORT_FILE
    echo "--------------------------" >> $REPORT_FILE
done

cat $REPORT_FILE
echo "Tests completed. See $REPORT_FILE for details."