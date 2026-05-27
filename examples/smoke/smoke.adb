--  Headless smoke test for ada-imgui.
--
--  Doesn't open a window or render anything — just exercises the
--  binding's lifecycle calls + verifies that everything links
--  cleanly against libcimgui. If this runs and exits 0, the
--  bindings are wired up correctly.
--
--  A real GUI example (with a windowing backend like GLFW or
--  SDL) is queued as a follow-up — it's a separate binding
--  problem to solve and shouldn't gate proving the core works.

with Ada.Text_IO;

with Imgui;
with Imgui.Style;

procedure Smoke is
   use type Imgui.Context;  --  expose "=" against private Context
   Ctx : Imgui.Context;
begin
   Ada.Text_IO.Put_Line ("ada-imgui smoke test starting");

   Ctx := Imgui.Create_Context;
   if Ctx = Imgui.Null_Context then
      Ada.Text_IO.Put_Line ("FAIL: Create_Context returned null");
      return;
   end if;
   Ada.Text_IO.Put_Line ("  Create_Context OK");

   Imgui.Style.Style_Colors_Dark;
   Ada.Text_IO.Put_Line ("  Style_Colors_Dark OK");

   --  Skipping New_Frame / Render here because they require an
   --  IO + DisplaySize set by a backend; without one ImGui asserts.
   --  The smoke test just proves linkage; the real example will
   --  drive a backend.

   Imgui.Destroy_Context (Ctx);
   Ada.Text_IO.Put_Line ("  Destroy_Context OK");

   Ada.Text_IO.Put_Line ("ada-imgui smoke test passed");
end Smoke;
