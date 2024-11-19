#!/bin/bash
# generate_large_files.sh
# This script generates large files with random content of varying sizes.

OUTPUT_DIR="large_files"
FILE_SIZES_MB=(50 100 200 300 500)  # Different file sizes in MB

mkdir -p $OUTPUT_DIR

for i in "${!FILE_SIZES_MB[@]}"; do
    FILE_SIZE_MB=${FILE_SIZES_MB[$i]}
    dd if=/dev/urandom of=$OUTPUT_DIR/large_file_$((i+1)) bs=1M count=$FILE_SIZE_MB
done

echo "Generated large files of varying sizes in $OUTPUT_DIR."