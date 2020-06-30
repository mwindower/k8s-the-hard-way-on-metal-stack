# 9. Bootstrapping Workers

Follow https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/09-bootstrapping-kubernetes-workers.md

Some adoptions are needed.

## CNI-Config

Generate a node-specific CNI configuration - the POD_CIDR has to be distinct on every node: e.g. `POD_CIDR="10.244.0.0/24"` for worker-0, `POD_CIDR="10.244.1.0/24"` for worker-1 and `POD_CIDR="10.244.2.0/24"` for worker-2.

```
for worker1: export POD_CIDR="10.244.0.0/24"
for worker2: export POD_CIDR="10.244.1.0/24"
for worker3: export POD_CIDR="10.244.2.0/24"
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
```

## Kube-Proxy-Config

```
cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.244.0.0/16"
EOF
```

## Repairing containerd

After that containerd has to be repaired because of https://github.com/kubernetes/kubernetes/issues/73189

```
mkdir -p /etc/containerd && containerd config default > /etc/containerd/config.toml 
systemctl restart containerd
```

## Adjusting node ips / setting hosts

To make `kubectl logs/exec` work, one needs to adjust the node ips OR set all the worker hostnames on the controller nodes (`/etc/hosts`).

### Adjusting node ips

The kubelet needs to have the cloud-provider flat set to external so that kubelet does not interfere with addresses that are specified later in the node spec.

```
vi /etc/systemd/system/kubelet.service
... add

--cloud-provider=external \

systemctl daemon-reload
systemctl restart kubelet
```

Patch node objects to contain the proper internal and external address.
This can not be done with kubectl!

```
export WORKER_EXTERNAL_IPS=()
export WORKER_INTERNAL_IPS=()

kubectl proxy --port=8080 &
for i in {0..2}; do \
  kubectl taint node worker-$0 node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule-
  url="http://localhost:8080/api/v1/nodes/worker-${i}/status"
  data=$(cat <<END
[
    {
        "op": "add",
        "path": "/status/addresses",
        "value": [
            {
                "type": "InternalIP",
                "address": "${WORKER_INTERNAL_IPS[$i]}"
            },
            {
                "type": "ExternalIP",
                "address": "${WORKER_EXTERNAL_IPS[$i]}"
            }
        ]
    }
]
END
);
  curl -k -v -XPATCH \
    -H "Accept: application/json" \
    -H "Content-Type: application/json-patch+json" \
    $url \
    --data "${data}" 
done
```
