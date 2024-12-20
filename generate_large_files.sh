#!/bin/bash
# generate_large_files.sh
# This script generates large files with random content of varying sizes.

OUTPUT_DIR="large_files"
SEQ_DIR="$OUTPUT_DIR/sequential"
RAND_DIR="$OUTPUT_DIR/random"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <median_size_mb> <number_of_files>"
    exit 1
fi

MEDIAN_SIZE_MB=$1
NUMBER_OF_FILES=$2

# Calculate step size, ensuring at least one step
if [ "$NUMBER_OF_FILES" -le 1 ]; then
    echo "Number of files must be greater than 1"
    exit 1
fi

STEP_SIZE=$((MEDIAN_SIZE_MB / (NUMBER_OF_FILES / 2)))
if [ "$STEP_SIZE" -eq 0 ]; then
    STEP_SIZE=1
fi

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $SEQ_DIR
mkdir -p $RAND_DIR

for ((i = 0; i < NUMBER_OF_FILES; i++)); do
    FILE_SIZE_MB=$((MEDIAN_SIZE_MB + (i - NUMBER_OF_FILES / 2) * STEP_SIZE))
    if [ "$FILE_SIZE_MB" -le 0 ]; then
        FILE_SIZE_MB=1
    fi
    # Generate two files of the same size for sequential and random reads
    dd if=/dev/urandom of=$SEQ_DIR/sequential_file_$((i+1)) bs=1M count=$FILE_SIZE_MB
    dd if=/dev/urandom of=$RAND_DIR/random_file_$((i+1)) bs=1M count=$FILE_SIZE_MB
done

echo "Generated $((NUMBER_OF_FILES * 2)) large files with median size $MEDIAN_SIZE_MB MB in $OUTPUT_DIR."
