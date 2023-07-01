# Platform lab

A base


## Requirements

Local k8s platform with an ingress, like rancher desktop

## setup

* `make all` in root directory will install ArgoCD and Gitea, create local repos and push content and then create root app of apps in ArgoCD
* `make push` will local git push current directory

### bootrap/

Default will create argocd namesapce, install argocd and print admin access. You can get credentials anytime writing `make access`.

`make root` will create root app of apps from the local gitea repo

### /platform

Create namespace and install gitea. After wating for the pods to be ready:

* Create a git remote named `local`.
* Create a token to access gitea.
* Create create an `ops` organization.
* Create `platform` repo inside `ops` organization.
* `git push -u local` current local repo.

## /mkcert

* Creates self-signed cert
* Install cert on Ingress

