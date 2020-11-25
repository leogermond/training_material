with Radar_Internals; use Radar_Internals;

procedure Main is
   -- You are in charge of developping a rotating radar for the new T-1000
   -- Some of the radar code is already in place, it is just missing the
   -- high-level interface to handle incoming objects.
   --
   -- In this lab, you are provided with a richer Radar interface that allows you
   -- to select an active object with the radar, and to decide what to do
   -- depending on its status and your position.

   -- Distance to the active object
   Active_Object_Distance : Object_Distance_Km_T;

   -- Status of the active object
   Active_Object_Status : Object_Status_T := Selected;

   -- Current running speed
   Running_Speed : Speed_Kph_T;

begin

   -- QUESTION 1
   --
   -- Declare a loop from 1 to 15 to get the active object status and
   -- distance and to perform the appropriate action up to the Time_Step
   -- subprogram call.
   for J in 1 .. 15 loop

      -- Get the status of the active object
      Active_Object_Status := Get_Active_Object_Status;

      -- And its distance
      Active_Object_Distance := Get_Active_Object_Distance;

      -- QUESTION 2
      --
      -- We want the action to change depending on the object status
      --
      -- Perform the following actions using a case statement
      -- on Active_Object_Status:
      -- when status is Tracked, then Walk_And_Scan
      -- when status is Cleared, then Next_Object
      -- when status is Selected, then Get_Closer (Run)
      -- when status is Out_Of_Range, then Get_Closer (Fast_Walk)

      case Active_Object_Status is
      when Tracked =>
         Walk_And_Scan;
      when Cleared =>
         Next_Object;
      when Selected =>
         Get_Closer (Fast);
      when Out_Of_Range =>
         Get_Closer (Normal);
      end case;

      -- Get running speed
      Running_Speed := Get_Running_Speed;

      -- QUESTION 3 - Part A
      --
      -- If Running_Speed is not 0 then update the E.T.A. by calling
      -- Update_E_T_A. Else, call Update_No_E_T_A

      if Running_Speed /= 0.0 then
         -- Calculate new E.T.A. to object
         Update_E_T_A (Active_Object_Distance / Running_Speed * 3600.0);
      else
         Update_No_E_T_A;
      end if;

      -- QUESTION 3 - Part B
      -- Using `if` and `elsif`, implement the following:
      --
      -- If Active_Object_Distance is under 2km
      -- do not do anything, explicitly, using a null statement.
      --
      -- If Active_Object_Distance is
      -- between 2 km and 4 km  Rotate_Antenna (Slow)
      -- between 4 km and 8 km  Rotate_Antenna (Normal)
      -- over 8 km  Rotate_Antenna (Fast)
      if Active_Object_Distance <= 2.0 then
         null;
      elsif Active_Object_Distance <= 4.0 then
         Rotate_Antenna (Slow);
      elsif Active_Object_Distance <= 8.0 then
         Rotate_Antenna (Normal);
      else
         Rotate_Antenna (Fast);
      end if;

      -- QUESTION 4 - Part A
      --
      -- We want to modify the loop so that it exits as soon as the active
      -- object status is Selected.
      --
      -- Modify the loop to use a `while`.
      -- Note: Be careful about the loop entry condition.

      -- QUESTION 4 - Part B
      --
      -- Modify it again to use a conditional `exit when` statement.

      exit when Active_Object_Status = Selected;

      -- QUESTION 5 - Part A
      --
      -- We want a 3s delay in case of scan (Active_Object_Status = Tracked)
      -- else a 0.1 seconds delay.
      -- Implement it using a case-expression

      -- QUESTION 5 - Part B
      --
      -- Reimplement it using an if-expression instead
      delay (if Active_Object_Status = Tracked then 3.0 else 0.1);
      Time_Step;
   end loop;

end Main;