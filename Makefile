TOFU := tofu

# Default target, executed when you run 'make'
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make init       - Initialize the Terraform working directory (tofu init)"
	@echo "  make plan       - Create an execution plan (tofu plan)"
	@echo "  make apply      - Apply the changes required to reach the desired state (tofu apply)"
	@echo "  make destroy    - Destroy all resources managed by Terraform (tofu destroy)"
	@echo "  make fmt        - Rewrite Terraform configuration files to a canonical format (tofu fmt)"
	@echo "  make validate   - Validate the configuration files (tofu validate)"
	@echo "  make output     - Show all terraform output (tofu output)"
	@echo "  make all        - Runs init, plan, and apply sequentially"
	@echo "  make refresh    - update the state file"
	@echo "  make clean      - Clean generated files"
	@echo "  make set-pat    - Set the GitHub PAT in AWS SSM Parameter Store"


# Initialize Terraform (Tofu)
.PHONY: init
init:
	$(TOFU) init

# Create an execution plan
.PHONY: plan
plan:
	$(TOFU) plan -out=.plan

# Apply the changes
.PHONY: apply
apply:
	$(TOFU) apply .plan

# Destroy all resources
.PHONY: destroy
destroy:
	$(TOFU) destroy

# Format Terraform configuration files
.PHONY: fmt
fmt:
	$(TOFU) fmt  -write -recursive .

# Validate the configuration
.PHONY: validate
validate:
	$(TOFU) validate

# Show the output
.PHONY: output
output:
	$(TOFU) output

# Refresh state
.PHONY: refresh
refresh:
	$(TOFU) refresh

# Run init, plan, and apply sequentially
.PHONY: all
all: init plan apply

.PHONY: clean
clean:
	@rm -rf .terraform*
	@rm -rf *.tfstate*
	@rm -f .plan

# Set GitHub PAT in SSM Parameter Store
.PHONY: set-pat
set-pat:
	@read -r -s -p "Enter your GitHub Personal Access Token (PAT): " GITHUB_PAT; \
	echo ""; \
	aws ssm put-parameter --name "github_pat" --value "$$GITHUB_PAT" --type "SecureString" --overwrite --region eu-central-1; \
	echo "GitHub PAT set in SSM Parameter Store."
