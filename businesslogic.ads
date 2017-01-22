with TypeArray2D; use TypeArray2D;

package BusinessLogic is

    function CountAliveNeighbours(matrix : Array2D; y : Integer; x : Integer) return Integer;
    function CalculateCell(alive : Float; aliveNeighbours : Integer) return Float;
    procedure CalculateMatrix(matrixPart : in out Array2D; matrix : Array2D; rows : Integer; cols : Integer);

end BusinessLogic;