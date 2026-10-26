#!/usr/bin/env bash
set -e

ssh-keygen -A

dev="$(ip -o link | awk -F': ' '/link\/ether/ { print $2 }' | cut -d@ -f1)"
ip="$(ip -4 -o address show dev "$dev" | awk '{ print $4 }' | cut -d/ -f1)"

exec /usr/sbin/sshd -D -e -o "ListenAddress=$ip"
