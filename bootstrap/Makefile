default: namespace argocd access

namespace:
	@kubectl create namespace argocd --dry-run=client --output=yaml \
		| kubectl apply -f - 

.PHONY: argocd
argocd:
	@cd argocd && \
		kustomize build --enable-helm \
			| kubectl apply -f -
	@echo "[info] Waiting for argocd server pods to be ready ..."
	@kubectl wait pods -n argocd -l app.kubernetes.io/component=server --for condition=Ready --timeout=90s

delete:
	@cd argocd && \
		kustomize build --enable-helm \
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


