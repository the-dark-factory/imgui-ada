--  Widget calls — the meat of an ImGui frame. Text, buttons,
--  checkboxes, sliders. v1 covers the most-asked-for set; the
--  rest follow once the binding-factory pattern is proven.
--
--  These calls only have effect between a successful
--  Begin_Window … End_Window pair. Calling them outside is
--  legal in ImGui but the output goes nowhere visible.

with Interfaces.C; use Interfaces.C;

with Imgui.Types;

package Imgui.Widgets is

   --  Render a single line of static text.
   procedure Text (S : String);

   --  Push a button. Returns True on the frame the user clicks.
   --  Pass Zero_Vec2 (the default) for auto-sized to label.
   function Button
     (Label : String;
      Size  : Types.Vec2 := Types.Zero_Vec2) return Boolean;

   --  Toggleable checkbox. Returns True on the frame the value
   --  changed; the new state is in V.
   function Checkbox (Label : String; V : in out Boolean) return Boolean;

   --  Float slider in the [Min, Max] range. Returns True on the
   --  frame the value changed.
   --
   --  Format is a printf-style format string for the displayed
   --  number; default "%.3f" gives three decimal places.
   function Slider_Float
     (Label  : String;
      V      : in out C_float;
      Min    : C_float;
      Max    : C_float;
      Format : String := "%.3f";
      Flags  : Types.Slider_Flags := Types.No_Slider_Flags)
      return Boolean;

end Imgui.Widgets;
