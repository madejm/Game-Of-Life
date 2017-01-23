with TypeArray2D; use TypeArray2D;

package BusinessLogic is
	
    procedure CLS;
    function CountAliveNeighbours(matrix : Array2D; y : Integer; x : Integer) return Integer;
    function CalculateCell(alive : Float; aliveNeighbours : Integer) return Float;
    procedure CalculateMatrix(matrix : in out Array2D; rows : Integer; cols : Integer; from : Integer; to : Integer);

end BusinessLogic;