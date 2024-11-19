# Makefile for automating file generation, compilation, and testing

# Variables
OUTPUT_DIR = large_files
TEST_PROGRAM = file_access_test
SOURCE_FILE = file_access_test.c
GENERATE_SCRIPT = generate_large_files.sh
RUN_TEST_SCRIPT = run_tests.sh
REPORT_FILE = performance_report.txt

# Default target
all: generate_files compile_tests run_tests

# Target to generate large files
generate_files:
	@echo "Generating large files..."
	@bash $(GENERATE_SCRIPT)

# Target to compile the test program
compile_tests:
	@echo "Compiling test program..."
	@gcc -o $(TEST_PROGRAM) $(SOURCE_FILE)

# # Target to run tests and generate report
run_tests:
	@echo "Running tests and generating report..."
	@bash $(RUN_TEST_SCRIPT)

# Target to clean up generated files and compiled binaries
clean:
	@echo "Cleaning up..."
	@rm -rf $(OUTPUT_DIR) $(TEST_PROGRAM) $(REPORT_FILE)

.PHONY: all generate_files compile_tests run_tests clean
