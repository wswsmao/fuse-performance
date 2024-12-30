FROM abushwang/ocs9:org

WORKDIR /app

RUN dnf install -y bc

COPY direct_read /app/
COPY read_files.sh /app/
COPY small_files /app/small_files

CMD ["./read_files.sh", "/app/small_files"]
