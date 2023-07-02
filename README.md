# Platform lab

A base for gitops lab


## Requirements

Local k8s platform with an ingress, like rancher desktop

## Setup

* `make all` in root directory will install ArgoCD and Gitea, create local repos and push content and then create root app of apps in ArgoCD
* `make push` will local git push current directory

### /mkcert

* Creates self-signed cert
* Install cert on Ingress

### /bootrap

By default it will:

* Create argocd namespace
* Install argocd with default admin/admin access

`make root` will create root app of apps from the local gitea repo

### /platform

Create namespace and install gitea. After wating for the pods to be ready:

* Create a git remote named `local`.
* Create a token to access gitea.
* Create create an `ops` organization.
* Create `platform` repo inside `ops` organization.
* `git push -u local` current local repo.
* Create webhook for argocd

