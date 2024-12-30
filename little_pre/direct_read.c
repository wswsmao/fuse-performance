#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <sys/stat.h>

#define BUFFER_SIZE 4096

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    int fd = open(argv[1], O_RDONLY | O_DIRECT);
    if (fd == -1) {
        perror("Error opening file");
        return 1;
    }

    void *buf;
    if (posix_memalign(&buf, 512, BUFFER_SIZE) != 0) {
        perror("Error allocating aligned memory");
        close(fd);
        return 1;
    }

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    ssize_t bytes_read = read(fd, buf, BUFFER_SIZE);

    clock_gettime(CLOCK_MONOTONIC, &end);

    if (bytes_read == -1) {
        perror("Error reading file");
        free(buf);
        close(fd);
        return 1;
    }

    long elapsed_us = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_nsec - start.tv_nsec) / 1000;
    printf("%ld\n", elapsed_us);

    free(buf);
    close(fd);
    return 0;
}
