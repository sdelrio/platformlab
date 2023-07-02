SHELL:=/bin/bash

define REQUIREMENTS

## You will need following tools installed:

|Name            |Required             |More info                                          |
|----------------|---------------------|---------------------------------------------------|
|mkcert          |Yes                  |'https://github.com/FiloSottile/mkcert#installation|
|kubectl         |Yes                  |'https://kubernetes.io/docs/tasks/tools/#kubectl'  |
|helm            |Yes                  |'https://helm.sh/docs/intro/install/'              |

endef
export REQUIREMENTS

all: check
all:
	@cd mkcert && $(MAKE) 
	@cd bootstrap && $(MAKE) 
	@cd platform && $(MAKE)
	@cd platform && $(MAKE) gitea/prepare
	@cd bootstrap && $(MAKE) root

push:
	@git -c http.sslVerify=false push -u local master

requirements:
	@echo "$$REQUIREMENTS"

check/%:
	which $* >/dev/null || (echo "[ERR] $* not found"; $(MAKE) $$REQUIREMENTS; exit 1); 

check: check/mkcert heck/jq check/yq check/kubectl check/helm
	@echo "[OK] checked requirements"

