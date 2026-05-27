with System;

with Imgui.C;

package body Imgui is

   ------------------------
   --  Is_Null
   ------------------------

   function Is_Null (Ctx : Context) return Boolean is
      use type System.Address;
   begin
      return System.Address (Ctx) = System.Null_Address;
   end Is_Null;

   ------------------------
   --  Create_Context
   ------------------------

   function Create_Context
     (Shared_Font_Atlas : System.Address := System.Null_Address)
      return Context
   is
   begin
      return Context (Imgui.C.igCreateContext (Shared_Font_Atlas));
   end Create_Context;

   ------------------------
   --  Destroy_Context
   ------------------------

   procedure Destroy_Context (Ctx : Context := Null_Context) is
   begin
      Imgui.C.igDestroyContext (System.Address (Ctx));
   end Destroy_Context;

   ------------------------
   --  New_Frame / Render
   ------------------------

   procedure New_Frame is
   begin
      Imgui.C.igNewFrame;
   end New_Frame;

   procedure Render is
   begin
      Imgui.C.igRender;
   end Render;

end Imgui;
