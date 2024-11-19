FROM abushwang/ocs9:org

WORKDIR /app

COPY file_access_test /app/
COPY large_files /app/large_files
COPY run_tests.sh /app/

RUN chmod +x /app/run_tests.sh

CMD ["bash", "/app/run_tests.sh"]
