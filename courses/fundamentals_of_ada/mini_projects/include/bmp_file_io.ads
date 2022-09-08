with Surfaces;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;

package BMP_File_IO is

   function Get (File : File_Type) return Surfaces.Surface_T;
   -- Get the file content from a Stream

   function Get (File_Name : String) return Surfaces.Surface_T;
   -- Get the file content from its name on disk

end BMP_File_IO;
