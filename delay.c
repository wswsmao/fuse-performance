// file_access_test.c
// This program tests different file access patterns on large files and records the time taken for read operations.

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/time.h>

#define BUFFER_SIZE 4096
#define SEED_VALUE 42

// Function to wait for a specified amount of time
void wait_before_run(int wait_time) {
    for (int i = wait_time; i > 0; i--) {
        printf("Running in %d seconds...\n", i);
        sleep(1);
    }
}

void measure_read_time(const char *filename, int sequential, size_t file_size_mb) {
    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open file");
        return;
    }

    // 计算要读取的字节数
    size_t total_bytes_to_read = file_size_mb * 1024 * 1024;
    char *data = malloc(total_bytes_to_read);
    if (data == NULL) {
        perror("Failed to allocate memory");
        close(fd);
        return;
    }

    ssize_t bytes_read;
    struct timeval start, end;
    double elapsed_time;
    int read_count = 0;

    if (posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) != 0) {
        perror("Failed to set posix_fadvise");
        free(data);
        close(fd);
        return;
    }

    gettimeofday(&start, NULL);

    if (sequential) {
        // Sequential read
        size_t total_read = 0;
        while (total_read < total_bytes_to_read && (bytes_read = read(fd, data + total_read, BUFFER_SIZE)) > 0) {
            total_read += bytes_read;
            sleep(1);
            read_count++;
        }
    } else {
        off_t file_size = lseek(fd, 0, SEEK_END);
        srand(SEED_VALUE);
        size_t total_read = 0;
        while (total_read < total_bytes_to_read) {
            off_t offset = rand() % file_size;
            lseek(fd, offset, SEEK_SET);
            bytes_read = read(fd, data + total_read, BUFFER_SIZE);
            if (bytes_read <= 0) {
                break; // 读取结束或出错
            }
            total_read += bytes_read;
            read_count++;
        }
    }

    gettimeofday(&end, NULL);
    elapsed_time = (end.tv_sec - start.tv_sec) * 1000.0;
    elapsed_time += (end.tv_usec - start.tv_usec) / 1000.0;

    printf("File: %s, Mode: %s, Time: %.2f ms, Read Calls: %d\n", filename, sequential ? "sequential" : "random", elapsed_time, read_count);

    fwrite(data, 1, total_bytes_to_read, stderr);

    free(data);
    close(fd);
}

int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <filename> <sequential|random> <wait_time> <size_in_mb>\n", argv[0]);
        return EXIT_FAILURE;
    }

    int sequential = (strcmp(argv[2], "sequential") == 0);

    // Parse the wait time from the command line arguments
    int wait_time = atoi(argv[3]);
    size_t file_size_mb = atoi(argv[4]);

    // Wait for the specified amount of time
    wait_before_run(wait_time);

    measure_read_time(argv[1], sequential, file_size_mb);

    return EXIT_SUCCESS;
}
