#!/bin/bash

# Function to print usage
print_usage() {
    echo "Usage: $0 <file_count> [-v]"
    echo "  <file_count>: Number of small files to generate"
    echo "  -v: Optional. If set, generates files with varying sizes (1KB to 16KB)"
    echo "      Without -v, all files will be 4KB"
}

# Check if file count parameter is provided
if [ $# -eq 0 ]; then
    print_usage
    exit 1
fi

# Get the number of small files
file_count=$1
shift

# Default file size
file_size="4K"
size_range="4k"
varying_size=false

# Check for -v option
while getopts ":v" opt; do
    case ${opt} in
        v )
            varying_size=true
            size_range="1k-16k"
            ;;
        \? )
            print_usage
            exit 1
            ;;
    esac
done

rm -rf fio_lit_test.fio Dockerfile small_files

# Create directory for small files
mkdir -p small_files

# Generate small files
for i in $(seq 1 $file_count); do
    if $varying_size; then
        # Random file size between 1KB and 16KB
        size=$((RANDOM % 16 + 1))
        dd if=/dev/urandom of=small_files/file_$i bs=1K count=$size 2>/dev/null
    else
        # Fixed 4KB file size
        dd if=/dev/urandom of=small_files/file_$i bs=4K count=1 2>/dev/null
    fi
done

# Generate Dockerfile
cat > Dockerfile << EOF
FROM abushwang/ocs9:org

WORKDIR /app

RUN dnf install -y fio

COPY small_files /app/small_files
COPY fio_lit_test.fio /app/fio_lit_test.fio

CMD ["fio", "fio_lit_test.fio"]
EOF

# Generate fio_lit_test.fio file
cat > fio_lit_test.fio << EOF
[global]
name=small_files_read_test
directory=/app/small_files
rw=randread
bs=4k
filesize=$size_range
nrfiles=$file_count
ioengine=libaio
iodepth=1
direct=1
numjobs=1
openfiles=1000

[job1]
EOF

echo "Generated Dockerfile, fio_lit_test.fio file, and small_files directory with $file_count files"
if $varying_size; then
    echo "Files have varying sizes between 1KB and 16KB"
else
    echo "All files are 4KB in size"
fi
echo "You can build and run the container using the following commands:"
echo "docker build -t small_files_test ."
echo "docker run small_files_test"
