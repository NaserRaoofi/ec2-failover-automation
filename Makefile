# Makefile for EC2 Failover Automation

# Default environment
ENV ?= dev

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help init plan apply destroy clean validate fmt check-fmt lint docs

help: ## Show this help message
	@echo "EC2 Failover Automation Makefile"
	@echo ""
	@echo "Usage: make [target] [ENV=environment]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform in the specified environment
	@echo "$(YELLOW)Initializing Terraform for $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform init

plan: ## Plan Terraform changes for the specified environment
	@echo "$(YELLOW)Planning Terraform changes for $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform plan

apply: ## Apply Terraform changes for the specified environment
	@echo "$(YELLOW)Applying Terraform changes for $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform apply

destroy: ## Destroy Terraform resources for the specified environment
	@echo "$(RED)Destroying Terraform resources for $(ENV) environment...$(NC)"
	@cd environments/$(ENV) && terraform destroy

clean: ## Clean up Terraform files
	@echo "$(YELLOW)Cleaning up Terraform files...$(NC)"
	@find . -name "*.tfstate*" -delete
	@find . -name ".terraform" -type d -exec rm -rf {} +
	@find . -name ".terraform.lock.hcl" -delete
	@find . -name "tfplan" -delete

validate: ## Validate Terraform configuration
	@echo "$(YELLOW)Validating Terraform configuration...$(NC)"
	@terraform validate

fmt: ## Format Terraform files
	@echo "$(YELLOW)Formatting Terraform files...$(NC)"
	@terraform fmt -recursive

check-fmt: ## Check if Terraform files are formatted
	@echo "$(YELLOW)Checking Terraform file formatting...$(NC)"
	@terraform fmt -check -recursive

lint: ## Run terraform validate on all modules
	@echo "$(YELLOW)Linting Terraform modules...$(NC)"
	@for dir in modules/*/; do \
		echo "Validating $$dir"; \
		cd $$dir && terraform init -backend=false > /dev/null 2>&1 && terraform validate; \
		cd - > /dev/null; \
	done

docs: ## Generate documentation
	@echo "$(YELLOW)Documentation is available in the docs/ directory$(NC)"
	@echo "$(GREEN)Getting Started:$(NC) docs/getting-started.md"
	@echo "$(GREEN)Architecture:$(NC) docs/architecture.md"

# Environment-specific targets
dev-init: ## Initialize dev environment
	@$(MAKE) init ENV=dev

dev-plan: ## Plan dev environment
	@$(MAKE) plan ENV=dev

dev-apply: ## Apply dev environment
	@$(MAKE) apply ENV=dev

dev-destroy: ## Destroy dev environment
	@$(MAKE) destroy ENV=dev

staging-init: ## Initialize staging environment
	@$(MAKE) init ENV=staging

staging-plan: ## Plan staging environment
	@$(MAKE) plan ENV=staging

staging-apply: ## Apply staging environment
	@$(MAKE) apply ENV=staging

staging-destroy: ## Destroy staging environment
	@$(MAKE) destroy ENV=staging

prod-init: ## Initialize prod environment
	@$(MAKE) init ENV=prod

prod-plan: ## Plan prod environment
	@$(MAKE) plan ENV=prod

prod-apply: ## Apply prod environment
	@$(MAKE) apply ENV=prod

prod-destroy: ## Destroy prod environment
	@$(MAKE) destroy ENV=prod

# Quick deployment with script
quick-deploy: ## Quick deployment using script
	@echo "$(YELLOW)Quick deployment to $(ENV) environment...$(NC)"
	@./scripts/deploy.sh $(ENV)

quick-cleanup: ## Quick cleanup using script
	@echo "$(RED)Quick cleanup for $(ENV) environment...$(NC)"
	@./scripts/cleanup.sh $(ENV)
