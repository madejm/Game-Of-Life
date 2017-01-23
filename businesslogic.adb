with TypeArray2D; use TypeArray2D;
with Ada.Text_IO; use Ada.Text_IO;

package body BusinessLogic is

    procedure CLS is
    begin
       Ada.Text_IO.Put(ASCII.ESC & "[2J");
    end CLS;

    function CountAliveNeighbours(matrix : Array2D; y : Integer; x : Integer) return Integer is
        count : Integer := 0;
    begin
        for I in y-1..y+1 loop
            if I >= 1 and I <= matrix'Length(1) then
                for J in x-1..x+1 loop
                    if J >= 1 and J <= matrix'Length(2) then
                        if not (I = y and J = x) then
                            if matrix(I,J) = 1.0 then
                                count := count + 1;
                            end if;
                        end if;
                    end if;
                end loop;
            end if;
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

    procedure CalculateMatrix(matrix : in out Array2D; rows : Integer; cols : Integer; from : Integer; to : Integer) is
        neighbours   : Integer;
        resultMatrix : Array2D(1..rows, 1..cols) := (others => (others => 0.0));
        currentIndex : Integer;
    begin
        for I in 1..rows loop
            for J in 1..cols loop
                currentIndex := rows*(I-1)+J;
                if currentIndex >= from and currentIndex <= to then
                    neighbours := CountAliveNeighbours(matrix,I,J);
                    resultMatrix(I,J) := CalculateCell(matrix(I,J), neighbours);
                end if;
            end loop;
        end loop;

        matrix := resultMatrix;
    end CalculateMatrix;

end BusinessLogic;
