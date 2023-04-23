default: namespace argocd access

argocd/charts: argocd/Chart.yaml
	@echo "[info] Checking argocd helm dependency build..."
	@cd argocd \
		&& [ ! -d ./charts ] && helm dependency build > /dev/null || echo "[info] chart already downloaded. Delete chars/ if want to download."

namespace:
	@kubectl create namespace argocd --dry-run=client --output=yaml \
		| kubectl apply -f - 

gpg:
	gpg --full-generate-key --rfc4880

secret:
	gpg --armor --export-secret-keys $(GPG_KEY) > $(GPG_TMP)
	kubectl -n argocd create secret generic helm-secrets-private-keys --from-file=$(GPG_TMP)

.PHONY: argocd
argocd: argocd/charts
	@cd argocd && \
		helm template \
        --include-crds \
        --namespace argocd \
        argocd . \
				| kubectl apply -f -
	@echo "[info] Waiting for argocd server pods to be ready ..."
	@kubectl wait pods -n argocd -l app.kubernetes.io/component=server --for condition=Ready --timeout=90s

delete:
	@cd argocd && \
		helm template \
        --include-crds \
        --namespace argocd \
        argocd . \
				| kubectl delete -f -

access:
	@echo -n 'ArgoCD admin: '
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

.PHONY: root
root:
	@cd root && \
		helm template \
        --namespace argocd \
        argocdroot . \
        | kubectl apply -f - 


