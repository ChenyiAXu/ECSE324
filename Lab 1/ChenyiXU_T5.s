.global _start
//Input Image: 
// **each word contains 1 byte dedicated to each channel**

input_image: .word 1057442138,  2410420899, 519339369,  2908788659, 1532551093, 4249151175, 4148718620, 788746931,  3777110853, 2023451652
.word 3000595192,   1424215634, 3130581119, 3415585405, 2359913843, 1600975764, 1368061213, 2330908780, 3460755284, 464067332
.word 2358850436,   1191202723, 2461113486, 3373356749, 3070515869, 4219460496, 1464115644, 3200205016, 1316921258, 143509283
.word 3846979011,   2393794600, 618297079,  2016233561, 3509496510, 1966263545, 568123240,  4091698540, 2472059715, 2420085477
.word 395970857,    2217766702, 44993357,   694287440,  2233438483, 1231031852, 2612978931, 1464238350, 3373257252, 2418760426
.word 4005861356,   288491815, 3533591053,  754133199,  3745088714, 2711399263, 2291899825, 2117953337, 1710526325, 1989628126
.word 465096977,    3100163617, 195551247,  3884399959, 422483884,  2154571543, 3380017320, 380355875,  4161422042, 654077379
.word 2168260534,   3266157063, 3870711524, 2809320128, 3980588369, 2342816349, 1283915395, 122534782,  4270863000, 2232709752
.word 1946888581,   1956399250, 3892336886, 1456853217, 3602595147, 1756931089, 858680934,  2326906362, 2258756188, 1125912976
.word 1883735002,   1851212965, 3925218056, 2270198189, 3481512846, 1685364533, 1411965810, 3850049461, 3023321890, 2815055881

R_MASK: .word 0xFF000000
G_MASK: .word 0x00FF0000
B_MASK: .word 0x0000FF00
A_MASK: .word 0x000000FF

window: .space 60


result:	.space 144			 //allocate space for the result, 6x6x4

_start:
	SUB SP, SP, #20

initialize_For_loop1:
	MOV R0, #0				
	STR R0, [SP, #16] 		//[SP+16] <- int m =0
For_loop_1_condition:
	LDR R0, [SP, #16] 
	CMP R0, #6				
	BGE end_forloop1
initialize_For_loop2:
	MOV R0, #0
	STR R0, [SP, #12]		//[SP+12] <- int n=0
For_loop_2_condition:
	LDR R0, [SP, #12]	
	CMP R0, #6
	BGE end_for_loop2
initialize_For_loop3:
	LDR R0, [SP, #16]		//[SP+8] <-int i = m
	STR R0, [SP, #8] 
	MOV R7, #0				//R7 <-window element index
For_loop_3_conditions:
	LDR R0, [SP, #16] 
	ADD R1, R0, #5			//R1 = i+5
	CMP R0, R1				
	BGE end_for_loop3
initialize_for_loop4:
	LDR R0, [SP, #12] 
	STR R0, [SP, #4] 		//[SP+4] <-int j=n
For_loop4_conditions:
	LDR R0, [SP, #4] 
	ADD R1, R0, #5
	CMP R0, R1
	BGE end_for_loop4
Body: 
	//extract 2D array to 1D
	LDR R0, [SP, #8] 		//R0<-i
	LDR R1, [SP, #4]		//R1<-j
	LDR R2, =input_image	//R2<- ptr input image
	MOV R6, #10
	MLA R3, R0, R6, R1		//R3<- index of inputimage[i][j]
	LDR R4, [R2, R3, LSL#2]	//R4<-inputimage[i][j]
	LDR R5, =window			//R5<-ptr to window
	STR R4, [R5, R7]		//window[R7} <- inputimage[i][j]
increment_for_loop4:
	LDR R0, [SP, #4]
	ADD R0, R0, #1
	STR R0, [SP, #4]
	ADD R7, R7, #1
	B 	For_loop4_conditions
end_for_loop4:
//directly go to loop 3 increment 
increment_for_loop3:
	LDR R0, [SP, #8]
	ADD R0, R0, #1
	STR R0, [SP, #8]
	B For_loop_3_conditions 
end_for_loop3:
	//apply mask and use masked window
	//sort masked window
	//store
	//repeat 4 times for 4 channels
	LDR R0, R_MASK
	AND R0, R0, R5			//R masked window
	BL recursivesort		//call the recursivesort
	MOV R1, #13
	LDR R2, [R0, R1, LSL#2] //R2<-median R_masked
	STR R2, [SP]
	
	LDR R0, G_MASK
	AND R0, R0, R5			//G masked window
	BL recursivesort		//call the recursivesort
	MOV R1, #13
	LDR R2, [R0, R1, LSL#2] //R2<-median R_masked
	STR R2, [SP]
	
	LDR R0, B_MASK
	AND R0, R0, R5			//B masked window
	BL recursivesort		//call the recursivesort
	MOV R1, #13
	LDR R2, [R0, R1, LSL#2] //R2<-median R_masked
	STR R2, [SP]
	
	LDR R0, A_MASK
	AND R0, R0, R5			//A masked window
	BL recursivesort		//call the recursivesort
	MOV R1, #13
	LDR R2, [R0, R1, LSL#2] //R2<-median R_masked
	STR R2, [SP]
	
increment_for_loop2:
	LDR R0, [SP, #12]
	ADD R0, R0, #1
	STR R0, [SP, #12]
	B For_loop_2_condition
end_for_loop2:
//go to loop 1 increment
increment_for_loop1:
	LDR R0, [SP, #16]
	ADD R0, R0, #1
	STR R0, [SP, #16]
	B For_loop_1_condition
end_forloop1:
	LDR R0, =result
	LDR R1, [SP]
	LDR R2, [SP, #16]
	STR R1, [R0, R2, LSL#2]
	ADD SP, SP, #20
	B stop
	//store the value into the address of result 
	//call the stop function
stop:
	B stop
	
recursivesort:
	PUSH	{R4-R7}
	LDR		R0, [SP]
	MOV		R1, #25		// R1 <- array length n
	MOV		R2, #1			// R2 <- i = 1

for_loop: 
	CMP		R2, R1
	BGE		end_for_loop		// end loop i < n
	LDR		R4, [R0, R2, LSL #2]	// R4 <- arr[i] = value
	MOV		R5, R2			// R5 <- j = i

while_loop_conditions:
	CMP		R5, #0
	BLE		end_while_loop		// condition j > 0
	SUB		R6, R5, #1			// R6 <- j - 1
	LDR		R7, [R0, R6, LSL #2]	// R7 <- arr[j - 1]
	CMP		R7, R4
	BLE		end_while_loop		// condition arr[j - 1] > arr[i]
	
while_Loop:
	STR		R7, [R0, R5, LSL #2]	// arr[j] = arr[j - 1]
	SUB		R5, R5, #1			// R5 <- j--
	B		while_loop_conditions

end_while_loop:
	STR		R4, [R0, R5, LSL #2]
	ADD		R2, R2, #1			// R2 <- i++
	B		for_loop

end_for_loop:
	POP		{R4-R7}
	BX LR