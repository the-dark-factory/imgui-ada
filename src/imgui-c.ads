--  Thin Ada bindings to cimgui's extern "C" surface.
--
--  This package is INTERNAL — public Imgui packages call into
--  it; user code should not need to. Every declaration here
--  corresponds 1:1 to a cimgui symbol, with C types preserved.
--
--  Naming convention: cimgui prefixes everything with `ig`
--  (e.g. `igBegin`, `igButton`). We keep that prefix in the
--  Ada names so a grep against cimgui.h cross-references
--  cleanly. The public packages adapt to Ada idioms.
--
--  Pinned to cimgui v1.92.8 / Dear ImGui 19280 (docking branch).
--  When cimgui is re-vendored, this file is the only Ada-side
--  thing that needs updating — provided the public-API shape
--  hasn't changed.

with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with System;

with Imgui.Types;

package Imgui.C is

   subtype Chars_Ptr is Interfaces.C.Strings.chars_ptr;
   subtype Bool_C    is unsigned_char;  --  C99 bool, single byte

   --  Convenience constants for the boolean ABI cimgui uses
   --  (C99 _Bool, sizeof 1).
   C_True  : constant Bool_C := 1;
   C_False : constant Bool_C := 0;

   ---------------
   --  Context
   ---------------

   function igCreateContext
     (Shared_Font_Atlas : System.Address) return System.Address
     with Import, Convention => C, External_Name => "igCreateContext";

   procedure igDestroyContext (Ctx : System.Address)
     with Import, Convention => C, External_Name => "igDestroyContext";

   ---------------
   --  Frame lifecycle
   ---------------

   procedure igNewFrame
     with Import, Convention => C, External_Name => "igNewFrame";

   procedure igRender
     with Import, Convention => C, External_Name => "igRender";

   ---------------
   --  Style
   ---------------

   procedure igStyleColorsDark (Dst : System.Address := System.Null_Address)
     with Import, Convention => C, External_Name => "igStyleColorsDark";

   procedure igStyleColorsLight (Dst : System.Address := System.Null_Address)
     with Import, Convention => C, External_Name => "igStyleColorsLight";

   ---------------
   --  Windows
   ---------------

   function igBegin
     (Name   : Chars_Ptr;
      P_Open : access Bool_C;
      Flags  : Types.Window_Flags) return Bool_C
     with Import, Convention => C, External_Name => "igBegin";

   procedure igEnd
     with Import, Convention => C, External_Name => "igEnd";

   procedure igShowDemoWindow (P_Open : access Bool_C)
     with Import, Convention => C, External_Name => "igShowDemoWindow";

   ---------------
   --  Widgets — text + button + checkbox + slider
   ---------------

   --  Note we bind to igTextUnformatted, not igText (which is
   --  varargs and can't be cleanly imported into Ada). Public
   --  Imgui.Widgets.Text uses this under the hood.
   procedure igTextUnformatted (Text_Begin, Text_End : Chars_Ptr)
     with Import, Convention => C, External_Name => "igTextUnformatted";

   function igButton (Label : Chars_Ptr; Size : Types.Vec2) return Bool_C
     with Import, Convention => C, External_Name => "igButton";

   function igCheckbox (Label : Chars_Ptr; V : access Bool_C) return Bool_C
     with Import, Convention => C, External_Name => "igCheckbox";

   function igSliderFloat
     (Label  : Chars_Ptr;
      V      : access C_float;
      V_Min  : C_float;
      V_Max  : C_float;
      Format : Chars_Ptr;
      Flags  : Types.Slider_Flags) return Bool_C
     with Import, Convention => C, External_Name => "igSliderFloat";

end Imgui.C;
