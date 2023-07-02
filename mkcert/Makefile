SHELL:=/bin/bash

define REQUIREMENTS

## You will need following tools installed:

|Name            |Required             |More info                                          |
|----------------|---------------------|---------------------------------------------------|
|mkcert          |Yes                  |'https://github.com/FiloSottile/mkcert'            |
|kubectl         |Yes                  |'https://kubernetes.io/docs/tasks/tools/#kubectl'  |

endef
export REQUIREMENTS

all:
	@./setup_mkcert.sh

check/%:
	@which $* >/dev/null || (echo "[ERR] $* not found"; make requirements; exit 1); \

check: check/mkcert check/kubectl

requirements:
	@echo "$$REQUIREMENTS"

