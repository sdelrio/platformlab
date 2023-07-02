SHELL:=/bin/bash

define REQUIREMENTS
## You will need following tools installed:
|Name            |Required             |More info                                          |
|----------------|---------------------|---------------------------------------------------|
|Charm Gum       |Yes                  |'https://github.com/charmbracelet/gum#installation'|
|mkcert          |Yes                  |'https://github.com/FiloSottile/mkcert'            |
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
	@echo "$$REQUIREMENTS" | gum format || echo "$$REQUIREMENTS"

check/%:
	@if [[ "$*" == "gum" ]]; then \
		which $* >/dev/null || (echo "[ERR] $* not found"; $(MAKE) $$REQUIREMENTS; exit 1); \
	else	\
		which $* >/dev/null || (gum style \
			--foreground 202 --border-foreground 202 --border double \
			--margin "1 2" --padding "1 2" \
			"[ERR] $* not found"; $(MAKE) requirements; exit 1); \
	fi;

check: check/gum check/mkcert check/jq check/yq check/kubectl check/helm
	@echo "[OK] checked requirements"

