package TypeArray2D is

   type Array2D is array(Integer range <>, Integer range <>) of Float;

   procedure Initialize_array(Array2 : in out Array2D; I : Integer; J : Integer);
   procedure PrintArray (arr : Array2D; I : Integer; J : Integer);
   function ArrayFromFile(Filename: String; sizeI : Integer; sizeJ : Integer) return Array2D;
   
end TypeArray2D;
