with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;

package body Arrays2D is

   procedure Initialize_array (Array2 : in out Array2D; I : Integer; J : Integer) is
   begin
      for X in 1 .. I loop
         for Y in 1 .. J loop
            Array2 (X, Y) := Float (X + Y);
         end loop;
      end loop;
   end Initialize_array;

   procedure Print_array (arr : Array2D; I : Integer; J : Integer) is
   begin
      for X in 1 .. I loop
         for Y in 1 .. J loop
            Put(Integer'Image(Integer(arr(X, Y))));
         end loop;
         Put_Line("");
      end loop;
   end Print_array;

   function Array_from_file(Filename: String; sizeI : Integer; sizeJ : Integer) return Array2D is
        File         : File_Type;
        Char         : Character;
        Result_arr   : Array2D(1..sizeI,1..sizeJ);
        I            : Integer := 1;
        J            : Integer := 1;
        str          : String(1..1);
    begin
        while I > sizeI loop
            while J > sizeJ loop
                Result_arr(I,J) := 0.0;
                J := J + 1;
            end loop;

            I := I + 1;
        end loop;

        I := 1;
        J := 1;

        Open (File, In_File, Filename);
        while not End_of_file(File) loop
            Get(File, Char);
            str(1) := Char;

            if Char /= ' ' then
                Result_arr(I,J) := Float'Value(str);
                J := J + 1;
                if J > sizeJ then
                    J := 1;
                    I := I + 1;
                    exit when I > sizeI;
                end if;
            end if;
        end loop;

        Close (File);
        return Result_arr;

    end Array_from_file;

end Arrays2D;
