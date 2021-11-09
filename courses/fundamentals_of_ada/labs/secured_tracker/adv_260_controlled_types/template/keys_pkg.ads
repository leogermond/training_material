--$ begin answer
with Ada.Finalization;
--$ end answer
package Keys_Pkg is

   type Key_T is limited private;
   function Generate return Key_T;
   procedure Destroy (Key : Key_T);
   function In_Use return Natural;
   function Image (Key : Key_T) return String;

private
--$ line question
   type Key_T is limited null record;
--$ begin answer
   type Key_T is new Ada.Finalization.Limited_Controlled with record
      Value : Character;
   end record;
   procedure Initialize (Key : in out Key_T);
   procedure Finalize (Key : in out Key_T);
--$ end answer

end Keys_Pkg;