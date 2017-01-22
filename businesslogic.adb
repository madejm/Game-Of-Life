with TypeArray2D; use TypeArray2D;
with Ada.Text_IO; use Ada.Text_IO;

package body BusinessLogic is

    function CountAliveNeighbours(matrix : Array2D; y : Integer; x : Integer) return Integer is
        count : Integer := 0;
    begin
        for I in y-1..y+1 loop
            for J in x-1..x+1 loop
                if not (I = y and J = x) then
                    if matrix(I,J) = 1.0 then
                        count := count + 1;
                    end if;
              end if;
          end loop;
      end loop;

      return count;
    end CountAliveNeighbours;

    function CalculateCell(alive : Float; aliveNeighbours : Integer) return Float is
    begin
        if alive = 0.0 and aliveNeighbours = 3 then
            return 1.0;
        elsif alive = 1.0 and (aliveNeighbours = 3 or aliveNeighbours = 2) then
            return 1.0;
        else
            return 0.0;
        end if;
    end CalculateCell;

    procedure CalculateMatrix(matrixPart : in out Array2D; matrix : Array2D; rows : Integer; cols : Integer) is
        neighbours : Integer;
        resultMatrix : Array2D(1..rows, 1..cols) := (others => (others => 0.0));
    begin
        for I in 2..rows-1 loop
            for J in 2..cols-1 loop
                neighbours := CountAliveNeighbours(matrix, I, J);
                resultMatrix(I,J) := CalculateCell(matrixPart(I,J), neighbours);
            end loop;
        end loop;

        matrixPart := resultMatrix;
    end CalculateMatrix;

end BusinessLogic;
