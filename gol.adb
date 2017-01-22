with Ada.Text_IO;    use Ada.Text_IO;

with Arrays2D; use Arrays2D;
with BusinessLogic; use businesslogic;

procedure GOL is
	MAX_SIZE : Integer := 10;
	ITERATIONS : Integer := 10;
	FILE_IN_NAME : String := "matrix.txt";
	NUMBER_OF_WORKERS : Integer := 2;

	task Supervisor is
	    entry Start_game;
	    entry on_data_returned (
			data                  : Array2D;
			start_range           : Integer;
			end_range             : Integer;
			current_worker_number : Integer);
	end Supervisor;

	task type Worker_task is
	    entry Get_worker_number_from_supervisor(worker_num : Integer);
	    entry Fill_local_board_part(whole_board : Array2D);
	    entry process_data;
	end Worker_task;

    -- Nadzorca
    task body Supervisor is
        matrix : Array2D(1..MAX_SIZE, 1..MAX_SIZE);
        workers : array(1..NUMBER_OF_WORKERS) of Worker_task;
    begin
    accept Start_game;

    Put_Line("Nadzorca: Odebrano sygnal startu");

    matrix := Array_from_file(FILE_IN_NAME, MAX_SIZE, MAX_SIZE);
    -- tmp_board := Array_from_file(FILE_IN_NAME, size_y, size_x);

    Put_Line("Nadzorca: Wczytano tablice z pliku i wypelniono brzegi zerami:");
    -- Print_array(matrix,size_y,size_x);
    Print_array(matrix,MAX_SIZE,MAX_SIZE);

    -- nadanie workerom numerow i wypelnienie ich czesci planszy lokalnych
    for I in 1..NUMBER_OF_WORKERS loop
      workers(I).Get_worker_number_from_supervisor(I);
      workers(I).Fill_local_board_part(matrix);
    end loop;

    -- glowna petla gry
    for J in 1..ITERATIONS loop
       Put_Line("Nadzorca: START NOWEJ ITERACJI");

       -- niech kazdy worker przetwarza swoja czesc
       for I in 1 .. NUMBER_OF_WORKERS loop
         workers(I).process_data;
       end loop;

       for I in 1 .. NUMBER_OF_WORKERS loop

         -- skladanie przetworzonej tablicy
         accept on_data_returned (
               data                  : Array2D;
               start_range           : Integer;
               end_range             : Integer;
               current_worker_number : Integer) do

           for I in 1..MAX_SIZE loop
             for J in start_range..end_range loop
               matrix(I,J) := data( I, J-(MAX_SIZE/NUMBER_OF_WORKERS-1)*(current_worker_number-1) );
             end loop;
           end loop;

         end on_data_returned;
       end loop;

       Put_Line("Nadzorca: Odebrano od workerow i scalono przetworzona tablice:");
       Print_array(matrix, MAX_SIZE, MAX_SIZE);
    end loop;
  end Supervisor;


  -- Worker --------------------------------------------------------------------
  task body Worker_task is
    worker_id : Integer;
    local_board_copy : Array2D(1..MAX_SIZE, 1..((MAX_SIZE)/NUMBER_OF_WORKERS)+1);
  begin
    -- nadaja workerowi unikalny numer
    accept Get_worker_number_from_supervisor(worker_num : Integer) do
      worker_id := worker_num;
    end Get_worker_number_from_supervisor;

    -- wypelniaja jego lokalna kopie tablicy
    accept Fill_local_board_part(whole_board : Array2D) do
    -- wszystkie zakresy sa uzmiennione - wole wyliczac je na podstawie innych
    -- parametrow programu niz wpisywac 'na sztywno'
    declare
      var_start_range : Integer := (MAX_SIZE / NUMBER_OF_WORKERS * (worker_id-1)) + worker_id mod 2;
      var_end_range : Integer := (MAX_SIZE/NUMBER_OF_WORKERS * worker_id) + worker_id mod 2;
      var_decrement : Integer := (MAX_SIZE/NUMBER_OF_WORKERS-1)*(worker_id-1);
    begin
      for I in 1..MAX_SIZE loop
        for J in var_start_range..var_end_range loop
          local_board_copy( I, J-var_decrement ) := whole_board(I,J);
        end loop;
      end loop;
    end;end Fill_local_board_part;

    Put_Line("   Worker " & Integer'Image(worker_id) & ": Wypelniono lokalna czesc planszy");

    for I in 1..ITERATIONS loop

       -- nastepuje przetwarzanie danych
       accept process_data;
       -- wszystkie zakresy sa uzmiennione - wole wyliczac je na podstawie innych
       -- parametrow programu niz wpisywac 'na sztywno'
       declare
         var_start_range : Integer := (MAX_SIZE / NUMBER_OF_WORKERS * (worker_id-1)) + worker_id mod 2 + 2*(worker_id-1);
         var_end_range : Integer := (MAX_SIZE/NUMBER_OF_WORKERS * worker_id) + worker_id mod 2;
       begin
         Apply_gol_logic_to_board(local_board_copy, MAX_SIZE, (MAX_SIZE)/NUMBER_OF_WORKERS+1);

         Put_Line("   Worker " & Integer'Image(worker_id) & ": Przetworzono lokalna czesc planszy");
         Put_Line("   Worker " & Integer'Image(worker_id) & ": Trwa wysylanie przetworzonej czesci do nadzorcy..");

         -- oraz odsylanie przetworzonej porcji tablicy do nadzorcy
         Supervisor.on_data_returned(local_board_copy, var_start_range, var_end_range, worker_id);
       end;
    end loop;

  end Worker_task;
begin

	Supervisor.Start_game;
end GOL;
