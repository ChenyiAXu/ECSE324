.global _start
//initialize memory
devident: .word 5		//initialization of devident
devisor: .word 2 		//initialization of devisor
result: .space 4 		//uninitialized space for the results

_start:
	LDR R0, devident	//R0<- devident, put the address of devidend into Ro
	LDR R1, devisor		//R1<- devisor, put the address of devisor into R1
	
	
	LDR R2, =result		//put the address of result into R2

	BL dev 				//call the dev function

	
stop:
	B stop				//stop the execution

dev:
	
	MOV R3, #0			//R3 <- quotient, accumulate quotient 

devLoop: 
	CMP R1, R0			// divident - divsor
	BGT stop			//Divident - Divsor >= 0
	
	ADD R3, R3, #1		 //Add Quotient, Quotient, #
	SUB R0, R0, R1 		//SUB remainder, remainder, devisor
	
	CMP R0, R1
	BGT devLoop 		//Ro-R1>=0 -> devLoop
	
	LSL R3, R3, #16		//Logicial shift left quotient
	ADD R0, R3, R0		//Quotient + remainder
	str r0, [r2]		//Store value into address of R2
	bx lr

	
	