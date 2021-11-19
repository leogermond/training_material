with Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with GNAT.Regpat;

package body Corpuses is

   function Count (C : Corpus_T; V : Inputs.Input_Value_T) return Natural is
      S : String := Inputs.To_String (V);
   begin
      if S'Length /= 0 then
          return Count (Unbounded_String (C), S);
      else
         return 0;
      end if;
   end Count;

   function Count (C : Corpus_T; R : Inputs.Values_Regexp_T) return Natural is
      From : Positive := 1;
      Count : Natural := 0;
   begin
      loop
         declare
            Data : constant String := Slice (C, From, Length (C));
            Position_Match : Natural;
            Result_No_Match : constant Natural := Data'First - 1;
         begin
             Position_Match := GNAT.Regpat.Match
               (Inputs.To_Pattern_Matcher (R), Data);

             exit when Position_Match = Result_No_Match;
             From := Position_Match + 1;
             Count := Count + 1;
         end;
      end loop;

      return Count;
   end Count;

end Corpuses;