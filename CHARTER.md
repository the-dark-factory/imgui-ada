# imgui-ada — charter

Ada bindings to Dear ImGui via cimgui. First entry in the
bindings line — the pattern this project establishes (factory
shape, type-translation conventions, Alire metadata, example
discipline) is meant to be reused by every binding that follows
on the community wishlist.

## Why ImGui first

- **Explicit community demand** — listed by name in ada-lang.io's
  Projects to Work on. Existing Ada binding is outdated and not
  in Alire.
- **C API exists** — cimgui (auto-generated C wrapper to Dear
  ImGui's C++ API) is the standard substrate every non-C++
  binding uses (Rust, Go, Python all bind cimgui, not the C++).
  Ada follows the same pattern.
- **Modest surface for a first artefact** — the core widget set
  is maybe 100 functions + a handful of structs/enums. Big
  enough to test the binding-factory pipeline, small enough to
  ship in a session, not weeks.
- **Cross-platform smoke-tests cleanly** — Bill (macOS M5) is
  the dev box; ImGui has reference backends for Metal/OpenGL
  already, so hello-imgui is achievable without writing a
  graphics backend ourselves.

## Non-goals

- A pure-Ada reimplementation of ImGui. That's a separate
  project, different name, different positioning, aimed at the
  verified-display market. Discussed and parked deliberately.
- Wrapping the C++ API directly. Ada → C++ bindings are painful
  and out of scope. cimgui is the contract.
- Bindings to ImGui add-on libraries (ImPlot, ImGuizmo, etc.)
  in v1. Once the base bindings ship cleanly, those follow as
  separate Alire crates.
- 100% API coverage in v1. The core widget set + the bits
  needed for the hello example are the v1 surface. Coverage
  fills in as users ask.

## Scope of v1

Core surface:
- Lifecycle: `CreateContext`, `DestroyContext`, `NewFrame`, `Render`
- Windowing: `Begin`, `End`, `BeginChild`, `EndChild`
- Layout: `SameLine`, `NewLine`, `Spacing`, `Separator`, `Indent`,
  `Unindent`
- Widgets: `Text`, `Button`, `Checkbox`, `RadioButton`, `Combo`,
  `SliderFloat`, `SliderInt`, `InputText`, `ColorEdit4`
- Containers: `BeginGroup`, `EndGroup`, `TreeNode`, `CollapsingHeader`
- IO: `GetIO`, `GetMousePos`, `IsMouseClicked`, key events
- Style: `StyleColorsDark`, `StyleColorsLight`, basic style getters
- Demo: bind enough to call `ShowDemoWindow` so users can
  validate end-to-end

Pinned to a specific Dear ImGui version (likely whatever cimgui
is built against at vendor time). Version is documented in the
crate metadata; users can override.

## Build shape

- cimgui is linked as a system library OR vendored + built as
  part of the Alire crate. Decision deferred to I5 once we
  understand the macOS / Linux / Windows install conventions.
- The Ada layer is `.ads`-only over `extern "C"` symbols from
  libcimgui. No thick wrapper layer initially; idiomatic Ada
  helpers come second.
- Examples build against the crate via Alire, not via in-tree
  source paths — the example IS the install test.

## Repository layout (planned)

```
imgui-ada/
├── CHARTER.md           — this
├── README.md            — public-facing one-pager
├── LICENSE              — MIT
├── alire.toml           — crate metadata
├── imgui_ada.gpr        — GPR build file
├── src/
│   ├── imgui.ads        — top-level package, lifecycle
│   ├── imgui-widgets.ads — widgets
│   ├── imgui-io.ads     — IO / events
│   ├── imgui-style.ads  — style
│   └── imgui-c.ads      — thin extern "C" layer (internal)
├── vendor/
│   └── cimgui/          — submodule or vendored source
├── examples/
│   ├── hello/
│   │   ├── hello.adb
│   │   └── hello.gpr
│   └── demo/
│       ├── demo.adb     — wraps cimgui's ShowDemoWindow
│       └── demo.gpr
└── tests/
    └── (gnattest / AUnit harness as the binding grows)
```

## What I'd defer thinking about until later

- Whether to publish as `imgui` or `imgui_bindings` on Alire.
  Decide at I7 (publish step) once I see what crate names are
  available + the convention other recently-published bindings
  use.
- Whether to provide a thicker Ada-idiomatic wrapper layer
  (e.g. `Begin_Window` taking an Ada `String` instead of a
  `chars_ptr`). Probably yes eventually; not in v1.
- Wide-character / Unicode handling. ImGui's UTF-8 model is
  reasonable; the binding inherits it. Surface as `String`
  (assumed UTF-8) in idiomatic helpers.
- Async / parallel use — ImGui is single-threaded by design.
  Document, don't fight it.

## What this binding establishes for the line

The output of this work is the *playbook*:

1. cimgui-style C API found / vendored
2. Type-translation rules: `c.int` → `Interfaces.C.int`, `char*`
   → `chars_ptr`, struct → record with `Convention => C`, enum
   → Ada enum
3. Naming convention: cimgui's `igBegin` / `igButton` are
   already de-prefixed in cimgui; Ada side renders as `Begin_`
   or `Button` per Ada convention (avoiding reserved words
   like `Begin`)
4. Alire crate metadata pattern
5. Example discipline: one minimal example, one demo wrapper,
   docs reference both
6. Repository layout, gitignore, license file

Once this works for ImGui, the same pattern handles STB, Raylib,
OpenCV, the GTKAda modernization, AWS rough-edge filling,
and the rest of the wishlist — at factory pace.

— Pawl
