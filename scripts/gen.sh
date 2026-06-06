#!/usr/bin/env bash
#
# gen.sh — dump the full cimgui C-API as an Ada spec from the vendored header,
# deterministically, for use as a re-vendoring reference. Output lands in gen/,
# NOT src/.
#
# STATUS (2026-06-06): this binding is NOT a machine-generated drop-in like
# box2d-ada. The committed src/ is a HAND-AUTHORED, Ada-idiomatic hierarchical
# wrapper (package Imgui + Imgui.C / Imgui.Types / Imgui.Windows / Imgui.Widgets
# / Imgui.Style) that deliberately covers a small, curated slice of cimgui's
# ~1000-function surface. `-fdump-ada-spec` over cimgui.h instead emits a single
# flat 14k-line `cimgui_h` package binding every `ig*` symbol with path-based
# names — a completely different artefact. So this script does NOT reproduce
# src/, and `git diff src/` after a run is expected to be (and stays) empty
# because the script never writes there. It is a REFERENCE GENERATOR: it
# regenerates gen/cimgui_h.ads + its with-closure so that, when cimgui is
# re-vendored, you have the full machine view of the new C surface to hand-port
# the relevant additions into src/ against. The hand-authored src/ is the moat
# and the authoritative binding; gen/ is scaffolding. (cf. box2d-ada/scripts/
# gen.sh, which IS byte-faithful because that binding is itself pure fdump
# output; this is the hand-wrapper case, like llama-ada but more so — there the
# wrapper sits over a generated base, here the whole binding is the wrapper.)
#
# Why a separate generator compiler (gcc-15, C++ mode): cimgui.h is a C API in a
# header that pulls <stdio.h> and is built with `extern "C"` guards. The Alire
# GCC is built for an older darwin, and its pre-fixed <stdio.h> no longer matches
# the current macOS SDK ('FILE' does not name a type) — it produces zero specs
# here. So generation uses a current-SDK-matched gcc (Homebrew gcc-15 by
# default) in C++ mode purely for the fdump step; the Ada still builds with the
# Alire toolchain. We define CIMGUI_DEFINE_ENUMS_AND_STRUCTS so the enum/struct
# definitions (guarded out by default) are emitted, giving the full type surface.
#
# Steps:
#   1. gcc -fdump-ada-spec (C++ mode, via a wrapper .cpp) over cimgui.h.
#   2. Keep the transitive with-closure (incl. `limited with`) from the cimgui_h
#      project-header root; drop the system-header spillover.
#   3. Write the kept specs to gen/ (wiped first); src/ is never touched.
#
# Requirements: a current-SDK gcc with -fdump-ada-spec (override with GEN_GCC),
# and the vendored cimgui at vendor/cimgui (cimgui.h is committed there).
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

inc="$repo_root/vendor/cimgui"
hdr="$inc/cimgui.h"
[ -f "$hdr" ] || { echo "error: $hdr not found — is vendor/cimgui populated?" >&2; exit 1; }

gen_gcc="${GEN_GCC:-/opt/homebrew/bin/gcc-15}"
command -v "$gen_gcc" >/dev/null 2>&1 || gen_gcc="gcc-15"
command -v "$gen_gcc" >/dev/null 2>&1 || {
  echo "error: no fdump-capable gcc ($gen_gcc). Install one (brew install gcc) or set GEN_GCC." >&2; exit 1; }

# macOS SDK sysroot. The default MacOSX.sdk symlink has been broken on some
# hosts, so prefer the explicit versioned path and fall back to the symlink,
# then to xcrun.
sysroot_flag=()
for sdk in /Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk \
           /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk; do
  [ -d "$sdk" ] && { sysroot_flag=(-isysroot "$sdk"); break; }
done
if [ ${#sysroot_flag[@]} -eq 0 ] && sdk="$(xcrun --show-sdk-path 2>/dev/null)" && [ -n "$sdk" ]; then
  sysroot_flag=(-isysroot "$sdk")
fi

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
printf '#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS\n#include "cimgui.h"\n' > "$work/gen.cpp"
echo ">> fdump-ada-spec over cimgui.h  (gcc: $gen_gcc)"
# fdump still emits the specs even when gcc returns non-zero (benign warnings).
( cd "$work" && "$gen_gcc" -c -fdump-ada-spec -x c++ -std=c++17 -fpermissive \
    -I "$inc" "${sysroot_flag[@]}" gen.cpp ) 2>/dev/null || true

cd "$work"
compgen -G "cimgui_h.ads" >/dev/null || { echo "error: fdump produced no cimgui_h.ads" >&2; exit 1; }

# Transitive with-closure from the cimgui_h project-header root. Follow both
# `with X;` and `limited with X;` to generated specs present here (lowercase,
# single-unit names); runtime units (Interfaces.C, System, …) have dots or no
# local file and drop out naturally. The wrapper TU's own spec (gen_cpp.ads) is
# not part of the root and is not withed by cimgui_h, so it is excluded.
keep=(cimgui_h.ads)
in_keep(){ local x="$1" k; for k in "${keep[@]}"; do [ "$k" = "$x" ] && return 0; done; return 1; }
changed=1
while [ "$changed" = 1 ]; do changed=0
  for f in "${keep[@]}"; do
    while IFS= read -r c; do [ -n "$c" ] || continue
      if [ -f "$c" ] && ! in_keep "$c"; then keep+=("$c"); changed=1; fi
    done < <(awk '
      tolower($1)=="with" { w=$2 }
      tolower($1)=="limited" && tolower($2)=="with" { w=$3 }
      w!="" { sub(/;.*/,"",w); if (w !~ /\./) print tolower(w)".ads"; w="" }
    ' "$f")
  done
done

dest="$repo_root/gen"
mkdir -p "$dest"
rm -f "$dest"/*.ads
for f in "${keep[@]}"; do cp "$f" "$dest/"; done

all_n=$(ls -1 *.ads | wc -l | tr -d ' ')
echo ">> kept ${#keep[@]} of $all_n generated specs (pruned $((all_n - ${#keep[@]})) system-closure spillovers) into gen/:"
printf '%s\n' "${keep[@]}" | sort | sed 's/^/   /'
echo ">> hand-authored src/ left untouched (it is the authoritative binding; gen/ is a re-vendoring reference)"
