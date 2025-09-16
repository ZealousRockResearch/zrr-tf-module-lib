# Makefile for MySQL Firewall Rule module

.PHONY: help init validate format docs test test-unit test-integration clean

# Default target
help:
	@echo "Available targets:"
	@echo "  init               Initialize Terraform"
	@echo "  validate           Validate Terraform configuration"
	@echo "  format             Format Terraform files"
	@echo "  docs               Generate documentation"
	@echo "  test               Run all tests"
	@echo "  test-unit          Run unit tests"
	@echo "  test-integration   Run integration tests"
	@echo "  clean              Clean up temporary files"

# Initialize Terraform
init:
	terraform init -backend=false

# Validate Terraform configuration
validate:
	terraform validate

# Format Terraform files
format:
	terraform fmt -recursive

# Generate documentation
docs:
	terraform-docs markdown table --output-file README.md .

# Run all tests
test: test-unit test-integration

# Run unit tests
test-unit:
	terraform test

# Run integration tests (requires Go)
test-integration:
	cd tests/integration && go test -v -timeout 30m

# Clean up
clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -rf tests/integration/vendor
	find . -name "terraform.tfstate*" -delete
	find . -name ".terraform" -type d -exec rm -rf {} +