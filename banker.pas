(***************************************************************
 *
 * KIET NGUYEN
 *
 * OS LAB 4: BANKER'S ALGORITHM
 *
 * DR MIKE SCHERGER
 *
 ***************************************************************)
Program banker;

{ Program to do Banking Algorithm. }

(***************************************************************
 *
 * Global variables and type declarations
 *
 ***************************************************************)
Type
    oneD_array = array of integer;
    twoD_array = array of array of integer;

Var F : Text;
    filename: String;
    state: Boolean;
    proc: Integer;
    res: Integer;
    resource: array of Integer;
    available: array of Integer;
    request: array of Integer;
    max: twoD_array;
    allocation: twoD_array;
    need: twoD_array;
    proc_req,I,J: Integer;


(***************************************************************
 *
 * updateAvailable(proc_req):
 *	update the AVAILABLE array
 * return: TRUE if the update is valid
 *	   FALSE if the update cannot be granted
 *
 ***************************************************************)
function updateAvailable(): boolean;
var
	temp: integer;
begin
	for I:=0 to res-1 do
	begin
	    temp := Available[I] - Request[I];
	    if(temp < 0) then
		begin
		    exit(false);
		end
	    else
		begin
		    Available[I] := temp;
		end;
	end;
	updateAvailable := true;
end;

(*************************************************************************************
 *
 * updateAllocation():
 *	update the ALLOCATION array after the request is granted to a specific process
 *
 *************************************************************************************)
procedure updateAllocation(proc_req: integer);
begin
	for I:=0 to res-1 do
	    Allocation[proc_req][I] := Allocation[proc_req][I] + Request[I];
end;

(*************************************************************************************
 *
 * updateNeed():
 *	update the NEED array after the request is granted to a specific process
 *
 *************************************************************************************)
function updateNeed(procno: integer): boolean;
var
	temp: integer;
begin
	for I:=0 to res-1 do
	begin
	    temp := Need[procno][I] - Request[I];
	    if(temp < 0) then
		begin
		    exit(false);
		end
	    else
		begin
		    Need[procno][I] := temp;
		end;
	end;
	updateNeed := true;
end;


(***************************************************************
 *
 * getRequest():
 *	Assume to grant request to the process
 *
 ***************************************************************)
function getRequest(): boolean;
var
    	retval, successUpdateAvailable, successUpdateNeed: boolean;
begin
	successUpdateAvailable	:= updateAvailable();
	successUpdateNeed	:= updateNeed(proc_req);
	if( (successUpdateAvailable = true) and (successUpdateNeed = true) ) then
	begin
	    updateAllocation(proc_req);
	    updateNeed(proc_req);
	    retval := true;
	end
	else
	    retval := false;

	getRequest := retval;
end;

(************************************************************************************
 *
 * print1D(): a general procedure to print the content of any 1D array
 * parameter: the 1D array to be printed
 *
 ************************************************************************************)
procedure print1D(toBePrinted: oneD_array);
begin
  writeln('A B C');
  for J:=0 to res-1 do begin
      write(toBePrinted[J], ' ');
    end;
  writeln();
  writeln();
end;

(*****************************************************************************************
 *
 * print2D(): a general procedure to print the content of any 2D array
 * parameter: the 2D array to be printed
 *
 *****************************************************************************************)
procedure print2D(toBePrinted: twoD_array);
begin
  writeln('   A B C');
  for I:=0 to proc-1 do
  begin
    write(I,': ');
    for J:=0 to res-1 do
    begin
      write(toBePrinted[I, J], ' ');
    end;
    writeln();
  end;
  writeln();
end;

(*****************************************************************************************
 *
 * printResult(): print the 5 following arrays' content: Resource, Available, Max, Need, Allocation
 *
 *****************************************************************************************)
procedure printResult();
begin
//Print Resource array
  writeln('The Resource Vector is:...');
  print1D(resource);

//Print Available array
  writeln('The Available Vector is:...');
  print1D(available);
  writeln();

//Print Max array
  writeln('The Max Matrix is:...');
  print2D(max);

//Print Allocation array
  writeln('The Allocation Matrix is:...');
  print2D(allocation);

//Print Need array:
  writeln('The Need Matrix is:...');
  print2D(need);
  writeln();
end;

(***************************************************************************************
 *
 *	Check if the NEED vector of a particular process is smaller than the
 *	current available vector
 *
 *	Return: TRUE if the need is smaller than available
 *		FALSE otherwise.
 *
 ***************************************************************************************)
function check(num: integer; available1: array of integer): boolean;
var
    start: integer;
begin
    for start := 0 to res-1 do
    begin
	if ( available1[start] < need[num][start]) then
	begin
	    exit(false);
	end;
    end;
    //result := true;
    check := true;
end;

(*******************************************************************************************
 *
 *	Function banker checks if the system will be in the safe state if the request
 * 	granted.
 *
 *	return: TRUE if request can be granted
 *		FALSE if system ends up in an unsafe state
 *
 ******************************************************************************************)
function isSafe(available1: array of integer; alloc: twoD_array): boolean;
var
	result, allocated: boolean;
	finish: array of Boolean;
	work: array of Integer;
	index,a,b: integer;
begin
	setlength(finish, proc);
	setlength(work, res);
	index := 0;

	//Initialize the Finish array to FALSE;
	for a:= 0 to proc-1 do begin
    	    finish[a] := FALSE;
    	end;
	//Initialize Work = Available
	for a:=0 to res-1 do begin
	    work[a] := available1[a];
	end;
	while (index < proc) do begin
	    allocated := false;
	    for a:= 0 to (proc-1) do begin
		if( (finish[a] = false) and check(a,available1) ) then begin
		    for b:= 0 to (res-1) do begin
			available1[b] := available1[b] + alloc[a][b];
		    end;
		    writeln('allocated process ', a);
		    allocated := true;
		    finish[a] := true;
		    index := index+1;
		end;
	    end;
	    if(allocated = false) then
		break;
	end;

	if(index = proc) then begin
   		result := true;
	    end
	else begin
		result:= false;
	    end;

	isSafe := result;
	writeln();

end;

(*************************************************************************************
 *
 * Read from the text file an one-dimensional array into the specified parameter 1-D array
 * @parameter: the 1-D array that will store the inputs
 *
 *************************************************************************************)
procedure readInput1D(arrayToRead: OneD_array); begin
  for J:=0 to res-1 do begin
      Read(F, arrayToRead[J]);
    end;
end;

(*************************************************************************************
 *
 * Read from the text file an two-dimensional array into the specified parameter 2-D array
 * @parameter: the 2-D array that will store the inputs
 *
 *************************************************************************************)
procedure readInput2D(arrayToRead: TwoD_array); begin
  for I:=0 to proc-1 do begin
    for J:=0 to res-1 do begin
      Read(F, arrayToRead[I, J]);
    end;
  end;
end;

(*************************************************************************************
 *
 * inputHandle(): Read in all the required array
 *
 * Assumption: the user must prepare the data in a correct format for the program to read
 *
 *************************************************************************************)
procedure inputHandle();
var
  C: Char;
  code: integer;
begin
  Assign (F,filename);
  Reset (F);

  Read(F, proc);
  writeln('# of processes = ', proc);
  Read(F, res);
  writeln('# of resources = ', res);
  writeln();
  //define size for the array: setlength(array, size);
  setlength(resource, res);
  setlength(available, res);
  setlength(request, res);
  setlength(max, proc, res);
  setlength(allocation, proc, res);
  setlength(need, proc, res);

//Read resource vector
  readInput1D(resource);

//Read Available vector
  readInput1D(available);

//Read Max 2-D array
  readInput2D(max);

//Read allocation 2-D array
  readInput2D(allocation);

//Get Need 2-D array:
  for I:=0 to proc-1 do begin
    for J:=0 to res-1 do begin
      need[I, J] := max[I, J] - allocation[I, J];
    end;
  end;

//read in two chars
  read(F, C);
  read(F, C);
//read in the process that requests the resources
  read(F, C);
  //convert the char read to the process number
  val(C,proc_req,code);
//read 1 char
  read(F, C);
// read request vector
  readInput1D(request);

  Close (F);
end;

(*************************************************************************************
 *
 * Main method: Call many subroutines to read in the matrices, do the safety algorithm
 * 		and check the second time
 *
 *************************************************************************************)
begin
  //check for the correct number of parameter counts
  if(paramCount = 1) then begin
	filename := paramStr(1);
  	writeln();
  end
  else begin
	writeln('Please enter correct FILE NAME');
	readln(filename);
  end;


  //read in the input from the text file
  inputHandle();

  //first print the contents of all the array needed
  printResult();
  //do the Banker's Algorithm the first time
  state := isSafe(available, allocation);
  if(state = true) then begin
        //if the first test is passed, read in the request vector and do the algorithm
        //the second time
	writeln('THE SYSTEM IS IN A SAFE STATE');
	writeln('Process ', proc_req,': The Request Vector is:...');
  	writeln('A B C');
  	for J:=0 to res-1 do
    	begin
     	    write(request[J], ' ');
    	end;
  	writeln();
	//check if the request meets basic requirements
  	if ( getRequest() = true) then begin
	    writeln('proceed to check');
	    state := isSafe(available, allocation);
	    if(state = true) then begin
		writeln('THE REQUEST CAN BE GRANTED: NEW STATE FOLLOWS:');
		//second print
	        printResult(); //expect to have the original matrix
	    end
	    else begin // system is not in a safe state, terminate program.
		writeln('THE REQUEST CANNOT BE GRANTED');
		//writeln('THE SYSTEM IS NOT IN A SAFE STATE');
  		exit();
 	    end;
	end
  	else begin
	    writeln('THE REQUEST CANNOT BE GRANTED');
	    exit();
	    end;
  end
  else begin	// system is not in a safe state, terminate program.
	writeln('THE SYSTEM IS NOT IN A SAFE STATE');
  	exit();
  end;

end.
