# AUDIT.md — known gaps after I4-I6

A critical pass over the v0.1.0 bindings + scaffold. Captures
what's NOT proven, what's deliberately deferred, and the
gotchas the next contributor (or me, in a later session)
needs to know.

## Fixed in this audit

- **Dead helper-doc comment** in `src/imgui-windows.adb` —
  block at the top referenced a "Helper" function that no
  longer exists (I refactored it inline). Replaced with a real
  note on the Boolean ↔ Bool_C marshalling pattern.
- **Misleading "private child" comment** in `src/imgui.ads` —
  said `Imgui.C` lives as a private child; it's currently
  public. Comment corrected + flagged for future
  re-evaluation.
- **`Null_Context` semantics misstated** — said cimgui's
  `igCreateContext` returns NULL on failure. It actually
  asserts (and aborts) via `IM_ASSERT`. Comment now describes
  Null_Context as a no-current-context marker rather than a
  failure return.
- **`use type Imgui.Context;` workaround** — added a public
  `Is_Null` function so callers don't need to import the
  equality operator just to test for null. Both patterns work;
  `Is_Null` is the friendlier one.

## NOT proven yet — known unknowns

- **`Button` Vec2-by-value ABI** — `Imgui.Widgets.Button`
  passes `Vec2` by value. The Ada record is declared with
  `Convention => C` and cimgui takes `const ImVec2_c size`
  by value. They SHOULD agree on the ABI (both treat the
  struct as a pair of floats in registers/on stack), but
  the smoke test doesn't actually call `Button` — it can't,
  because ImGui asserts when widgets are called outside a
  frame, and a frame needs a windowing backend that sets
  DisplaySize. **Until a real GUI demo exercises Button, the
  ABI compatibility is assumed-but-untested.**
- **`Checkbox`, `Slider_Float` round-trips** — same shape as
  Button. The in-out parameter dance with the aliased
  scratch byte / float should work, but isn't exercised by
  the headless smoke test.
- **Linux + Windows** — the build script + GPR are written
  with cross-platform branches but only macOS has been
  tested. `xcrun` paths are macOS-specific; the script
  falls back to `c++` on Linux but that path is unverified.
  Windows isn't supported in v0.1.0 (the `alire.toml`
  marks it `available = false`).

## Accepted trade-offs

- **Per-call `New_String` / `Free`** — every string-taking
  widget allocates + frees a `chars_ptr` per invocation.
  Under high-frequency widget calls (60fps × many widgets)
  this is heap pressure. Acceptable for v1 because
  correctness > performance; revisit when a real GUI demo
  reveals it as a real bottleneck.
- **Exception-leak risk** — if a C call were to raise into
  Ada (rare; the Ada-C boundary doesn't typically translate
  C++ exceptions), `Free (chars_ptr)` would not run and the
  string would leak. Could be fixed with a controlled-type
  RAII wrapper. Not worth the complexity for v1 given the
  near-zero probability.
- **ImGui label-pointer lifetime** — ImGui internally copies
  window names into its window storage and computes widget
  IDs from labels (no long-lived pointer retained). So
  freeing our `chars_ptr` immediately after the call is
  safe per ImGui's documented behaviour. We don't enforce
  this assumption with a test — it's a property of the
  upstream library.

## Architectural choices to revisit

- **`Imgui.C` public vs private** — currently public so
  consumers and tests can reach in if they need to. Once the
  public API stabilises (covers everything users actually
  ask for), make this private and force everything through
  the public packages.
- **Static-only library kind** — `imgui_ada.gpr` builds a
  static `.a`. Could also produce a dynamic `.dylib` /
  `.so` / `.dll` for users who prefer dynamic linking; left
  as static for now to simplify the macOS bring-up.
- **No GUI demo with windowing backend** — separate binding
  problem (GLFW or SDL). Decoupling this from the cimgui
  binding line is deliberate; conflating them would have
  delayed shipping ImGui by weeks.

## What would force a v0.2.0

- A genuine GUI demo proves the widget ABI (esp. Button's
  Vec2 by value)
- More-of-the-CHARTER-scope widgets bound: Combo,
  RadioButton, InputText, ColorEdit4
- Linux verified end-to-end
- Alire crate published (PR to alire-project/alire-index)
- A windowing-backend binding (GLFW or SDL) so the GUI demo
  is buildable from the same workspace

— Pawl
