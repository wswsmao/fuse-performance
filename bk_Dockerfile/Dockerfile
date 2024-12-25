FROM abushwang/ocs9:org

WORKDIR /app

COPY file_access_test /app/
COPY large_files /app/large_files
COPY run_contain_tests.sh /app/

# delay random test.
# it need large files, which will cost long time
RUN rm -rf /app/large_files/random

RUN chmod +x /app/run_contain_tests.sh

CMD ["bash", "/app/run_contain_tests.sh"]
