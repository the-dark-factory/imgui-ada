#!/usr/bin/env bash
# Build cimgui + Dear ImGui from vendor/cimgui as a static library.
#
# Output: vendor/cimgui/libcimgui.a
#
# Why this exists (instead of using cimgui's own Makefile or CMakeLists):
# cimgui's Makefile invokes /usr/bin/c++ which on macOS doesn't pick up
# the SDK paths reliably, and CMake isn't installed by default. This
# script uses `xcrun clang++` on macOS and a sensible `c++` on Linux,
# both of which compile cleanly without extra dependencies.

set -euo pipefail
cd "$(dirname "$0")/.."

VENDOR="vendor/cimgui"
SOURCES=(
  "$VENDOR/cimgui.cpp"
  "$VENDOR/imgui/imgui.cpp"
  "$VENDOR/imgui/imgui_draw.cpp"
  "$VENDOR/imgui/imgui_demo.cpp"
  "$VENDOR/imgui/imgui_tables.cpp"
  "$VENDOR/imgui/imgui_widgets.cpp"
)

CXXFLAGS=(
  -O2
  -fno-exceptions
  -fno-rtti
  -fPIC
  -I"$VENDOR"
  -I"$VENDOR/imgui"
  -DIMGUI_IMPL_API="extern \"C\""
)

UNAME="$(uname -s)"
case "$UNAME" in
  Darwin)
    CXX=(xcrun clang++)
    SDK_PATH="$(xcrun --show-sdk-path)"
    CXXFLAGS+=( -isysroot "$SDK_PATH" )
    AR=(ar -rc)
    ;;
  Linux)
    CXX=(c++)
    AR=(ar -rc)
    ;;
  *)
    echo "Unsupported OS: $UNAME" >&2
    exit 1
    ;;
esac

OBJS=()
for src in "${SOURCES[@]}"; do
  obj="${src%.cpp}.o"
  echo "  cc   $src"
  "${CXX[@]}" "${CXXFLAGS[@]}" -c "$src" -o "$obj"
  OBJS+=( "$obj" )
done

OUT="$VENDOR/libcimgui.a"
rm -f "$OUT"
echo "  ar   $OUT"
"${AR[@]}" "$OUT" "${OBJS[@]}"

# Print a quick fingerprint so callers can verify
ls -la "$OUT"
echo
echo "Done. Add to linker:"
echo "  -L$VENDOR -lcimgui -lc++"
