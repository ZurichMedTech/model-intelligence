SHELL 								= /bin/bash
.DEFAULT_GOAL 						:= help

makefile_dir                        := $(dir $(makefile_path))
VENV_DIR                            := $(makefile_dir).venv


# VIRTUAL ENVIRONMENT -----------------------------

.PHONY: devenv
devenv: $(VENV_DIR) ## builds development environment
	# Installing python tools in $<
	@$</bin/pip --no-cache install \
		bump2version==1.0.1 \
		pip-tools==7.4.1 \
		mkdocs \
		mkdocs-material \
		pymdown-extensions \
		mkdocstrings
	# Installed packages in $<
	@$</bin/pip list

$(VENV_DIR):
	# creating virtual environment
	@python3 -m venv $@
	# updating package managers
	@$@/bin/pip --no-cache install --upgrade \
		pip \
		setuptools \
		wheel

.PHONY: serve
serve: ## serves the documentation
	@$(VENV_DIR)/bin/mkdocs serve --dev-addr=0.0.0.0:8000 

.PHONY: build
build: ## build the documentation site
	@$(VENV_DIR)/bin/mkdocs build

.PHONY: gh-deploy
gh-deploy: ## deploy documentation to GitHub Pages
	@$(VENV_DIR)/bin/mkdocs gh-deploy --force

.PHONY: help
help: ## help on rule's targets
	@awk --posix 'BEGIN {FS = ":.*?## "} /^[[:alpha:][:space:]_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
