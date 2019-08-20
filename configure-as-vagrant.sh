#!/usr/bin/env bash

set -euxo pipefail

function latest_non_ea_openjdk_version() {
  safecmd sdk list java | tr -d ' ' | grep -oE "[^|]+-open$" | sort -V | grep -v ".ea." | tail -1
}

function safecmd() {
    set +u
    eval "$@"
    set -u
}

SDKMAN_HOME="${HOME}/.sdkman"
SDKMAN_CFGFILE="${SDKMAN_HOME}/etc/config"
SDKMAN_INITFILE="${SDKMAN_HOME}/bin/sdkman-init.sh"
SDKMAN_JAVA_HOME="${HOME}/.sdkman/candidates/java/current"

declare -x

command -v sdk || {
  curl -s "https://get.sdkman.io" | bash
  safecmd source "${SDKMAN_INITFILE}"
}

latest_version=$(latest_non_ea_openjdk_version)

command -v java || {
    echo "sdkman_auto_answer=true" > "${SDKMAN_CFGFILE}"
    safecmd sdk install java "${latest_version}"
    export JAVA_HOME="${SDKMAN_JAVA_HOME}"
}

current_version=$(java --version | head -1 | cut -d ' ' -f 2)

case "${latest_version}" in
  "${current_version}*")
    echo "Java is up-to-date"
  ;;
  *)
    echo "Java is not up-to-date (current:${current_version}, latest:${latest_version})"
    safecmd sdk install java "${latest_version}"
    safecmd sdk default java "${latest_version}"
  ;;
esac

[ -d FlameGraph ] || git clone --depth=1 https://github.com/brendangregg/FlameGraph

[ -d perf-map-agent ] || git clone --depth=1 https://github.com/codewise/perf-map-agent.git --branch java-9-plus

pushd perf-map-agent
git clean -dfx
cmake .
make
popd

[ -d flamescope ] || git clone --depth=1 https://github.com/Netflix/flamescope

pushd flamescope
git clean -dfx
pip3 install setuptools
pip3 install -r requirements.txt
popd

[ -d async-profiler ] || git clone --depth=1 https://github.com/jvm-profiling-tools/async-profiler

pushd async-profiler
git clean -dfx
make build build/libasyncProfiler.so
