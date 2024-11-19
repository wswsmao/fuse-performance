#!/bin/bash
# generate_large_files.sh
# This script generates a specified number of large files with random content.

NUM_FILES=5
FILE_SIZE_MB=100
OUTPUT_DIR="large_files"

mkdir -p $OUTPUT_DIR

for i in $(seq 1 $NUM_FILES); do
    dd if=/dev/urandom of=$OUTPUT_DIR/large_file_$i bs=1M count=$FILE_SIZE_MB
done

echo "Generated $NUM_FILES large files of size $FILE_SIZE_MB MB each in $OUTPUT_DIR."
