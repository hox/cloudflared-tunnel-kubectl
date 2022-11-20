#!/bin/bash
echo ::group::Downloading latest Cloudflared
wget -q -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared
mkdir -p log
touch log/cloudflared.log
echo ::endgroup::

echo ::group::Downloading latest kubectl
curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
mkdir -p ~/.kube
echo $kubeconfig | base64 -d > ~/.kube/config
echo ::endgroup::

echo ::group::Start Cloudflared Tunnel
echo "127.0.0.1 kubernetes" | sudo tee -a /etc/hosts
./cloudflared access tcp --id $cloudflared_service_token_id --secret $cloudflared_service_token_secret -T $cloudflared_host_address -L kubernetes:6443 --log-level debug --logfile log >/dev/null 2>&1 < /dev/null &
curl --retry 5 --retry-connrefused https://kubernetes:6443 >/dev/null 2>&1 < /dev/null &
tail -f log/cloudflared.log | while read LOGLINE
do
    [[ "${LOGLINE}" == *"tunnel->origin"* ]] && pkill -P $$ tail
done
echo ::endgroup::

echo ::group::Run kubectl
KUBECONFIG=~/kube/config kubectl $kubectl_args
echo ::endgroup::
