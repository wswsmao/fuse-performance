#!/bin/bash
# run_tests.sh
# This script runs file access tests on all generated large files and collects the results.

OUTPUT_DIR="large_files"
TEST_PROGRAM="./file_access_test"
REPORT_FILE="performance_report.txt"
WAIT_TIME=0
BUFFER_SIZE=4096
ODIRECT=0

echo "Running file access tests..."
echo "Sequential Read Performance Report" > $REPORT_FILE
echo "=================================" >> $REPORT_FILE
printf "%-20s %-20s %-20s %-20s\n" "File" "Size (MB)" "Read Calls" "Time (ms)" >> $REPORT_FILE
printf "%-20s %-20s %-20s %-20s\n" "----" "--------" "----------" "--------" >> $REPORT_FILE

for file in $OUTPUT_DIR/sequential/sequential_file_*; do
    echo "Testing file: $file"
    FILE_SIZE=$(ls -lh $file | awk '{print $5}' | sed 's/[A-Za-z]*//g')
    SEQ_RESULT=$($TEST_PROGRAM $file sequential $WAIT_TIME $BUFFER_SIZE $ODIRECT)

    SEQ_TIME=$(echo $SEQ_RESULT | awk '{print $6}')
    SEQ_CALLS=$(echo $SEQ_RESULT | awk '{print $10}')

    printf "%-20s %-20s %-20s %-20s\n" "$(basename $file)" "$FILE_SIZE" "$SEQ_CALLS" "$SEQ_TIME" >> $REPORT_FILE
done

echo "" >> $REPORT_FILE
# echo "Random Read Performance Report" >> $REPORT_FILE
# echo "==============================" >> $REPORT_FILE
# printf "%-20s %-20s %-20s %-20s\n" "File" "Size (MB)" "Read Calls" "Time (ms)" >> $REPORT_FILE
# printf "%-20s %-20s %-20s %-20s\n" "----" "--------" "----------" "--------" >> $REPORT_FILE
# 
# for file in $OUTPUT_DIR/random/random_file_*; do
#     echo "Testing file: $file"
#     FILE_SIZE=$(ls -lh $file | awk '{print $5}' | sed 's/[A-Za-z]*//g')
#     RAND_RESULT=$($TEST_PROGRAM $file random $WAIT_TIME $BUFFER_SIZE $ODIRECT)
# 
#     RAND_TIME=$(echo $RAND_RESULT | awk '{print $6}')
#     RAND_CALLS=$(echo $RAND_RESULT | awk '{print $10}')
# 
#     printf "%-20s %-20s %-20s %-20s\n" "$(basename $file)" "$FILE_SIZE" "$RAND_CALLS" "$RAND_TIME" >> $REPORT_FILE
# done

echo ""
cat $REPORT_FILE
echo ""
echo "Tests completed. See $REPORT_FILE for details."
