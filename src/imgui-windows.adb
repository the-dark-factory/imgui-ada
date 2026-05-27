with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;

with Imgui.C;

package body Imgui.Windows is

   --  Note on the Boolean ↔ Bool_C dance below:
   --  We can't pass &Boolean directly to cimgui because Ada's
   --  Boolean isn't guaranteed to be sizeof 1 (the spec leaves
   --  it implementation-defined). So when caller passes Is_Open,
   --  we allocate a local aliased Bool_C, initialise it from
   --  Is_Open.all, pass &Scratch to cimgui, and sync Scratch back
   --  into Is_Open.all after the call (cimgui may have set it
   --  false if the user clicked the window's [X]).

   ------------------------
   --  Begin_Window
   ------------------------

   function Begin_Window
     (Name    : String;
      Is_Open : access Boolean := null;
      Flags   : Types.Window_Flags := Types.No_Window_Flags)
      return Boolean
   is
      use Interfaces.C.Strings;
      C_Name : chars_ptr := New_String (Name);

      --  Scratch byte for the in-out p_open parameter. Only used
      --  when caller passed Is_Open.
      Scratch : aliased Imgui.C.Bool_C :=
        (if Is_Open /= null and then Is_Open.all
         then Imgui.C.C_True else Imgui.C.C_False);

      Visible : Imgui.C.Bool_C;
   begin
      if Is_Open = null then
         Visible := Imgui.C.igBegin (C_Name, null, Flags);
      else
         Visible := Imgui.C.igBegin (C_Name, Scratch'Access, Flags);
         Is_Open.all := Scratch = Imgui.C.C_True;
      end if;
      Free (C_Name);
      return Visible = Imgui.C.C_True;
   end Begin_Window;

   ------------------------
   --  End_Window
   ------------------------

   procedure End_Window is
   begin
      Imgui.C.igEnd;
   end End_Window;

   ------------------------
   --  Show_Demo_Window
   ------------------------

   procedure Show_Demo_Window (Is_Open : access Boolean := null) is
      Scratch : aliased Imgui.C.Bool_C :=
        (if Is_Open /= null and then Is_Open.all
         then Imgui.C.C_True else Imgui.C.C_False);
   begin
      if Is_Open = null then
         Imgui.C.igShowDemoWindow (null);
      else
         Imgui.C.igShowDemoWindow (Scratch'Access);
         Is_Open.all := Scratch = Imgui.C.C_True;
      end if;
   end Show_Demo_Window;

end Imgui.Windows;
