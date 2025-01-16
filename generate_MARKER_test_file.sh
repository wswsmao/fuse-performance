#!/bin/bash

# 函数：将大小转换为字节
convert_to_bytes() {
    local size=$1
    local unit=${size: -1}
    local number=${size%[KM]}
    
    case $unit in
        K|k) echo $((number * 1024)) ;;
        M|m) echo $((number * 1024 * 1024)) ;;
        *) echo $size ;;
    esac
}

# 检查参数
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file_name> <file_size>"
    echo "Example: $0 test_file.bin 80K"
    exit 1
fi

# 设置文件名和大小
FILE_NAME=$1
FILE_SIZE=$(convert_to_bytes $2)

# 创建一个函数来生成随机字节
generate_random_bytes() {
    dd if=/dev/urandom bs=1 count=$1 2>/dev/null
}

# 创建一个函数来生成可grep的标记
generate_marker() {
    echo -n "MARKER_$(date +%s%N | md5sum | head -c 10)"
}

# 创建文件
: > "$FILE_NAME"

# 生成标记
MARKER=$(generate_marker)

# 计算每个块的大小（假设我们要插入标记的次数为文件大小的平方根）
MARKER_COUNT=$(echo "sqrt($FILE_SIZE/1024)" | bc)
BLOCK_SIZE=$((FILE_SIZE / MARKER_COUNT))

# 生成文件内容
for ((i=1; i<=MARKER_COUNT; i++))
do
    # 生成随机数据
    generate_random_bytes $((BLOCK_SIZE - ${#MARKER})) >> "$FILE_NAME"
    
    # 插入标记
    echo -n "$MARKER" >> "$FILE_NAME"
done

# 确保文件大小正确
CURRENT_SIZE=$(wc -c < "$FILE_NAME")
if [ "$CURRENT_SIZE" -lt "$FILE_SIZE" ]; then
    generate_random_bytes $((FILE_SIZE - CURRENT_SIZE)) >> "$FILE_NAME"
elif [ "$CURRENT_SIZE" -gt "$FILE_SIZE" ]; then
    truncate -s $FILE_SIZE "$FILE_NAME"
fi

echo "File generated: $FILE_NAME"
echo "File size: $(wc -c < "$FILE_NAME") bytes"
echo "Marker used: $MARKER"
echo "Marker count: $MARKER_COUNT"
echo "Compression ratio test:"
echo "Original size: $(wc -c < "$FILE_NAME") bytes"
# echo "Gzip size: $(gzip -c "$FILE_NAME" | wc -c) bytes"
# echo "Bzip2 size: $(bzip2 -c "$FILE_NAME" | wc -c) bytes"
echo "You can use 'grep $MARKER $FILE_NAME' to find the markers"
