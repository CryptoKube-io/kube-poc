# CryptoKube Proof-of-concept

## Prerequisites
- DigitalOcean account w/Kubernetes service
- Kuberenetes cluster created, env var KUBECONFIG=<path/to/kubeconfig.yaml>
- kubectl installed on management host (laptop or otherwise)

## Setup
### Cluster-wide
```bash
./init.sh -c mycluster-kubeconfig.yaml -u myrpcuser -p myrpcpass # set KUBECONFIG, rpcuser+rpcpass secrets
source env.sh

kubectl cluster-info
kubectl create -f namespaces.yaml

git clone https://github.com/coreos/prometheus-operator.git

kubectl create -f prometheus-operator/contrib/kube-prometheus/manifests/ || true
until kubectl get crd servicemonitors.monitoring.coreos.com ; do date; sleep 1; echo ""; done
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
# repeate last "kubectl create" command if some resources fail to create (due to a race condition)
```

### Bitcoin
```bash
kubectl -n bitcoin-testnet create -f bitcoin/testnet/secrets.yaml
kubectl -n bitcoin-testnet create configmap bitcoin-config --from-file=bitcoin.conf=bitcoin/testnet/bitcoin.conf
kubectl -n bitcoin-testnet create -f bitcoin/bitcoin-statefulset.yaml
kubectl -n bitcoin-testnet logs statefulset/bitcoin --tail=5 -f

kubectl -n bitcoin-mainnet create -f bitcoin/mainnet/secrets.yaml
kubectl -n bitcoin-mainnet create configmap bitcoin-config --from-file=bitcoin.conf=bitcoin/mainnet/bitcoin.conf
kubectl -n bitcoin-mainnet create -f bitcoin/bitcoin-statefulset.yaml
kubectl -n bitcoin-mainnet logs statefulset/bitcoin --tail=5 -f
```
### Ethereum
```bash
kubectl -n ethereum-kovan create configmap parity-config --from-file=config.toml=parity/kovan/config.toml
kubectl -n ethereum-kovan create -f parity/parity-statefulset.yaml
kubectl -n ethereum-kovan logs statefulset/parity --tail=5 -f

kubectl -n ethereum-ropsten create configmap parity-config --from-file=config.toml=parity/ropsten/config.toml
kubectl -n ethereum-ropsten create -f parity/parity-statefulset.yaml
kubectl -n ethereum-ropsten logs statefulset/parity --tail=5 -f

kubectl -n ethereum-mainnet create configmap parity-config --from-file=config.toml=parity/mainnet/config.toml
kubectl -n ethereum-mainnet create -f parity/parity-statefulset.yaml
kubectl -n ethereum-mainnet logs statefulset/parity --tail=5 -f

```

## Monitoring
For monitoring, alerting, and visualization I have been using [kube-prometheus](https://github.com/coreos/prometheus-operator/tree/master/contrib/kube-prometheus). It seems to cause issues with namespaces (preventing termination at least). As a workaround, I delete kube-prometheus, modify namespaces, and re-create it.
### Grafana
```bash
kubectl --namespace monitoring port-forward svc/grafana 3000
```
Then visit http://localhost:3000 (initial login is `admin:admin`)
### Prometheus
```bash
kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090     # Prometheus
kubectl --namespace monitoring port-forward svc/alertmanager-main 9093  # Alert Manager
```
Then visit http://locahost:9090 or http://localhost:9093

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
- https://github.com/ethersphere/swarm-kubernetes
- https://github.com/ethersphere/helm-charts
 
