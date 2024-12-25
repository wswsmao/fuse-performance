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

[seq-read-small]
rw=read
bs=4k
numjobs=1

[seq-read-medium]
rw=read
bs=64k
numjobs=1

[seq-read-large]
rw=read
bs=1M
numjobs=1

[rand-read-small]
rw=randread
bs=4k
numjobs=1

[rand-read-medium]
rw=randread
bs=64k
numjobs=1

[rand-read-large]
rw=randread
bs=1M
numjobs=1
EOF

echo "Dockerfile and fio test file have been generated."
echo "You can now build and run the Docker image to perform the FIO test."
