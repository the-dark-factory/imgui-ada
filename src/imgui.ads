--  Ada bindings to Dear ImGui via cimgui.
--
--  This is the root package of the binding. It defines the
--  opaque Context type and exposes the lifecycle calls that
--  every program using ImGui must make:
--
--    Ctx := Create_Context;
--    --  per frame:
--      New_Frame;
--      --  ... call widgets from Imgui.Windows / Imgui.Widgets ...
--      Render;
--      --  ... let the renderer backend draw the resulting data ...
--    Destroy_Context (Ctx);
--
--  The thin extern "C" surface lives in child package `Imgui.C`.
--  Public packages call into it. Users of this library should
--  not need to import `Imgui.C` directly — if you find yourself
--  reaching for it, the public API is probably missing a binding
--  we should add. (The child is currently public for testability;
--  a future revision may make it private once the public surface
--  has stabilised.)

with System;

package Imgui is

   --  Opaque handle to an ImGui context. ImGui is single-context-
   --  at-a-time globally (you set the "current" context with
   --  internal cimgui calls), but you can construct multiple
   --  contexts and swap between them. Most apps create one.
   type Context is private;

   --  Sentinel for a not-yet-created or already-destroyed context.
   --  Note: cimgui's `igCreateContext` doesn't return NULL in
   --  practice — it asserts (and aborts) on allocation failure
   --  rather than gracefully failing. Null_Context is therefore
   --  most useful as a "no current context" marker before
   --  Create_Context runs, or after Destroy_Context.
   Null_Context : constant Context;

   --  Test whether a Context handle is null. Avoids forcing
   --  consumers to write `use type Imgui.Context;` just to
   --  compare against Null_Context.
   function Is_Null (Ctx : Context) return Boolean;

   --  Create an ImGui context. The optional Shared_Font_Atlas
   --  parameter lets multiple contexts share a font atlas; pass
   --  Null_Address for the common single-context case.
   function Create_Context
     (Shared_Font_Atlas : System.Address := System.Null_Address)
      return Context;

   --  Destroy the given context. Pass Null_Context to destroy the
   --  currently-active context (matches cimgui's igDestroyContext
   --  behaviour when called with NULL).
   procedure Destroy_Context (Ctx : Context := Null_Context);

   --  Begin a new ImGui frame. Call once per render loop, after
   --  the backend has fed input state but before any widget calls.
   procedure New_Frame;

   --  Finalise the frame. Builds the draw lists ImGui's renderer
   --  backend will consume. Call once per render loop, after the
   --  last widget call.
   procedure Render;

private

   --  Context is just an opaque pointer at the C level. We
   --  represent it as System.Address so it can be passed around
   --  without copying, and so Null_Context maps to Null_Address.
   type Context is new System.Address;

   Null_Context : constant Context := Context (System.Null_Address);

end Imgui;
