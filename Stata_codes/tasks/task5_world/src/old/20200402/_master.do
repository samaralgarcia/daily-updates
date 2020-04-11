* Version: March 24, 2020
* Author: Glenn Magerman

// change to directory of task
clear all
cd "$task2"

// initialize task (build from inputs)
foreach dir in tmp output {
	cap !rm -rf "./`dir'"
}

// create task folders
foreach dir in input src output tmp {
	cap !mkdir "./`dir'"
}	
	
// code	
	do "./src/1. global_totals.do"
	do "./src/2. global_cases.do"
	do "./src/3. global_deaths.do"
	
// maintenance
cap !rm -rf "./tmp"									// Linux/Mac
cap !rmdir /q /s "./tmp"							// Windows		

// back to main folder of tasks
cd "$folder"		


/* Latest updates: 
- add log plots and infected/mortality rates (April 2, 2020)
- add growth rates (April 1, 2020)
- automate choice of top_world (March 28, 2020)
- update color pallette (March 27, 2020)
- automate legend for auto-selected countries (March 27, 2020)
- try svg and html interactive output (March 27, 2020)
*/
