with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with TypeArray2D; use TypeArray2D;
with BusinessLogic; use businesslogic;

procedure GOL is
	SIZE : Integer := 16;
	TASKS : Integer := 10;
	steps : Integer;

	task Game is
	    entry Start(stepsNumber : Integer; filename : String);
	    entry calculated(data : Array2D; from : Integer; to : Integer; currentTaskNumber : Integer);
	end Game;

	task type GameTask is
	    entry AssignNumberAndRange(number : Integer);
	    entry SetMatrix(m : Array2D);
	    entry CalculatePart;
	end GameTask;


    task body Game is
        matrix : Array2D(1..SIZE, 1..SIZE);
        taskArray : array(1..TASKS) of GameTask;
    begin
		accept Start(stepsNumber : Integer; filename : String) do
			steps := stepsNumber;
			matrix := ArrayFromFile(filename, SIZE, SIZE);

			PrintArray(matrix,SIZE,SIZE);

			for I in 1..TASKS loop
			  	taskArray(I).AssignNumberAndRange(I);
			end loop;

			for J in 1..steps loop
			   	Put_Line("");
			   	Put_Line(Integer'Image(J));

			  	for I in 1 .. TASKS loop
			    	taskArray(I).SetMatrix(matrix);
			    	taskArray(I).CalculatePart;
			   	end loop;

			   	for I in 1 .. TASKS loop
			     	accept calculated(data : Array2D; from : Integer; to : Integer; currentTaskNumber : Integer) do
			     		declare
			     			currentIndex : Integer;
		     			begin
				           	for I in 1..SIZE loop
				            	for J in 1..SIZE loop
					                currentIndex := SIZE*(I-1)+J;
					                if currentIndex >= from and currentIndex <= to then
					                	matrix(I,J) := data(I, J);
					                end if;
				             	end loop;
				           	end loop;
				        end;
			    	end calculated;
			   	end loop;

			    CLS;
			    PrintArray(matrix, SIZE, SIZE);
			    delay 0.1;
			end loop;
		end Start;
  	end Game;


	task body GameTask is
		taskNumber : Integer;
        matrix     : Array2D(1..SIZE, 1..SIZE);
        fromIndex  : Integer;
        toIndex    : Integer;
	begin
		accept AssignNumberAndRange(number : Integer) do
			declare
				count : Integer := SIZE*SIZE;
				chunk : Integer := Integer(Float'Floor(Float(count)/Float(TASKS)));
			begin
			 	taskNumber := number;
			 	fromIndex := (number-1)*chunk+1;
			 	if number = TASKS then
			 		toIndex := count;
			 	else
				 	toIndex := number*chunk;
			 	end if;

			   	Put("Task"); Put(Integer'Image(taskNumber)); Put("   From"); Put(Integer'Image(fromIndex)); Put("   To"); Put_Line(Integer'Image(toIndex));
		   	end;
		end AssignNumberAndRange;

		for I in 1..STEPS loop

			accept SetMatrix(m : Array2D) do
		    	matrix := m;
		    end SetMatrix;

		   	accept CalculatePart;
			   	begin
    				CalculateMatrix(matrix, SIZE, SIZE, fromIndex, toIndex);
			     	Game.calculated(matrix, fromIndex, toIndex, taskNumber);
			   	end;
		end loop;

	end GameTask;

begin
	Game.Start(Integer'Value(Argument(1)), Argument(2));
end GOL;
