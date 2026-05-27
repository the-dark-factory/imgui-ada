# Prior art survey — Ada bindings for Dear ImGui

Survey: 2026-05-27. Performed during I2.

## What exists

### Cre8or/ImGui-Ada

- Repo: https://github.com/Cre8or/ImGui-Ada
- **License: NONE** (no LICENSE file in repo)
- Stars: 6, forks: 2
- **Last push: 2023-08-25** (2.5+ years stale)
- **Pinned to Dear ImGui v1.88** (current cimgui is v1.92.8 —
  about 10 minor versions of API drift)
- Open issues: 2
- Size: 1.5 MB (vendored ImGui + cimgui source included)

#### Structure (informative for our design)

```
src/
├── binding/                          — Ada-side
│   ├── dear_imgui.ads/.adb           — top-level
│   ├── dear_imgui-api.ads            — extern "C" surface
│   ├── dear_imgui-contexts.ads/.adb  — lifecycle
│   ├── dear_imgui-windows.ads/.adb   — Begin/End
│   ├── dear_imgui-widgets.ads/.adb   — buttons, text, sliders
│   ├── dear_imgui-drawing.ads/.adb   — draw list ops
│   ├── dear_imgui-inputs.ads/.adb    — IO/events
│   ├── dear_imgui-types.ads          — record/enum translations
│   ├── dear_imgui-backend_glfw.ads/.adb     — GLFW backend
│   ├── dear_imgui-backend_opengl3.ads/.adb  — OpenGL3 backend
│   ├── backends/imgui_impl_glfw_h.ads/.adb
│   ├── backends/imgui_impl_opengl3_h.ads
│   └── generic_imgui.ads
├── cimgui_v1.88/                     — vendored cimgui
└── imgui_v1.88/                      — vendored Dear ImGui
```

15 `.ads` + 11 `.adb` files — moderate API coverage with Ada-
idiomatic wrappers (not just thin bindings — they wrote
package-by-package wrappers per concept).

### Other Ada bindings

GitHub search + Alire index probe (2026-05-27): **no other Ada
bindings to ImGui found.** Cre8or is the only one.

Alire index has `image_io` and `image_random` under `index/im/`
but nothing for `imgui`. The crate name is open.

### Adjacent tooling worth knowing

- **cimgui** (https://github.com/cimgui/cimgui) — the C API
  wrapper we're vendoring. Auto-generated against Dear ImGui;
  pins to specific upstream versions.
- **dear_bindings** (https://github.com/dearimgui/dear_bindings)
  — official-ish alternative to cimgui that produces a C API
  PLUS metadata for binding-generators. Worth a follow-up
  evaluation; cimgui is the default for v1 because every other
  Ada-language binding effort to ImGui has used it.

## Decision (I3)

**From-scratch generation against current cimgui** — not a fork of Cre8or.

### Why

1. **License unclear** — Cre8or's repo has no LICENSE file. We
   can't ethically or legally fork without explicit permission;
   reaching out to ask would slow us down for ambiguous value.
2. **Targets ImGui v1.88; the world is on v1.92.8** — over two
   years of API drift. Forking means a v1.88-→ v1.92.8 migration
   pass as the first work item. From-scratch against v1.92.8 is
   the same effort with a cleaner result.
3. **Stale 2.5 years, no recent maintainer activity** — a fork
   inherits no momentum.
4. **The community asked for a *current* Alire-installable
   binding**, not a resurrection. We deliver what was asked for.
5. **Establishes the binding-factory pattern with no legacy
   baggage** — the conventions, file layout, generation pipeline
   shape the project independently of any historical choices.

### What we DO inherit from Cre8or — conceptually only

These are public API design choices, not code:

- **Package decomposition by concept** (windows, widgets,
  drawing, inputs, types) — good shape; we adopt the same.
- **Separate `.api` package for the raw `extern "C"` surface**
  with idiomatic wrappers on top — sound layering.
- **Backend packages per renderer / windowing toolkit** — we'll
  do similar but pick our own first backend (likely SDL2 since
  it's broadly portable and has a clean C API itself).

### What we explicitly do differently

- License: MIT, declared upfront in `LICENSE`, matches upstream
  Dear ImGui and cimgui.
- Pinned to current cimgui (Dear ImGui v1.92.8, docking branch).
- Vendor cimgui as a submodule or fetched artefact, not as a
  copy of `imgui_v1.88/` sitting in-tree.
- Alire-installable from day one. `alire.toml` lands with the
  first runnable example.
- Naming: `imgui` package root (not `dear_imgui`) — shorter,
  matches the cimgui prefix convention more cleanly, fewer
  characters in every call site.

### What we will NOT do without re-deciding

- Reproduce Cre8or's source code line-for-line, even by chance.
  The repo is reference material, not a copy source. All Ada
  code is written fresh.
- Wrap the C++ API directly. cimgui is the contract.
- Ship our binding pinned to a wrong/stale ImGui — version
  alignment with cimgui is the v1 quality gate.
