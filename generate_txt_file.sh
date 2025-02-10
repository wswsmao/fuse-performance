#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <output_file> <size_in_MB>"
    exit 1
fi

output_file=$1
size_mb=$2

# Calculate the number of 1MB chunks needed
chunks=$size_mb

# Function to generate 1MB of random alphanumeric content
generate_chunk() {
    < /dev/urandom tr -dc 'a-zA-Z0-9' | head -c 1048576
}

# Generate and write content to file
(
    for ((i=0; i<chunks; i++)); do
        generate_chunk
    done
) > "$output_file"

echo "Generated $size_mb MB file: $output_file"
