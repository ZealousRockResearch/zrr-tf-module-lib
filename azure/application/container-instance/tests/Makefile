# Makefile for Container Instance Module Tests

# Default Go settings
GOCMD=go
GOTEST=$(GOCMD) test
GOMOD=$(GOCMD) mod
GOFMT=$(GOCMD) fmt

# Test directories
UNIT_TEST_DIR=./unit
INTEGRATION_TEST_DIR=./integration

# Test settings
TIMEOUT=45m
PARALLEL=4

# Default target
.PHONY: all
all: fmt test

# Format Go code
.PHONY: fmt
fmt:
	@echo "Formatting Go code..."
	$(GOFMT) ./...

# Download Go modules
.PHONY: deps
deps:
	@echo "Downloading Go modules..."
	$(GOMOD) download
	$(GOMOD) tidy

# Run unit tests
.PHONY: test-unit
test-unit:
	@echo "Running unit tests..."
	cd $(UNIT_TEST_DIR) && $(GOTEST) -v -timeout $(TIMEOUT) -parallel $(PARALLEL)

# Run integration tests
.PHONY: test-integration
test-integration:
	@echo "Running integration tests..."
	cd $(INTEGRATION_TEST_DIR) && $(GOTEST) -v -timeout $(TIMEOUT) -parallel $(PARALLEL)

# Run all tests
.PHONY: test
test: test-unit test-integration

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "Running tests with coverage..."
	cd $(UNIT_TEST_DIR) && $(GOTEST) -v -timeout $(TIMEOUT) -parallel $(PARALLEL) -coverprofile=coverage.out
	cd $(INTEGRATION_TEST_DIR) && $(GOTEST) -v -timeout $(TIMEOUT) -parallel $(PARALLEL) -coverprofile=coverage.out

# Clean test artifacts
.PHONY: clean
clean:
	@echo "Cleaning test artifacts..."
	rm -f $(UNIT_TEST_DIR)/coverage.out
	rm -f $(INTEGRATION_TEST_DIR)/coverage.out
	rm -f $(UNIT_TEST_DIR)/*.tfplan
	rm -f $(INTEGRATION_TEST_DIR)/*.tfplan
	rm -rf $(UNIT_TEST_DIR)/.terraform
	rm -rf $(INTEGRATION_TEST_DIR)/.terraform
	rm -f $(UNIT_TEST_DIR)/.terraform.lock.hcl
	rm -f $(INTEGRATION_TEST_DIR)/.terraform.lock.hcl

# Terraform-specific targets
.PHONY: tf-fmt
tf-fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive ../../

.PHONY: tf-validate
tf-validate:
	@echo "Validating Terraform configuration..."
	cd ../../ && terraform init -backend=false
	cd ../../ && terraform validate

.PHONY: tf-lint
tf-lint:
	@echo "Linting Terraform code..."
	cd ../../ && tflint || echo "tflint not installed or configuration issues"

# Full validation pipeline
.PHONY: validate
validate: tf-fmt tf-validate deps fmt test

# Test specific scenarios
.PHONY: test-basic
test-basic:
	@echo "Testing basic example..."
	cd ../../examples/basic && terraform init -backend=false
	cd ../../examples/basic && terraform validate
	cd ../../examples/basic && terraform plan

.PHONY: test-advanced
test-advanced:
	@echo "Testing advanced example..."
	cd ../../examples/advanced && terraform init -backend=false
	cd ../../examples/advanced && terraform validate
	cd ../../examples/advanced && terraform plan

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all              - Format code and run all tests"
	@echo "  fmt              - Format Go code"
	@echo "  deps             - Download and tidy Go modules"
	@echo "  test-unit        - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test             - Run all tests"
	@echo "  test-coverage    - Run tests with coverage reporting"
	@echo "  clean            - Clean test artifacts"
	@echo "  tf-fmt           - Format Terraform code"
	@echo "  tf-validate      - Validate Terraform configuration"
	@echo "  tf-lint          - Lint Terraform code"
	@echo "  validate         - Run full validation pipeline"
	@echo "  test-basic       - Test basic example"
	@echo "  test-advanced    - Test advanced example"
	@echo "  help             - Show this help message"