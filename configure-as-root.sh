#!/usr/bin/env bash

set -veuxo pipefail

[ -f apt.uptodate ] || (apt-get update && touch apt.uptodate)

apt-get install --no-install-recommends -y \
  zip unzip \
  python3-pip \
  cmake build-essential \
  linux-tools-common linux-tools-generic linux-tools-$(uname -r)

#
# If we don't do this, the default stack depth will be 127
#
sysctl -w kernel.perf_event_max_stack=1024

sudo -u vagrant --set-home -s /vagrant/configure-as-vagrant.sh

