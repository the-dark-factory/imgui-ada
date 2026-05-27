with Imgui.C;

package body Imgui.Style is

   procedure Style_Colors_Dark is
   begin
      Imgui.C.igStyleColorsDark;
   end Style_Colors_Dark;

   procedure Style_Colors_Light is
   begin
      Imgui.C.igStyleColorsLight;
   end Style_Colors_Light;

end Imgui.Style;
