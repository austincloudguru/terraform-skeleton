# Makefile for running Terraform.
## Set the Project Variables
s3_bucket="${PROJECT}-tf"
key="-${PROJECT}.tfstate"
dynamodb_table="terraform-${PROJECT}-lock"
region=${AWS_REGION}


.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z $(PROJECT) ]; then echo "PROJECT was not set" ; exit 10 ; fi
	@if [ -z $(AWS_REGION) ]; then echo "AWS Region was not set" ; exit 10 ; fi

stateinit: set-env ## Initializes the bucket and dynamodb for state
	@terraform init

stateplan: stateinit ## Shows the plan
	@terraform plan -input=false -refresh=true -var 'tf_project=${PROJECT}'

stateapply: stateinit
	@terraform apply -input=true -refresh=true -var 'tf_project=${PROJECT}'


init: set-env ## Initializes the terraform remote state backend and pulls the correct projects state.
	@rm -rf .terraform/*.tf*
	@terraform init \
        -backend-config="bucket=${s3_bucket}" \
        -backend-config="key=${key}" \
        -backend-config="dynamodb_table=${dynamodb_table}" \
        -backend-config="region=${region}"

update: ## Gets any module updates
	@terraform get -update=true &>/dev/null

plan: init update ## Runs a plan.
	@terraform plan -input=false -refresh=true -var-file=projects/globals/inputs.tfvars -var-file=projects/$(PROJECT)/inputs.tfvars

plan-destroy: init update ## Shows what a destroy would do.
	@terraform plan -input=false -refresh=true -destroy -var-file=projects/globals/inputs.tfvars -var-file=projects/$(PROJECT)/inputs.tfvars

show: init ## Shows a module
	@terraform show 

graph: ## Runs the terraform grapher
	@rm -f graph.png
	@terraform graph -draw-cycles | dot -Tpng > graph.png
	@open graph.png

apply: init update ## Applies a new state.
	@terraform apply -input=true -refresh=true -var-file=projects/globals/inputs.tfvars -var-file=projects/$(PROJECT)/inputs.tfvars

output: update ## Show outputs of a module or the entire state.
	@if [ -z $(MODULE) ]; then terraform output ; else terraform output -module=$(MODULE) ; fi

destroy: init update ## Destroys targets
	@terraform destroy -var-file=projects/globals/inputs.tfvars -var-file=projects/$(PROJECT)/inputs.tfvars
