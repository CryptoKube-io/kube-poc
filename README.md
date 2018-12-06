# CryptoKube Proof-of-concept

## Prerequisites
- DigitalOcean account w/Kubernetes service
- Kuberenetes cluster created, env var KUBECONFIG=<path/to/kubeconfig.yaml>
- kubectl installed on management host (laptop or otherwise)

## Setup
```bash
./init.sh -c mycluster-kubeconfig.yaml -u myrpcuser -p myrpcpass # set KUBECONFIG, rpcuser+rpcpass secrets
source env.sh
kubectl cluster-info
kubectl create -f bitcoin-secrets.yaml
kubectl create configmap bitcoin-config --from-file=bitcoin.conf
kubectl create -f bitcoin-deploy.yaml
kubectl logs deploy/bitcoin --tail=5 -f
```

## External resources
### Bitcoin
- https://bitcoin.org/en/download
- https://jlopp.github.io/bitcoin-core-config-generator
- https://en.bitcoin.it/wiki/Running_Bitcoin#Command-line_arguments
- https://bitcoin.org/en/developer-reference
#### Docker images
- https://github.com/SatoshiPortal/dockers
- https://github.com/kylemanna/docker-bitcoind
- https://github.com/jamesob/docker-bitcoind
- https://github.com/zquestz/docker-bitcoin
- https://github.com/amacneil/docker-bitcoin (archived)
#### Kubernetes configs
- https://github.com/btc1/bitcoin/issues/128
- https://github.com/bonovoxly/gke-bitcoin-node
### Ethereum
- https://wiki.parity.io/Configuring-Parity-Ethereum
- https://paritytech.github.io/parity-config-generator
- https://github.com/ethereum/go-ethereum/wiki/Command-Line-Options
#### Docker
- https://wiki.parity.io/Docker
#### Kubernetes/Helm
- https://github.com/carlolm/kube-parity
- https://github.com/jpoon/kubernetes-ethereum-chart
- https://github.com/helm/charts/tree/master/stable/ethereum
