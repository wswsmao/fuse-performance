#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <test_tool> <directory>"
    exit 1
fi

TEST_TOOL="$1"
TEST_DIR="$2"

if [ ! -d "$TEST_DIR" ]; then
    echo "Directory $TEST_DIR does not exist."
    exit 1
fi

BUFFER_SIZES=(4096 131072 262144 67108864)
MODES=("sequential" "random")
USE_ODIRECT=(0 1)

RESULT_FILE_NO_DIRECT="test_results_no_direct.txt"
RESULT_FILE_DIRECT="test_results_direct.txt"

echo "Filename,Size,Mode,Buffer Size,Time (ms),Read Calls" > $RESULT_FILE_NO_DIRECT
echo "Filename,Size,Mode,Buffer Size,Time (ms),Read Calls" > $RESULT_FILE_DIRECT

for MODE in "${MODES[@]}"; do
    MODE_DIR="$TEST_DIR/$MODE"
    if [ ! -d "$MODE_DIR" ]; then
        echo "Directory $MODE_DIR does not exist. Skipping $MODE mode."
        continue
    fi

    for FILE in "$MODE_DIR"/*; do
        if [ -f "$FILE" ]; then
            FILE_SIZE=$(ls -lh "$FILE" | awk '{print $5}')
            FILE_NAME=$(basename "$FILE")
            echo "Testing file: $FILE_NAME (Size: $FILE_SIZE bytes)"

            for BUFFER_SIZE in "${BUFFER_SIZES[@]}"; do
                for O_DIRECT in "${USE_ODIRECT[@]}"; do
                    echo 3 > /proc/sys/vm/drop_caches
                    sleep 1

                    OUTPUT=$("$TEST_TOOL" "$FILE" "$MODE" 0 "$BUFFER_SIZE" "$O_DIRECT")

                    TIME=$(echo "$OUTPUT" | grep "Time:" | awk '{print $6}')
                    READ_CALLS=$(echo "$OUTPUT" | grep "Read Calls:" | awk '{print $10}')

                    if [ "$O_DIRECT" -eq 0 ]; then
                        echo "$FILE_NAME,$FILE_SIZE,$MODE,$BUFFER_SIZE,$TIME,$READ_CALLS" >> $RESULT_FILE_NO_DIRECT
                    else
                        echo "$FILE_NAME,$FILE_SIZE,$MODE,$BUFFER_SIZE,$TIME,$READ_CALLS" >> $RESULT_FILE_DIRECT
                    fi
                done
            done
        fi
    done
done

echo "Test Results without O_DIRECT:"
column -s, -t < $RESULT_FILE_NO_DIRECT
echo
echo "Test Results with O_DIRECT:"
column -s, -t < $RESULT_FILE_DIRECT

rm -f $RESULT_FILE_NO_DIRECT $RESULT_FILE_DIRECT
