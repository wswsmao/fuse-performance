# Fuse Performance Testing

This project provides a set of scripts and a Dockerfile to generate large files, compile test programs, and run performance tests on file access patterns using a Docker container.

## Prerequisites

* Docker installed on your system.
* A working C compiler (e.g., `gcc`) and `make` utility for local compilation.

## Project Structure

* `file_access_test.c`: C source code for testing different file access patterns.
* `generate_large_files.sh`: Shell script to generate large files with random content.
* `run_tests.sh`: Shell script to run the compiled test program on the generated files.
* `Makefile`: Automates the process of generating files, compiling the test program, and cleaning up.
* `Dockerfile`: Defines the Docker image to run the tests in a container.

## Usage

### Step 1: Generate Files and Compile

Run the following command to generate large files and compile the test program:

```bash
make
```

This will execute the following steps:

* Generate large files with random content.
* Compile the `file_access_test.c` into an executable named `file_access_test`.

### Step 2: Build Docker Image

Build the Docker image using the provided Dockerfile:

```bash
docker build -t my-test-image .
```

This command will:

* Copy the compiled binary and generated files into the Docker image.
* Set up the container to run the tests upon startup.

### Step 3: Run Tests in Docker

Run the Docker container to execute the tests:

```bash
docker run --rm my-test-image
```

This will:

* Execute the `run_tests.sh` script inside the container.
* Output the performance results to the terminal.

### Step 4: Clean Up

To remove generated files and binaries from your local environment, run:

```bash
make clean
```

## Notes

* Ensure that the `run_tests.sh` script is executable. You can set the permission using `chmod +x run_tests.sh`.
* Adjust the file sizes and number of files in `generate_large_files.sh` as needed for your testing purposes.
* The Dockerfile assumes that all necessary files are in the same directory. Adjust the `COPY` commands if your file structure differs.

