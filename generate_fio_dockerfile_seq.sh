#!/bin/bash

# 检查参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <fio_file_path>"
    exit 1
fi

FIO_FILE=$1

# 检查文件是否存在
if [ ! -f "$FIO_FILE" ]; then
    echo "Error: File $FIO_FILE not found!"
    exit 1
fi

rm -f fio_test.fio

# 获取文件大小（字节）
FILE_SIZE_BYTES=$(stat -c %s "$FIO_FILE")

# 转换文件大小为fio可识别的格式
if [ $FILE_SIZE_BYTES -ge 1073741824 ]; then
    FILE_SIZE="$((FILE_SIZE_BYTES / 1073741824))G"
elif [ $FILE_SIZE_BYTES -ge 1048576 ]; then
    FILE_SIZE="$((FILE_SIZE_BYTES / 1048576))M"
elif [ $FILE_SIZE_BYTES -ge 1024 ]; then
    FILE_SIZE="$((FILE_SIZE_BYTES / 1024))K"
else
    FILE_SIZE="${FILE_SIZE_BYTES}"
fi

# 生成Dockerfile
cat << EOF > Dockerfile
FROM abushwang/ocs9:org

WORKDIR /app

RUN dnf install -y fio

COPY $FIO_FILE /app/test_file

COPY fio_test.fio /app/fio_test.fio

CMD fio fio_test.fio
EOF

# 生成fio测试文件
cat << EOF > fio_test.fio
[global]
filename=/app/test_file
size=$FILE_SIZE
direct=1
ioengine=libaio
iodepth=1
rw=read
numjobs=1

[seq-read-4k]
bs=4k

[seq-read-8k]
bs=8k

[seq-read-16k]
bs=16k

[seq-read-32k]
bs=32k

[seq-read-64k]
bs=64k

[seq-read-128k]
bs=128k

[seq-read-256k]
bs=256k

[seq-read-512k]
bs=512k

[seq-read-1m]
bs=1m

[seq-read-2m]
bs=2m

[seq-read-4m]
bs=4m

[seq-read-8m]
bs=8m

[seq-read-16m]
bs=16m

[seq-read-32m]
bs=32m

[seq-read-64m]
bs=64m

[seq-read-128m]
bs=128m

[seq-read-256m]
bs=256m
EOF

echo "Dockerfile and fio test file have been generated."
echo "You can now build and run the Docker image to perform the FIO test."
