ALIAS			   = fenrir
.DEFAULT_GOAL      = help

# Executables (local)
DOCKER_COMP = docker-compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP_CONT) bin/console
PLATFORM ?= $(shell uname -s)

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
## —— 🎵 🐳 The Symfony-docker Makefile 🐳 🎵 ——————————————————————————————————
%:
	@:

test-run: ## Print platform
	@echo $(PLATFORM) ${ARGS}

help: ## Outputs this help screen
	@echo "\033[1m make [TARGET] \033[0m"
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Build base and dev image to start development
	$(DOCKER_COMP) build --pull

build-no-cache: ## Build base and dev image to start development with no cache
	$(DOCKER_COMP) build --pull --no-cache

up: ## Start the project docker containers
	$(DOCKER_COMP) up

up-detached: ## Start the project docker containers
	$(DOCKER_COMP) up -d

down: ## Remove the docker containers
	$(DOCKER_COMP) down --remove-orphans

stop: ## Stop the docker containers
	$(DOCKER_COMP) stop

volume-prune: ## Removes docker volumes
	$(DOCKER_COMP) down -v

clean-images: down ## clean all docker images
	docker rmi $$(docker image ls | grep "${ALIAS}_*" | awk '{print $3}')

sh: ## Connect to the PHP FPM container
	@$(PHP_CONT) sh

## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the argument after composer to run a given command, example: make composer 'req symfony/orm-pack'
	@$(COMPOSER) $(filter-out $@,$(MAKECMDGOALS))

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the argument after make sf to run a given command, example: make sf about
	@$(SYMFONY) $(filter-out $@,$(MAKECMDGOALS))

cc: c=c:c ## Clear the cache
cc: sf
