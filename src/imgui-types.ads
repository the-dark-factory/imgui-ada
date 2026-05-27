--  Shared types used across the public Imgui packages.
--
--  Records here are declared with `Convention => C` so they
--  match the ABI cimgui expects when passing them by value
--  (which is how ImGui's ImVec2 and ImVec4 cross the C boundary).
--
--  Flag types (Window_Flags, Slider_Flags, etc.) are bitfield
--  newtypes of unsigned integers; combine with `or`. v2 may
--  switch to packed-record representations for ergonomics.

with Interfaces.C; use Interfaces.C;

package Imgui.Types is

   --  2D vector — ImVec2. Used for sizes + positions throughout
   --  the API. Passed by value across the C boundary so the C
   --  convention is required.
   type Vec2 is record
      X : C_float := 0.0;
      Y : C_float := 0.0;
   end record
     with Convention => C;

   --  Convenience zero — passed where ImGui says "auto-size".
   Zero_Vec2 : constant Vec2 := (0.0, 0.0);

   --  4D vector — ImVec4. Mostly used for colours (R/G/B/A in
   --  the 0.0..1.0 range) and rectangles.
   type Vec4 is record
      X : C_float := 0.0;
      Y : C_float := 0.0;
      Z : C_float := 0.0;
      W : C_float := 0.0;
   end record
     with Convention => C;

   --  Window-creation flags. Bitmask combinable with `or`.
   --  Values mirror ImGuiWindowFlags_*. v1 exposes the
   --  most commonly used; the rest are easy to add as needed.
   type Window_Flags is new unsigned;
   No_Window_Flags            : constant Window_Flags := 0;
   Window_No_Title_Bar        : constant Window_Flags := 16#0000_0001#;
   Window_No_Resize           : constant Window_Flags := 16#0000_0002#;
   Window_No_Move             : constant Window_Flags := 16#0000_0004#;
   Window_No_Scrollbar        : constant Window_Flags := 16#0000_0008#;
   Window_No_Collapse         : constant Window_Flags := 16#0000_0020#;
   Window_Always_Auto_Resize  : constant Window_Flags := 16#0000_0040#;
   Window_No_Background       : constant Window_Flags := 16#0000_0080#;
   Window_No_Saved_Settings   : constant Window_Flags := 16#0000_0100#;
   Window_Menu_Bar            : constant Window_Flags := 16#0000_0400#;

   --  Slider behaviour flags. Same bitmask style.
   type Slider_Flags is new unsigned;
   No_Slider_Flags     : constant Slider_Flags := 0;
   Slider_Always_Clamp : constant Slider_Flags := 16#0000_0010#;
   Slider_Logarithmic  : constant Slider_Flags := 16#0000_0020#;
   Slider_No_Round     : constant Slider_Flags := 16#0000_0040#;
   Slider_No_Input     : constant Slider_Flags := 16#0000_0080#;

end Imgui.Types;
