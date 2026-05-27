with Interfaces.C.Strings;

with Imgui.C;

package body Imgui.Widgets is

   ------------------------
   --  Text
   ------------------------

   procedure Text (S : String) is
      use Interfaces.C.Strings;
      C_S : chars_ptr := New_String (S);
   begin
      --  Text_End = null tells cimgui to read until the C-string
      --  null terminator. We could pass an explicit end if we
      --  wanted to render a slice without copying — v2.
      Imgui.C.igTextUnformatted (C_S, Null_Ptr);
      Free (C_S);
   end Text;

   ------------------------
   --  Button
   ------------------------

   function Button
     (Label : String;
      Size  : Types.Vec2 := Types.Zero_Vec2) return Boolean
   is
      use Interfaces.C.Strings;
      C_Label : chars_ptr := New_String (Label);
      Clicked : constant Imgui.C.Bool_C := Imgui.C.igButton (C_Label, Size);
   begin
      Free (C_Label);
      return Clicked = Imgui.C.C_True;
   end Button;

   ------------------------
   --  Checkbox
   ------------------------

   function Checkbox (Label : String; V : in out Boolean) return Boolean is
      use Interfaces.C.Strings;
      C_Label : chars_ptr := New_String (Label);
      Scratch : aliased Imgui.C.Bool_C :=
        (if V then Imgui.C.C_True else Imgui.C.C_False);
      Changed : Imgui.C.Bool_C;
   begin
      Changed := Imgui.C.igCheckbox (C_Label, Scratch'Access);
      V := Scratch = Imgui.C.C_True;
      Free (C_Label);
      return Changed = Imgui.C.C_True;
   end Checkbox;

   ------------------------
   --  Slider_Float
   ------------------------

   function Slider_Float
     (Label  : String;
      V      : in out C_float;
      Min    : C_float;
      Max    : C_float;
      Format : String := "%.3f";
      Flags  : Types.Slider_Flags := Types.No_Slider_Flags)
      return Boolean
   is
      use Interfaces.C.Strings;
      C_Label  : chars_ptr := New_String (Label);
      C_Format : chars_ptr := New_String (Format);
      Scratch  : aliased C_float := V;
      Changed  : Imgui.C.Bool_C;
   begin
      Changed :=
        Imgui.C.igSliderFloat
          (C_Label, Scratch'Access, Min, Max, C_Format, Flags);
      V := Scratch;
      Free (C_Label);
      Free (C_Format);
      return Changed = Imgui.C.C_True;
   end Slider_Float;

end Imgui.Widgets;
