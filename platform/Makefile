default: namespace gitea

SHELL:=/bin/bash

GITEA_DOMAIN := git.127.0.0.1.nip.io
GITEA_URL := https://$(GITEA_DOMAIN)
GITEA_API := $(GITEA_URL)/api/v1
TMP_TOKEN := /tmp/token.json
TOKEN_NAME := makefile-token

GITOPS_ORG := ops
GITOPS_REPO := platform
GITOPS_USER := devops
GITOPS_PASS := devops
GITOPS_PUSH_URL := https://$(GITOPS_USER):$(GITOPS_PASS)@$(GITEA_DOMAIN)

gitea/charts: gitea/Chart.yaml
	@echo "[info] Checking gitea helm dependency build ..."
	@cd gitea \
		&& [ ! -d ./charts ] && helm dependency build > /dev/null || echo "[info] chart already downloaded. Delete chars/ if want to download."

namespace:
	@kubectl create namespace gitea --dry-run=client --output=yaml \
		| kubectl apply -f -

.PHONY: gitea
gitea: namespace gitea/charts
	@cd gitea && \
		helm template \
        --include-crds \
				--api-versions="networking.k8s.io/v1/Ingress" \
				--skip-tests \
        --namespace gitea \
        gitea . \
				| kubectl -n gitea apply -f -
	@echo "[info] wait for gitea pods to be ready ..."
	@kubectl wait pods -n gitea -l app=gitea --for condition=Ready --timeout=120s
	@echo "[info] wait for gitea ingress $(GITEA_URL) to be ready ..."
	@while [[ "`curl -L -sk -o /dev/null -w ''%{http_code}'' $(GITEA_URL)`" != "200" ]]; do sleep 1; echo -n "." ; done

gitea/token:  # https://docs.gitea.io/en-us/api-usage/#generating-and-listing-api-tokens
	@echo "Generating token"
	@[ ! -f $(TMP_TOKEN) ] && \
		curl -k -s \
		-H "Content-Type: application/json" \
		-X POST \
		-d '{"name":"$(TOKEN_NAME)", "scopes":["sudo","admin:org","write:repo_hook"]}' \
		-u $(GITOPS_USER):$(GITOPS_PASS) \
		$(GITEA_API)/users/$(GITOPS_USER)/tokens > $(TMP_TOKEN) \
		|| echo "$(TMP_TOKEN) already existed"

gitea/tokendelete:  # https://docs.gitea.io/en-us/api-usage/#generating-and-listing-api-tokens
	@echo "Deleting token"
	@curl -k -s \
		-X DELETE $(GITEA_API)/users/$(GITOPS_USER)/tokens/$(TOKEN_NAME) \
		-H "Content-Type: application/json" \
		-d '{"name":"$(TOKEN_NAME)"}' \
		-u $(GITOPS_USER):$(GITOPS_PASS) \
		&& rm -f $(TMP_TOKEN)

gitea/org:
	@echo "Creating gitea organization: $(GITOPS_ORG)"
	@curl -k -X POST "$(GITEA_API)/admin/users/$(GITOPS_USER)/orgs" \
		-H "Authorization: token $(shell cat $(TMP_TOKEN) | jq -r .sha1)" \
		-H "Content-Type: application/json" \
		-H "accept: application/json" \
		--data '{"username": "$(GITOPS_ORG)"}'

gitea/projectdelete:
	@curl -v -X DELETE "$(GITEA_API)/admin/users/ORG" -H "Authorization: token $(shell cat $(TMP_TOKEN) | jq -r .sha1)" -H  "accept: application/json"

gitea/repo:
	@echo "Creating gitea repo: $(GITOPS_REPO)"
	@curl -k -X POST "$(GITEA_API)/org/$(GITOPS_ORG)/repos" \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-H "Authorization: token $(shell cat $(TMP_TOKEN) | jq -r .sha1)" \
		--data '{"name":"$(GITOPS_REPO)"}'

gitea/remote:
	@if git remote -v | grep -q $(GITEA_DOMAIN); then \
		echo "already configured local git"; \
	else \
		echo "configuring $(GITEA_URL)"; \
		cd .. && git remote add local https://$(GITOPS_USER):$(GITOPS_PASS)@$(GITEA_DOMAIN)/$(GITOPS_ORG)/$(GITOPS_REPO).git; \
	fi

gitea/push:
	cd .. && git -c http.sslVerify=false push -u local master

gitea/webhook:
	@echo "Checking for already created argocd webhook on: $(GITOPS_REPO)"
	@curl -sk -X GET "$(GITEA_API)/repos/$(GITOPS_ORG)/$(GITOPS_REPO)/hooks" \
	-H 'accept: application/json' \
	-H 'Content-Type: application/json' \
	-H "Authorization: token $(shell cat $(TMP_TOKEN) | jq -r .sha1)" \
	| grep -q argocd-server.argocd \
	&& echo "Webhook was already created" \
	|| ( echo "Creating gitea argocd webhook on: $(GITOPS_REPO)"; \
	curl -k -X POST "$(GITEA_API)/repos/$(GITOPS_ORG)/$(GITOPS_REPO)/hooks" \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-H "Authorization: token $(shell cat $(TMP_TOKEN) | jq -r .sha1)" \
		--data '{ "type": "gitea", "active": true, "branch_filter": "master", "authorization_heder": "", "events": ["push"], "config": { "content_type":"json", "http_method":"post", "url":"http://argocd-server.argocd/api/webhook" } }'\
		)

gitea/prepare: gitea/remote gitea/tokendelete gitea/token gitea/org gitea/repo gitea/push gitea/webhook

gitea/template:
	@cd gitea && \
		helm template \
        --include-crds \
				--api-versions="networking.k8s.io/v1/Ingress" \
        --namespace gitea \
        gitea .

delete:
	@cd gitea && \
		helm template \
        --include-crds \
				--api-versions="networking.k8s.io/v1/Ingress" \
        --namespace gitea \
        gitea . \
				| kubectl -n gitea delete -f -
