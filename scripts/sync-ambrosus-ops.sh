#!/usr/bin/env bash
set -e

server='52.16.114.112'

function sync {
  rsync -avz ~/work/ambrosus/ambrosus-ops "$server:~/" \
    --exclude=ambrosus-ops/.git/ \
    --exclude=ambrosus-ops/terraform/environments/dev/.terraform/ \
    --exclude=ambrosus-ops/terraform/environments/ops/.terraform/ \
    --exclude=ambrosus-ops/terraform/environments/test/.terraform/
  rsync -avz ~/.ssh/ambrosus_deployer_rsa "$server:~/.ssh/"
  rsync -avz ~/.vault-password "$server:~/"
}

echo 'Removing server ~/ambrosus-ops'
ssh "$server" "rm -rf ~/ambrosus-ops"

echo 'Performing initial sync'
sync

while inotifywait -e modify -r ~/work/ambrosus/ambrosus-ops/*; do
 notify-send 'Syncing to amb-ops...' -i network-transmit-receive
  sync
  #pkill xfce4-notifyd
done