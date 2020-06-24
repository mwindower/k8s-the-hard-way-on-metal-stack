# Kubernetes the hard way on metal-stack

This is an adoption of Kelsey Hightowers famous guide ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) for metal-stack.

**Disclaimer: This is only a demo setup that is published for CKA preparation**

Main differences to Kelsey's guide, which runs on GCP, are:
- LoadBalancing of the kube-apiserver can simply be done by setting the reserved static IP to the loopback interfaces of the controller nodes
- When using `10.244.0.0/16` for Pods, PodIPs are automatically distributed with BGP - so there is no route setup needed ([11-pod-network-routes](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/11-pod-network-routes.md) can be skipped completely)
- internal and external node ips have to be patched into the kubernetes node objects - this could be avoided with running the metal-ccm on the controllers (but it's good to do it once manually and see some grifts of kubelet)