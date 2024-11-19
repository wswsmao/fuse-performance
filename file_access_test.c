// file_access_test.c
// This program tests different file access patterns on large files and records the time taken for read operations.

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/time.h>
#include <string.h>

#define BUFFER_SIZE 4096

void measure_read_time(const char *filename, int sequential) {
    int fd = open(filename, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open file");
        return;
    }

    char buffer[BUFFER_SIZE];
    ssize_t bytes_read;
    struct timeval start, end;
    double elapsed_time;

    if (posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) != 0) {
        perror("Failed to set posix_fadvise");
        close(fd);
        return;
    }

    gettimeofday(&start, NULL);

    if (sequential) {
        // Sequential read
        while ((bytes_read = read(fd, buffer, BUFFER_SIZE)) > 0);
    } else {
        // Random read
        off_t file_size = lseek(fd, 0, SEEK_END);
        for (off_t offset = 0; offset < file_size; offset += BUFFER_SIZE) {
            lseek(fd, rand() % file_size, SEEK_SET);
            read(fd, buffer, BUFFER_SIZE);
        }
    }

    gettimeofday(&end, NULL);
    elapsed_time = (end.tv_sec - start.tv_sec) * 1000.0;
    elapsed_time += (end.tv_usec - start.tv_usec) / 1000.0;

    printf("File: %s, Mode: %s, Time: %.2f ms\n", filename, sequential ? "sequential" : "random", elapsed_time);

    close(fd);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <filename> <sequential|random>\n", argv[0]);
        return EXIT_FAILURE;
    }

    int sequential = (strcmp(argv[2], "sequential") == 0);
    measure_read_time(argv[1], sequential);

    return EXIT_SUCCESS;
}