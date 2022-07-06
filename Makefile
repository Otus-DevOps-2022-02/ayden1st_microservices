.DEFAULT_GOAL := help
.PHONY: all

help:  ## Show this help message.
	@echo 'usage: make [target] ...'
	@echo
	@echo 'targets:'
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'

all: build_all push_all ## Build and Push all images.

build_prometheus: ## Build Prometheus image.
	docker build -t $(USER_NAME)/prometheus monitoring/prometheus

build_ui: ## Build UI image.
	echo `git show --format="%h" HEAD | head -1` > src/ui/build_info.txt
	echo `git rev-parse --abbrev-ref HEAD` >> src/ui/build_info.txt
	docker build -t $(USER_NAME)/ui src/ui

build_post: ## Build Post image.
	echo `git show --format="%h" HEAD | head -1` > src/post-py/build_info.txt
	echo `git rev-parse --abbrev-ref HEAD` >> src/post-py/build_info.txt
	docker build -t $(USER_NAME)/post src/post-py

build_comment: ## Build Comment image.
	echo `git show --format="%h" HEAD | head -1` > src/comment/build_info.txt
	echo `git rev-parse --abbrev-ref HEAD` >> src/comment/build_info.txt
	docker build -t $(USER_NAME)/comment src/comment

build_all: build_prometheus build_ui build_comment build_post  ## Build all

push_prometheus: ## Push Prometheus image.
	docker push $(USER_NAME)/prometheus

push_ui: ## Push UI image.
	docker push $(USER_NAME)/ui

push_post: ## Push Post image.
	docker push $(USER_NAME)/post

push_comment: ## Push Comment image.
	docker push $(USER_NAME)/comment

push_all: push_prometheus push_ui push_post push_comment ## Push all

terraform_k8s_vm: ## Create VM for k8s
	@cd kubernetes/terraform && \
	terraform init -input=false && \
	terraform plan -out=tfplan -input=false \
	&& terraform apply -input=false tfplan

ansible_k8s: ## Install k8s
	@cd kubernetes/ansible && \
	ansible all -m wait_for_connection && \
	ansible-playbook playbooks/install_docker.yml && \
	ansible-playbook playbooks/install_kuber.yml

destroy_k8s_vm: ## Destroy VM for k8s
	@cd kubernetes/terraform && \
	terraform init -input=false && \
	terraform plan -out=tfplan -destroy && \
	terraform apply tfplan

install_k8s: terraform_k8s_vm ansible_k8s ## Install k8s on YC

install_yc_mk8s: ## Install Yandex Cloud Managed Kubernetes
	@cd kubernetes/terraform_yc_mk8s && \
	terraform init -input=false && \
	terraform plan -out=tfplan -input=false \
	&& terraform apply -input=false tfplan

destroy_yc_mk8s_vm: ## Destroy Yandex Cloud Managed Kubernetes
	@cd kubernetes/terraform_yc_mk8s && \
	terraform init -input=false && \
	terraform plan -out=tfplan -destroy && \
	terraform apply tfplan
