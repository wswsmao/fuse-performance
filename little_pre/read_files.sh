#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory=$1
total_time=0
file_count=0

for file in "$directory"/*; do
    if [ -f "$file" ]; then
        elapsed_us=$(./direct_read "$file")
        echo "File: $file, Time: $elapsed_us microseconds"
        total_time=$((total_time + elapsed_us))
        file_count=$((file_count + 1))
    fi
done

average_time=$(echo "scale=2; $total_time / $file_count" | bc)

echo "Total files processed: $file_count"
echo "Total time: $total_time microseconds"
echo "Average time per file: $average_time microseconds"
