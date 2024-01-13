.global _start
.equ pixel_buffer_memory, 0xc8000000
.equ character_buffer_memory, 0xc9000000
_start:

  bl      draw_test_screen
end:
        b       end
@ TODO: Insert VGA driver functions here.
VGA_draw_point_ASM:
//should only access pixel buffer memoy
//color indicated in the third argument
// x is the column <- R0, y is the row  <-R1
//color R2
	
		PUSH    {R4, R5, R6, R7, R8, R9}
		MOV		R5, #300
		ADD 	R5, R5, #19
		CMP		R0, R5		//x needs to be smaller than 320
		POPGT   {R4, R5, R6, R7, R8, R9}
		BXGT    LR                //branch it to an error subroutine
		CMP		R0, #0  		//x needs to be greater than 0
		POPLT  {R4, R5, R6, R7, R8, R9}
		BXLT 	LR
		CMP		R1, #239 		//y needs to be smaller than 240
		POPGT  {R4, R5, R6, R7, R8, R9}
		BXGT	LR
		CMP		R1, #0  		//y needs to be greater than 0 
		POPLT  {R4, R5, R6, R7, R8, R9}
		BXLT 	LR

		LSL		R0, R0, #1
		LSL     R1, R1, #10
	
		LDR     R4, =pixel_buffer_memory
		ADD     R4, R4, R0
		ADD		R4, R4, R1
		STRH    R2, [R4]
		POP    {R4, R5, R6, R7, R8, R9}
		BX		LR 

VGA_clear_pixelbuff_ASM:
//calling the VGD_draw_point_ASM
//colour value of 0 for every valid location on the screen
//max x 320, 
//loop through every value of x and y (1 nested for loop)
		PUSH    {R5, R6, R7, R8, R9}
initialization:
//R6, R0, x
//R7, R1, y
//R8, R2, color
//R9 x max
		MOV    R6, #-1       //x
		MOV	   R7, #0       //y
		MOV    R8, #0       //color
		
		MOV		R9, #300
		ADD 	R9, R9, #20 //x-max 320, y-max 240

outter_increment:
		ADD		R6, R6, #1
		CMP     R6, R9
		POPEQ 	{R5, R6, R7, R8, R9}
		BXEQ    LR          //x reach end, execution finished
		MOV		R7, #0
		B		inner_loop
inner_loop:
		MOV		R1, R7
		MOV		R0, R6
		MOV		R2, #0
		PUSH	{LR}
		BL		VGA_draw_point_ASM
		POP		{LR}
		ADD		R7, R7, #1
		CMP		R7, #240
		BGE		outter_increment
		B		inner_loop
		
	
VGA_write_char_ASM:
//ASCII <- R2, x <- R0, y<- R1
// x needs to be in [0, 79], y needs to be in [0, 59]
//R4 <- address
		PUSH	{R4, R5, R6, R7, R8, R9}
		CMP		R0, #0
		POPLT	{R4, R5, R6, R7, R8, R9}
		BXLT	LR
		CMP		R0, #79
		POPGT	{R4, R5, R6, R7, R8, R9}
		BXGT	LR
		CMP		R1, #0
		POPLT	{R4, R5, R6, R7, R8, R9}
		BXLT	LR
		CMP		R1, #59
		POPGT	{R4, R5, R6, R7, R8, R9}
		BXGT	LR
		LDR		R4, =character_buffer_memory
		LSL		R1, R1, #7                   //Logic shift y by 7 bits
		ADD		R4, R4, R0					//add x into address
		ADD		R4, R4, R1					//add y into address
		STRB	R2, [R4]					//store char into address
		POP		{R4, R5, R6, R7, R8, R9}
		BX		LR
		
VGA_clear_charbuff_ASM: 
//R6, R0, x
//R7, R1, y
//R8, R2, color
//R9 x max
	PUSH   {R5, R6, R7, R8, R9}
initialization_c:
		MOV    R6, #-1       //x
		MOV	   R7, #0       //y
	
		MOV		R9, #300
		ADD 	R9, R9, #20 //x-max 320, y-max 240

outter_increment_c:
		ADD		R6, R6, #1
		CMP     R6, R9
		POPEQ 	{R5, R6, R7, R8, R9}
		BXEQ    LR          //x reach end, execution finished
		MOV		R7, #0
		B		inner_loop_c
inner_loop_c:
	
		MOV		R2, #0
		MOV		R1, R7
		MOV     R0, R6
		PUSH    {LR}
		BL		VGA_write_char_ASM
		POP		{LR}
		ADD		R7, R7, #1
		CMP		R7, #240
		BEQ		outter_increment_c
		B		inner_loop_c	

draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320               //320 pixels wide 
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6			//print the most significant 32 bits
        asr     r3, r6, #31              //R3  <- R6 < 31
        rsb     r7, r3, r7, asr #2		// R7 = (R7 > 2) - R3
        lsl     r7, r7, #5              //R7 <- R7 << 5
        lsl     r5, r6, #5			    // R5 <- R6 << 5
        mov     r4, #0					// R4 = 0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5			//print the most significant 32 bits
        add     r3, r2, r5				//R3 <- R2 + R5
        asr     r2, r5, #31				//R2 <- R5 > 31
        rsb     r2, r2, r3, asr #9		//R2 = (R3 > 9) -R2
        orr     r2, r7, r2, lsl #11     //R2 = R7 OR (R2 << 11)
        lsl     r3, r4, #5 				//R3 <- R4 << 5
        smull   r0, r1, r8, r3			//print the most significant 32 bits
        add     r1, r1, r3				//R1 = R1 +R3
        asr     r3, r3, #31				//R3 <- R3 >31
        rsb     r3, r3, r1, asr #7      //R3 = (R1 > 7) - R1
		
        orr     r2, r2, r3    			//base address (color)
        mov     r1, r4					//height - rows
        mov     r0, r6					//width -columns
		
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240                  //240 pixels high
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071
	
	