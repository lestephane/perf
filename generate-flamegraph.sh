#!/usr/bin/env bash
# Usage:
# sudo generate-flamegraph.sh

set -veuxo pipefail

function usage() {
cat <<-EOF
Usage: $0 COMMAND

Environment:
  - JAVA_HOME (default: latest non-ea openjdk)
  - AGENT_HOME (default: codewise/perf-map-agent --branch java-9-plus)
  - PERF_COLLAPSE_OPTS (default: --all) <http://psy-lob-saw.blogspot.com/2017/02/flamegraphs-intro-fire-for-everyone.html>
    	--pid		# include PID with process names [1]
      --tid		# include TID and PID with process names [1]
      --inline	# un-inline using addr2line
      --all		# all annotations (--kernel --jit)
      --kernel	# annotate kernel functions with a _[k]
      --jit		# annotate jit functions with a _[j]
      --context	# adds source context to --inline
      --addrs		# include raw addresses where symbols can't be found
      --event-filter=EVENT	# event name filter\n
EOF
  exit 1
}

[ $# -gt 0 ] || usage

export AGENT_HOME=$(readlink -e $(dirname $(dirname $(find -name "libperfmap.so"))))
declare -x | grep _HOME

echo HOME=${HOME}
NOW=$(date --iso-8601=minutes)
PERFDIR="/tmp"
PERFNAME="perf.${NOW}"
PERFPREFIX="${PERFDIR}/${PERFNAME}"
FLAMESCOPEDIR="${HOME}/flamescope/examples"

#find /tmp -maxdepth 1 -name "*.map"
perf record -F 99 -a -g -o "${PERFPREFIX}.data" -- "$@"
#./FlameGraph/jmaps -u # -u = include inlined symbols
#find /tmp -maxdepth 1 -name "*.map"

#chown root /tmp/perf-*.map
#chown root perf.data

perf script -i "${PERFPREFIX}.data" | tee "${FLAMESCOPEDIR}/${PERFNAME}" > "${PERFPREFIX}.stacks"
cat "${PERFPREFIX}.stacks" | ./FlameGraph/stackcollapse-perf.pl "${PERF_COLLAPSE_OPTS:---all}" > "${PERFPREFIX}.collapsed"
cat "${PERFPREFIX}.collapsed" | ./FlameGraph/flamegraph.pl --color=java --hash > "${PERFPREFIX}.flamegraph.svg"

cp "${PERFPREFIX}"* /vagrant

#rm /tmp/perf-*.map
#rm perf.data
