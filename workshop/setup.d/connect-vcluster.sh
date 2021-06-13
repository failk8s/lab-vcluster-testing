#!/bin/bash

set -x

set -eo pipefail

# Download vcluster binary.

curl -L --silent --show-error --fail -o /opt/kubernetes/bin/vcluster https://github.com/loft-sh/vcluster/releases/download/v0.3.0-beta.2/vcluster-linux-amd64

chmod +x /opt/kubernetes/bin/vcluster

# Connect to cluster, merging the kubeconfig with $HOME/.kube/config.

vcluster connect vcluster -n $SESSION_NAMESPACE-vc --server https://vcluster.$SESSION_NAMESPACE-vc.svc.cluster.local --update-current

# Set the current context to use the virtual Kubernetes cluster.

kubectl config use-context vcluster_$SESSION_NAMESPACE-vc_vcluster 

kubectl config set-context vcluster_$SESSION_NAMESPACE-vc_vcluster --namespace default

# Override start-octant script and remove option for setting it's default
# namespace as having that means it ignores namespace set in context when
# changing contexts. Also override the console URL the gateway uses when
# first opening Octant. Both of these may actually no longer be required as
# they were hacks to get around problems with early Octant versions.

cp /opt/workshop/scripts/start-octant /opt/eduk8s/sbin/start-octant

CONSOLE_URL="$INGRESS_PROTOCOL://$SESSION_NAMESPACE-console.$INGRESS_DOMAIN$INGRESS_PORT_SUFFIX/"

cat >> /opt/eduk8s/etc/supervisor/gateway.conf << EOF
environment=CONSOLE_URL=$CONSOLE_URL
EOF
