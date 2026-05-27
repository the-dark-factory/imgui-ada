# ada-imgui

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
$ gprbuild -P ada_imgui.gpr           # builds lib/libada_imgui.a
$ gprbuild -P examples/smoke/smoke.gpr
$ ./examples/smoke/bin/smoke
ada-imgui smoke test starting
  Create_Context OK
  Style_Colors_Dark OK
  Destroy_Context OK
ada-imgui smoke test passed
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
git clone https://github.com/the-dark-factory/ada-imgui
cd ada-imgui
./scripts/build-cimgui.sh    # compiles vendor/cimgui/libcimgui.a (~5s on M-series)
gprbuild -P ada_imgui.gpr    # compiles lib/libada_imgui.a
```

Consumers `with "ada_imgui.gpr"` from their own GPR — the linker
flags (`-lcimgui`, libc++ syslibroot on macOS) propagate
automatically via `Linker_Options`.

## License

MIT — matches upstream Dear ImGui and cimgui.

## Thanks

Dedicated to the Ada community who have answered countless
questions, corrected countless mistakes, and saved countless
hours of head-scratching over the decades. See [THANKS.md](THANKS.md).
