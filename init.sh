#\!/bin/sh

function help {
  echo "Usage: $0 -b [bitcoin|ethereum] -n <network> -u <rpcuser> -p <rpcpass>"
  echo ''
}

[[ $# -eq 0 ]] && help && exit 0

while [[ $# -gt 0 ]]; do
  arg="$1"
  case $arg in
    -u|--rpcuser)
      input_rpcuser="$2"
      shift; shift ;;
    -p|--rpcpass)
      input_rpcpass="$2"
      shift; shift ;;
    *)
      echo "Unknown argument $arg"
      exit 1 ;;
  esac
done

if [ ! -f $input_config ]; then
  echo "$input_config not found. Exiting"
  exit 1
fi

if [ ! -f env.sh ]; then
  echo "KUBECONFIG=$input_config" >> env.sh
else
  sed -i "s/KUBECONFIG=.*/KUBECONFIG=$input_config/" env.sh
fi
echo "to set KUBECONFIG: source env.sh"

rpcuser=$(echo -n rpcuser_txt | base64)
rpcpass=$(echo -n rpcpass_txt | base64)
unset input_rpcuser input_rpcpass

sed -i "s/rpcuser:.*/rpcuser: $rpcuser/" bitcoin-secrets.yaml && echo "set rpcuser"
sed -i "s/rpcpass:.*/rpcpass: $rpcpass/" bitcoin-secrets.yaml && echo "set rpcpass"

source <(kubectl completion bash) && echo "enabled kubectl tab-completion"
[[ $(grep -c 'kubectl completion bash' ~/.bashrc) -eq 0 ]] && echo 'source <(kubectl completion bash)' >> ~/.bashrc && echo "added kubectl tab-completion in ~/.bashrc"
