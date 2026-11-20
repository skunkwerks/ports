#!/bin/sh
#
# Self test for the native, LIEF-free single executable application injector
# (files/patch-src_node__sea__bin.cc).
#
# Builds a real single executable application with "node --build-sea", runs it,
# and checks that the injected executable is still a well formed FreeBSD ELF:
# the program header table has to stay inside the first page and the original
# FreeBSD notes have to survive byte for byte, or the kernel and rtld stop
# recognising the binary.
#
# Usage: NODE=/path/to/node sh sea-selftest.sh <workdir>

set -eu

NODE=${NODE:?NODE must point at the node executable to test}
READELF=${READELF:-/usr/bin/readelf}
WORKDIR=${1:?usage: sea-selftest.sh <workdir>}

fail() {
	echo "sea-selftest: FAIL: $*" >&2
	exit 1
}

rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# An application that exercises both the bundled main script and an asset, so
# that a truncated or misplaced blob shows up as a failure rather than as a
# binary that merely starts.
cat > hello.js <<'EOJS'
const { getAsset } = require('node:sea');
const greeting = new TextDecoder().decode(getAsset('greeting.txt')).trim();
const args = process.argv.filter((a) => a === 'one' || a === 'two');
console.log(`sea-selftest ${greeting} args=${args.join(',')}`);
EOJS
printf 'hello from the bundled asset\n' > greeting.txt
cat > sea-config.json <<'EOJSON'
{
  "main": "hello.js",
  "output": "hello-sea",
  "disableExperimentalSEAWarning": true,
  "assets": { "greeting.txt": "greeting.txt" }
}
EOJSON

echo "sea-selftest: building the single executable application"
"${NODE}" --build-sea sea-config.json || fail "node --build-sea failed"
[ -x hello-sea ] || fail "node --build-sea did not produce an executable"

echo "sea-selftest: running it"
output=$(./hello-sea one two) ||
	fail "the single executable application did not run"
expected='sea-selftest hello from the bundled asset args=one,two'
[ "${output}" = "${expected}" ] ||
	fail "unexpected output: '${output}' (expected '${expected}')"

echo "sea-selftest: checking the injected executable"
"${READELF}" -h hello-sea > header.txt 2>/dev/null ||
	fail "readelf cannot parse the injected executable"

# FreeBSD's image activator only looks for the program header table in the
# first page (__elfN(phdr_in_zero_page) in sys/kern/imgact_elf.c).
phoff=$(awk '/Start of program headers/ { print $5 }' header.txt)
phnum=$(awk '/Number of program headers/ { print $5 }' header.txt)
phentsize=$(awk '/Size of program headers/ { print $5 }' header.txt)
table_end=$((phoff + phnum * phentsize))
[ "${table_end}" -le 4096 ] ||
	fail "the program header table ends at ${table_end}, outside the first page"

# The blob is mapped through a PT_NOTE that the injector adds next to the ones
# the executable already had.
notes=$("${READELF}" -lW hello-sea | awk '$1 == "NOTE" { n++ } END { print n + 0 }')
[ "${notes}" -ge 2 ] ||
	fail "expected an injected PT_NOTE, found ${notes} NOTE segments"

# The bug that motivated this injector: rewriting an ELF with a general purpose
# library grew n_namesz of every note it did not recognise, and the FreeBSD
# kernel and rtld match notes by exact n_namesz.
"${READELF}" -n "${NODE}" 2>/dev/null | grep FreeBSD > node-notes.txt ||
	fail "the node executable has no FreeBSD notes to compare against"
"${READELF}" -n hello-sea 2>/dev/null | grep FreeBSD > sea-notes.txt ||
	fail "the injected executable lost its FreeBSD notes"
cmp -s node-notes.txt sea-notes.txt ||
	fail "the FreeBSD notes changed during injection"

# Injecting twice must be refused rather than producing two blobs.
cat > sea-config-again.json <<'EOJSON'
{
  "main": "hello.js",
  "output": "hello-sea-again",
  "disableExperimentalSEAWarning": true,
  "executable": "hello-sea"
}
EOJSON
if "${NODE}" --build-sea sea-config-again.json > again.log 2>&1; then
	fail "injecting into an executable that already carries a blob succeeded"
fi
grep -q 'already exists' again.log ||
	fail "re-injection failed for the wrong reason: $(cat again.log)"

# An executable without reserved program header slots must be rejected with a
# clear message instead of being silently corrupted.
cat > sea-config-nopad.json <<'EOJSON'
{
  "main": "hello.js",
  "output": "nopad-sea",
  "disableExperimentalSEAWarning": true,
  "executable": "/bin/sh"
}
EOJSON
if "${NODE}" --build-sea sea-config-nopad.json > nopad.log 2>&1; then
	fail "injecting into an executable without reserved slots succeeded"
fi
grep -q 'reserved program header slots' nopad.log ||
	fail "injection without reserved slots failed for the wrong reason: $(cat nopad.log)"
[ ! -e nopad-sea ] || fail "a corrupted executable was written anyway"

echo "sea-selftest: PASS"
