# imgui-ada

Ada bindings to [Dear ImGui](https://github.com/ocornut/imgui)
via [cimgui](https://github.com/cimgui/cimgui).

Aimed at the gap on the Ada community's
[Projects to Work on](https://ada-lang.io/docs/projects-to-work-on/)
list — an up-to-date, Alire-installable set of Ada bindings for
ImGui with worked examples.

## Status

v0.1.0-dev. End-to-end works on macOS:

```
$ ./scripts/build-cimgui.sh           # one-time, builds vendor/cimgui/libcimgui.a
$ gprbuild -P imgui_ada.gpr           # builds lib/libimgui_ada.a
$ gprbuild -P examples/smoke/smoke.gpr
$ ./examples/smoke/bin/smoke
imgui-ada smoke test starting
  Create_Context OK
  Style_Colors_Dark OK
  Destroy_Context OK
imgui-ada smoke test passed
```

What works:
- `Create_Context` / `Destroy_Context`
- `Style_Colors_Dark` / `Style_Colors_Light`
- `Begin_Window` / `End_Window`
- `Show_Demo_Window`
- `Text` / `Button` / `Checkbox` / `Slider_Float`
- `New_Frame` / `Render` (binding present; needs a windowing
  backend to actually call without ImGui asserting)

What's NOT done yet:
- A working GUI example with a backend (GLFW/SDL/Metal). The
  smoke test is headless — it proves linkage end-to-end but
  doesn't open a window.
- Combo, RadioButton, InputText, ColorEdit4 (CHARTER scope but
  not yet bound).
- Linux + Windows verification — code is portable but the
  build scripts are macOS-tested only.

See [CHARTER.md](CHARTER.md) for the full plan and decisions.

## Build (development)

Prerequisites:
- macOS with Xcode Command Line Tools (or Linux with `c++`).
- GNAT 14+ via Alire (`alr toolchain --select`).
- ~/.alire/bin in PATH.

```
git clone https://github.com/the-dark-factory/imgui-ada
cd imgui-ada
./scripts/build-cimgui.sh    # compiles vendor/cimgui/libcimgui.a (~5s on M-series)
gprbuild -P imgui_ada.gpr    # compiles lib/libimgui_ada.a
```

Consumers `with "imgui_ada.gpr"` from their own GPR — the linker
flags (`-lcimgui`, libc++ syslibroot on macOS) propagate
automatically via `Linker_Options`.

## Regenerating the binding

Unlike a pure `-fdump-ada-spec` binding (see e.g. `box2d-ada`), the
Ada side here is **hand-authored**: `src/` is a small, curated,
Ada-idiomatic tree (`Imgui` + `Imgui.C` / `Imgui.Types` /
`Imgui.Windows` / `Imgui.Widgets` / `Imgui.Style`) that wraps a
deliberately-chosen slice of cimgui's ~1000-function surface. It is
the authoritative binding and is **not** machine-reproducible — do
not expect a generator to emit it.

What `scripts/gen.sh` does provide is a **re-vendoring reference**:
it runs `-fdump-ada-spec` over `vendor/cimgui/cimgui.h` and writes
the full machine view of the C surface to `gen/` (gitignored):

```sh
./scripts/gen.sh        # -> gen/cimgui_h.ads (+ its with-closure)
```

`gen/cimgui_h.ads` is a single flat ~14k-line `cimgui_h` package
binding every `ig*` symbol with path-based names. When cimgui is
bumped under `vendor/`, regenerate `gen/` and diff it to see what
changed in the C API, then hand-port the relevant additions into
`src/`. `gen/` is scaffolding, never shipped; `src/` is the moat.

Because cimgui.h pulls `<stdio.h>` and the Alire-shipped gcc's
pre-fixed `<stdio.h>` no longer matches the current macOS SDK
(`'FILE' does not name a type` — it emits nothing), `gen.sh` uses
Homebrew **gcc-15** in C++ mode for the fdump step only (override
with `GEN_GCC`). The Ada still builds with the Alire toolchain.
`src/` is never touched, so `git diff src/` after a run is empty.

## License

MIT — matches upstream Dear ImGui and cimgui.

## Thanks

Dedicated to the Ada community who have answered countless
questions, corrected countless mistakes, and saved countless
hours of head-scratching over the decades. See [THANKS.md](THANKS.md).
