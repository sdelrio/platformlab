#!/bin/bash

MKCERT_DOMAIN=127.0.0.1.nip.io
MKCERT_EXTRA="localhost 127.0.0.1 ::1"
CERT_FILEPREFIX=localhost
SECRET_NAME=default-certificate

traefikCert() {

# https:/doc.traefik.io/traefik/https/tls/

kubectl -n default create secret generic $SECRET_NAME \
  --from-file=tls.crt=./$CERT_FILEPREFIX-cert.pem \
  --from-file=tls.key=./$CERT_FILEPREFIX-key.pem \
  --save-config --dry-run=client -o yaml | tee | \
  kubectl apply -f -
   
kubectl apply -f - <<EOF
apiVersion: traefik.containo.us/v1alpha1
kind: TLSStore
metadata:
  name: default
  namespace: default
spec:
  defaultCertificate:
    secretName: $SECRET_NAME
EOF

echo "[info] Created traefik default certifcated using mkcert"
}

mkcert -install

mkcert \
  --cert-file $CERT_FILEPREFIX-cert.pem \
  --key-file $CERT_FILEPREFIX-key.pem \
  $MKCERT_DOMAIN "*.$MKCERT_DOMAIN" $MKCERT_EXTRA

# If traefik installed (rancher-desktop)
kubectl -n kube-system get deployment ztraefik 2>/dev/null >/dev/null
[ $? -eq 0 ] && traefikCert

exit 0
