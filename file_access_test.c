// file_access_test.c
// This program tests different file access patterns on large files and records the time taken for read operations.

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/time.h>
#include <string.h>

#define SEED_VALUE 42

// Function to wait for a specified amount of time
void wait_before_run(int wait_time) {
    for (int i = wait_time; i > 0; i--) {
        printf("Running in %d seconds...\n", i);
        sleep(1);
    }
}

// Static function to calculate the next offset using LCG
static off_t calculate_next_offset(off_t current_offset, off_t file_size) {
    const off_t a = 1103515245; // Multiplier
    const off_t c = 12345;      // Increment
    const off_t m = file_size;  // Modulus

    return (a * current_offset + c) % m;
}

void measure_read_time(const char *filename, int sequential, size_t buffer_size, int use_odirect) {
    int flags = O_RDONLY;
    if (use_odirect) {
        flags |= O_DIRECT;
    }

    int fd = open(filename, flags);
    if (fd < 0) {
        perror("Failed to open file");
        return;
    }

    void *buffer;
    if (posix_memalign(&buffer, buffer_size, buffer_size) != 0) {
        perror("posix_memalign");
        close(fd);
        return;
    }
    ssize_t bytes_read;
    struct timeval start, end;
    double elapsed_time;
    int read_count = 0;

    if (posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) != 0) {
        perror("Failed to set posix_fadvise");
        close(fd);
        return;
    }

    gettimeofday(&start, NULL);

    if (sequential) {
        // Sequential read
        while ((bytes_read = read(fd, buffer, buffer_size)) > 0) {
            read_count++;
        }
    } else {
        // Simulate random read using a deterministic algorithm
        off_t file_size = lseek(fd, 0, SEEK_END);
        off_t offset = 0;

        for (off_t i = 0; i < file_size / buffer_size; i++) {
            offset = calculate_next_offset(offset, file_size);
            lseek(fd, offset, SEEK_SET);
            read(fd, buffer, buffer_size);
            read_count++;
        }
    }

    gettimeofday(&end, NULL);
    elapsed_time = (end.tv_sec - start.tv_sec) * 1000.0;
    elapsed_time += (end.tv_usec - start.tv_usec) / 1000.0;

    printf("File: %s, Mode: %s, Time: %.2f ms, Read Calls: %d\n", filename, sequential ? "sequential" : "random", elapsed_time, read_count);

    free(buffer);
    close(fd);
}

int main(int argc, char *argv[]) {
    if (argc < 6) {
        fprintf(stderr, "Usage: %s <filename> <sequential|random> <wait_time> <buffer_size> <use_odirect>\n", argv[0]);
        return EXIT_FAILURE;
    }

    int sequential = (strcmp(argv[2], "sequential") == 0);
    int wait_time = atoi(argv[3]);
    size_t buffer_size = (size_t)atoi(argv[4]);
    int use_odirect = atoi(argv[5]);

    wait_before_run(wait_time);

    measure_read_time(argv[1], sequential, buffer_size, use_odirect);

    return EXIT_SUCCESS;
}
