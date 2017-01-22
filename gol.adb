with Ada.Text_IO;    use Ada.Text_IO;

with TypeArray2D; use TypeArray2D;
with BusinessLogic; use businesslogic;

procedure GOL is
	SIZE : Integer := 10;
	STEPS : Integer := 3;
	FILENAME : String := "matrix.txt";
	TASKS : Integer := 2;

	task Game is
	    entry Start;
	    entry calculated(data : Array2D; from : Integer; to : Integer; currentTaskNumber : Integer);
	end Game;

	task type GameTask is
	    entry AssignNumber(number : Integer);
	    entry SetMatrixPart(whole_board : Array2D);
	    entry SetMatrix(m : Array2D);
	    entry CalculatePart;
	end GameTask;


    task body Game is
        matrix : Array2D(1..SIZE, 1..SIZE);
        taskArray : array(1..TASKS) of GameTask;
    begin
		accept Start;

		matrix := ArrayFromFile(FILENAME, SIZE, SIZE);

		PrintArray(matrix,SIZE,SIZE);

		for I in 1..TASKS loop
		  	taskArray(I).AssignNumber(I);
		    taskArray(I).SetMatrixPart(matrix);
		end loop;

		-- glowna petla gry
		for J in 1..STEPS loop
		   	Put_Line("");
		   	Put_Line(Integer'Image(J));

			-- niech kazdy worker przetwarza swoja czesc
		  	for I in 1 .. TASKS loop
		    	taskArray(I).SetMatrix(matrix);
		    	taskArray(I).CalculatePart;
		   	end loop;

		   	for I in 1 .. TASKS loop

		    	-- skladanie przetworzonej tablicy
		     	accept calculated(data : Array2D; from : Integer; to : Integer; currentTaskNumber : Integer) do

		           	for I in 1..SIZE loop
		            	for J in from..to loop
		               		matrix(I,J) := data( I, J-(SIZE/TASKS-1)*(currentTaskNumber-1) );
		             	end loop;
		           	end loop;

		    	end calculated;
		   	end loop;

		    PrintArray(matrix, SIZE, SIZE);
		end loop;
  	end Game;


	task body GameTask is
		taskNumber : Integer;
        matrix     : Array2D(1..SIZE, 1..SIZE);
		matrixPart : Array2D(1..SIZE, 1..((SIZE)/TASKS)+1);
	begin
		accept AssignNumber(number : Integer) do
		 	taskNumber := number;
		end AssignNumber;

		accept SetMatrixPart(whole_board : Array2D) do
			declare
			  	from : Integer := (SIZE / TASKS * (taskNumber-1)) + taskNumber mod 2;
			  	to : Integer := (SIZE/TASKS * taskNumber) + taskNumber mod 2;
			  	var_decrement : Integer := (SIZE/TASKS - 1) * (taskNumber - 1);
			begin
				matrix := whole_board;
			  	for I in 1..SIZE loop
			    	for J in from..to loop
			      		matrixPart(I, J-var_decrement) := whole_board(I,J);
			    	end loop;
			  	end loop;
			end;
		end SetMatrixPart;

		for I in 1..STEPS loop

			accept SetMatrix(m : Array2D) do
		    	matrix := m;
		    end SetMatrix;

		   	accept CalculatePart;
			   	-- wszystkie zakresy sa uzmiennione - wole wyliczac je na podstawie innych
			   	-- parametrow programu niz wpisywac 'na sztywno'
			   	declare
			     	from : Integer := (SIZE/TASKS * (taskNumber - 1)) + taskNumber mod 2 + 2 * (taskNumber - 1);
			     	to : Integer := (SIZE/TASKS * taskNumber) + taskNumber mod 2;
			   	begin
			     	CalculateMatrix(matrixPart, matrix, SIZE, SIZE/TASKS + 1);

			     	Put_Line("   Worker " & Integer'Image(taskNumber) & ": Przetworzono lokalna czesc planszy");

			     	-- oraz odsylanie przetworzonej porcji tablicy do nadzorcy
			     	Game.calculated(matrixPart, from, to, taskNumber);
			   	end;
		end loop;

	end GameTask;

begin
	Game.Start;
end GOL;
