.global _start

.equ ps2, 0xff200100
.equ pixel_buffer_memory, 0xc8000000
.equ character_buffer_memory, 0xc9000000

input_mazes:// First Obstacle Course
            .word 0,1,0,1,1,1,0,0,0,1,0,1
            .word 0,1,0,1,1,1,0,0,0,1,0,1
            .word 0,1,0,0,0,0,0,0,0,1,0,1
            .word 0,1,0,1,1,1,0,0,0,1,1,1
            .word 0,1,0,1,1,1,0,0,0,1,1,1
            .word 0,0,0,1,1,1,0,0,0,1,1,1
            .word 1,1,1,1,1,1,0,0,1,0,0,0
            .word 1,1,1,1,1,1,0,1,0,0,0,0
            .word 1,1,1,1,1,1,0,0,0,0,0,0
_start:
			BL   VGA_fill_ASM
			PUSH {LR}
			BL  draw_grid_ASM
			POP {LR}
			MOV	R0, #7
			MOV	R1, #7
			BL	draw_ampersand_ASM
			MOV	R0, #61
			MOV R1, #47
			PUSH	{LR}
			BL  draw_exit_ASM
			POP		{LR}
			PUSH	{LR}
			BL	fill_grid_ASM
			POp		{LR}
			B	end
end:
			B  end
		

			
VGA_fill_ASM:
	PUSH    {R5, R6, R7, R8, R9}
initialization:
//R6, R0, x
//R7, R1, y
//R8, R2, color
//R9 x max
		MOV    R6, #-1       //x
		MOV	   R7, #0       //y
		
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
		MOV		R2, #0b111111000000
		PUSH	{LR}
		BL		VGA_draw_point_ASM
		POP		{LR}
		ADD		R7, R7, #1
		CMP		R7, #240
		BGE		outter_increment
		B		inner_loop
		
draw_grid_ASM:
		PUSH    {R5, R6, R7, R8, R9}
//R6 -> X R0
//R7 -> Y R1
//R5 -> X max 296
//R8 -> color R2
init:
		MOV		R6, #20				//X
		MOV 	R7, #20				//Y
		MOV		R8, #0		//blue
		MOV		R5, #260            // max X 296, Max Y 200
X_grid:
		CMP		R6, R5                // start of x always 20, end 296, y value inc 20
		BEQ     y_increment
		MOV		R0, R6
		MOV		R1, R7
		MOV		R2, R8
		PUSH	{LR}
		BL		VGA_draw_point_ASM
		POP		{LR}
		ADD		R6, R6, #1
		B		X_grid
		
y_increment: 
		CMP		R7, #200
		BEQ		y_grid_init
		ADD		R7, R7, #20
		MOV		R6, #20
		B		X_grid

y_grid_init: 
		MOV		R6, #20
		MOV		R7, #20
y_grid:
		CMP		R7, #200
		BEQ		x_increment
		MOV		R0, R6
		MOV		R1, R7
		MOV		R2, R8
		PUSH	{LR}
		BL		VGA_draw_point_ASM
		POP		{LR}
		ADD		R7, R7, #1
		B y_grid
x_increment:
		MOV		R5, #260
		CMP		R6, R5
		POPEQ   {R5, R6, R7, R8, R9}  ///end of drawing grid
		BXEQ	LR
		ADD		R6, R6, #20
		MOV		R7, #20
		B		y_grid
draw_ampersand_ASM:
//ampersand 38, R0->X, R1-> Y
		MOV		R2, #38
		PUSH	{LR}
		BL		VGA_write_char_ASM
		POP		{LR}
		BX		LR
draw_exit_ASM:
//2 input arguments , X  and Y
//EXIT have same Y (-> R1), different X(R0, R0+1, R0+2, R0+3)
//E-69, X-88, I-73, T-84
//R0-X, R1-Y
		PUSH	{R6, R7}
		MOV		R6, R0
		MOV		R7, R1
		
		MOV		R2, #69  //E
		PUSH	{LR}
		BL		VGA_write_char_ASM
		POP		{LR}
		MOV		R2, #88   //X
		ADD		R6, R6, #1
		MOV		R0, R6
		MOV		R1, R7
		PUSH	{LR}
		BL		VGA_write_char_ASM
		POP		{LR}
		MOV		R2, #73   //I
		ADD		R6, R6, #1
		MOV		R0, R6
		MOV		R1, R7
		PUSH	{LR}
		BL		VGA_write_char_ASM
		POP		{LR}
		MOV		R2, #84
		ADD		R6, R6, #1
		MOV		R0, R6
		MOV		R1, R7
		PUSH	{LR}
		BL		VGA_write_char_ASM
		POP		{LR}
		POP		{R6, R7}
		BX		LR
draw_obstacles_ASM:
//R0-> X, R1 -> Y, obstacles #219
		MOV		R2, #36
		PUSH    {LR}
		BL		VGA_write_char_ASM
		POP		{LR}
		BX 		LR
		
fill_grid_ASM:
// takes 1 argument -> the number of the obstacle course
//X stat at 5, each square 4 length
//array stored in R0 
//draw_obstacle_ASM: R0->X, R1 -> Y
		PUSH    {R5, R6, R7, R8, R9, R10, R11}
		
//initial X-Y 7/7 center of first square
//X 7-51
//Y 7-39
//counter R9, if R9 = 11, Y+4
		LDR		R5, =input_mazes
		MOV		R6, #7		//init x    move 5
		MOV 	R7, #7		//init y    move 5
		MOV		R8, #108       //arraylength
		MOV		R9, #0			// R9 <- i =1

	
x_grid_increment:
	    CMP		R9, R8
		BGE		end_for_loop
		LDR		R10, [R5, R9, LSL #2] // array[i]
		
		
		MOV		R0, R6
		MOV		R1, R7
		CMP     R10, #1
		BEQ     draw_obstacle
back:
		ADD		R6, R6, #5
		ADD     R9, R9, #1
		CMP		R6, #67
		BEQ		y_grid_increment
		B		x_grid_increment
		
y_grid_increment:
		//CMP		R7, #47
		//BGT		end_for_loop
		ADD		R7, R7, #5
		MOV		R6, #7
		B		x_grid_increment

end_for_loop:
		POP		{R5, R6, R7, R8, R9, R10, R11}
		BX		LR
draw_obstacle:
		PUSH	{LR}
		BL		draw_obstacles_ASM
		POP		{LR}
		B		back
		//ADD		R6, R6, #5
		//ADD     R9, R9, #1
		//B		x_grid_increment
move_ASM:
// moves the & if there is no obstacle in that position

result_ASM:
// takes
VGA_draw_point_ASM:
//should only access pixel buffer memoy
//color indicated in the third argument
// x is the column <- R0, y is the row  <-R1
//color R2
		PUSH   {R4, R5, R6, R7, R8, R9}	
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
	