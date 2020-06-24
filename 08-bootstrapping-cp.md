# 8. Bootstrapping Control-Plane

Follow https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md

But Loadbalancer-Creation is not needed, just assign the `$KUBERNETES_PUBLIC_ADDRESS` to the loopback device of every controller:

```
ip a a ${KUBERNETES_PUBLIC_ADDRESS} dev lo
```

Generate admin kubeconfig locally:

```
kubectl config set-cluster kubernetes-the-hard-way \
--certificate-authority=ca.pem \
--embed-certs=true \
--server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin \
--client-certificate=admin.pem \
--client-key=admin-key.pem

kubectl config set-context kubernetes-the-hard-way \
--cluster=kubernetes-the-hard-way \
--user=admin

kubectl config use-context kubernetes-the-hard-way
```