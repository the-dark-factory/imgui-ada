--  Style presets. ImGui ships two standard colour schemes
--  out of the box; pick one early in setup, before the first
--  New_Frame.

package Imgui.Style is

   --  Apply ImGui's default dark colour scheme. Call once after
   --  Create_Context, before any frame.
   procedure Style_Colors_Dark;

   --  Apply ImGui's classic light colour scheme.
   procedure Style_Colors_Light;

end Imgui.Style;
