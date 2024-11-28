#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <test_tool> <directory>"
    exit 1
fi

TEST_TOOL="$1"
TEST_DIR=$2

if [ ! -d "$TEST_DIR" ]; then
    echo "Directory $TEST_DIR does not exist."
    exit 1
fi

BUFFER_SIZES=(4096 131072 262144)
MODES=("sequential" "random")
USE_ODIRECT=(0 1)

RESULT_FILE="test_results.txt"
echo "Filename,Size,Mode,Buffer Size,Use O_DIRECT,Time (ms),Read Calls" > $RESULT_FILE

for FILE in "$TEST_DIR"/*; do
    if [ -f "$FILE" ]; then
        FILE_SIZE=$(ls -lh "$FILE" | awk '{print $5}')
        echo "Testing file: $FILE (Size: $FILE_SIZE bytes)"

        for MODE in "${MODES[@]}"; do
            for BUFFER_SIZE in "${BUFFER_SIZES[@]}"; do
                for O_DIRECT in "${USE_ODIRECT[@]}"; do
                    echo 3 > /proc/sys/vm/drop_caches
                    sleep 1

                    OUTPUT=$("$TEST_TOOL" "$FILE" "$MODE" 0 "$BUFFER_SIZE" "$O_DIRECT")

                    TIME=$(echo "$OUTPUT" | grep "Time:" | awk '{print $6}')
                    READ_CALLS=$(echo "$OUTPUT" | grep "Read Calls:" | awk '{print $10}')
                    echo "$FILE,$FILE_SIZE,$MODE,$BUFFER_SIZE,$O_DIRECT,$TIME,$READ_CALLS" >> $RESULT_FILE
                done
            done
        done
    fi
done

echo "Test Results:"
column -s, -t < $RESULT_FILE
