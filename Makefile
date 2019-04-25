################################################################################
# Variables
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
UID:=$(shell id -u)
GID:=$(shell id -g)
DOCKER_COMPOSE := docker-compose
################################################################################
# Copie des dists
$(shell test ! -f docker-compose.override.yml && cp docker-compose.override.dist.yml docker-compose.override.yml)
$(shell test ! -f .env && cp .env.dist .env)
# Inclusion de l'environnement
include .env
export $(shell sed 's/=.*//' .env)
################################################################################

# Commandes
build:
	$(DOCKER_COMPOSE) build $(c)
up:
	touch traefik/acme.json
	chmod 600 traefik/acme.json
	$(DOCKER_COMPOSE) up -d $(c)
down:
	$(DOCKER_COMPOSE) down $(c)
down-volumes:
	$(DOCKER_COMPOSE) down -v $(c)
	
restart: stop
restart: start	
start:
	$(DOCKER_COMPOSE) start $(c)
stop:
	$(DOCKER_COMPOSE) stop $(c)
exec:
	$(DOCKER_COMPOSE) exec $(c)
logs:
	$(DOCKER_COMPOSE) logs -f $(c)
