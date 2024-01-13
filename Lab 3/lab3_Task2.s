.global _start
.equ ps2, 0xff200100
.equ pixel_buffer_memory, 0xc8000000
.equ character_buffer_memory, 0xc9000000
_start:
        bl      input_loop
end:
        b       end

@ TODO: copy VGA driver here.
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

@ TODO: insert PS/2 driver here.

//intput R0: memory address in which data read stored
//Check Rvalid bit
//if valid, data from same register should be stored in pointer argument
//subroutine return 1
//else subroutine return 0

	
read_PS2_data_ASM:
		LDR		R1, =ps2
		LDR		R2, [R1]
		MOV		R3, R2
		LSR		R2, R2, #15
		AND		R2, R2, #0x1	
		CMP		R2, #1
		BNE		not_read
		STRB	R3, [R0]
		MOV	    R0, #1
		BX		LR
not_read:
		MOV		R0, #0
		BX		LR
write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
