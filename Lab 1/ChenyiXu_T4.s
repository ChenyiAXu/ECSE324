.global _start

//initialize memory
arr: .word 68, -22, -31, 75, -10, -61, 39, 92, 94, -55 //test array
arrayLength: .word 10 //length of the array given as input paramter 


_start:
	
	LDR		R0, =arr 				//Ro <- ptr to array
	LDR 	R1, arrayLength 				//R1 <- array length n 
	MOV 	R2, #1					//R2 <-i= 1
	BL		recursivesort
	B 		stop 
recursivesort: 
	PUSH 	{R4-R7}
	CMP		R2, R1
	POPGE		{R4-R7}		
	BXGE	lr						//	stop  if (I<=n) return


	LDR		R4, [R0, R2, LSL #2]		// R4 <- arr[i] = value
	MOV		R5, R2				// R5 <- j = i

while_loop_conditions:
	CMP		R5, #0
	BLE		end_while_loop			// condition j > 0
	SUB		R6, R5, #1				// R6 <- j - 1
	LDR		R7, [R0, R6, LSL #2]		// R7 <- arr[j - 1]
	CMP		R7, R4
	BLE		end_while_loop			// condition arr[j - 1] > arr[i]
while_Loop:
	STR		R7, [R0, R5, LSL #2]		// arr[j] = arr[j - 1]
	SUB		R5, R5, #1				// R5 <- j--
	B		while_loop_conditions
end_while_loop:
	STR		R4, [R0, R5, LSL #2]
	ADD		R2, R2, #1				// R2 <- i++
	POP		{R4-R7}
	B		recursivesort 

	
stop:
	B 		stop