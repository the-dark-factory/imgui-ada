--  Window operations — Begin_Window, End_Window, and the
--  built-in demo window which is the recommended smoke-test
--  for any new ImGui integration.
--
--  ImGui windows are always opened with `Begin_Window` and
--  must be paired with `End_Window` regardless of whether
--  Begin returned True or False. The Ada idiom for this is
--  scoped — see the example pattern below — but the language
--  doesn't enforce it (RAII isn't quite ImGui's shape since
--  Begin is conditional). v2 may add a controlled-type
--  wrapper.

with Imgui.Types;

package Imgui.Windows is

   --  Open a window. Returns True if the window is visible and
   --  its contents should be rendered. Always call End_Window
   --  after a Begin_Window, even if this returned False:
   --
   --    if Begin_Window ("Hello") then
   --       Imgui.Widgets.Text ("World");
   --    end if;
   --    End_Window;
   --
   --  Is_Open: optional in-out flag for an OS-style close button.
   --  When supplied and set False by the user clicking [X], the
   --  caller can use that to drop the window from their UI.
   function Begin_Window
     (Name    : String;
      Is_Open : access Boolean := null;
      Flags   : Types.Window_Flags := Types.No_Window_Flags)
      return Boolean;

   --  Close the most recently opened window. Pairs 1:1 with
   --  every Begin_Window call.
   procedure End_Window;

   --  Show ImGui's built-in demo window. Useful smoke test and
   --  reference. Pass Is_Open to support an OS-style close
   --  button; when nil the demo cannot be closed by the user.
   procedure Show_Demo_Window (Is_Open : access Boolean := null);

end Imgui.Windows;
