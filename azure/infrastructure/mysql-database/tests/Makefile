# Makefile for MySQL Database module tests

.PHONY: test unit-test integration-test clean fmt vet deps help

# Default target
help:
	@echo "Available targets:"
	@echo "  test            - Run all tests (unit + integration)"
	@echo "  unit-test       - Run unit tests only"
	@echo "  integration-test - Run integration tests only"
	@echo "  fmt             - Format Go code"
	@echo "  vet             - Run go vet"
	@echo "  deps            - Install dependencies"
	@echo "  clean           - Clean test artifacts"
	@echo "  help            - Show this help"

# Install dependencies
deps:
	@echo "Installing Go dependencies..."
	go mod tidy
	go mod download

# Format Go code
fmt:
	@echo "Formatting Go code..."
	go fmt ./...

# Run go vet
vet:
	@echo "Running go vet..."
	go vet ./...

# Run unit tests
unit-test: deps fmt vet
	@echo "Running unit tests..."
	go test -v -tags=unit ./unit/... -timeout=30m

# Run integration tests
integration-test: deps fmt vet
	@echo "Running integration tests..."
	@echo "Note: Integration tests require valid Azure credentials and may create real resources"
	go test -v -tags=integration ./integration/... -timeout=60m

# Run all tests
test: unit-test integration-test

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	go clean -testcache
	rm -rf .terraform*
	rm -f terraform.tfstate*
	rm -f *.log

# Run tests with coverage
test-coverage: deps fmt vet
	@echo "Running tests with coverage..."
	go test -v -cover ./... -timeout=30m

# Run tests in parallel
test-parallel: deps fmt vet
	@echo "Running tests in parallel..."
	go test -v -parallel=4 ./... -timeout=45m

# Validate Terraform files
terraform-validate:
	@echo "Validating Terraform files..."
	cd .. && terraform init -backend=false
	cd .. && terraform validate
	cd ../examples/basic && terraform init -backend=false
	cd ../examples/basic && terraform validate
	cd ../examples/advanced && terraform init -backend=false
	cd ../examples/advanced && terraform validate

# Run all validation checks
validate: terraform-validate fmt vet

# CI target for continuous integration
ci: validate unit-test

# Local development target
dev: validate unit-test

# Security scan (if security tools are available)
security-scan:
	@echo "Running security scan..."
	@if command -v gosec >/dev/null 2>&1; then \
		gosec ./...; \
	else \
		echo "gosec not installed, skipping security scan"; \
	fi