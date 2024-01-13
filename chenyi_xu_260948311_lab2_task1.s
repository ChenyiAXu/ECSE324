.global _start
	
// Sider Switches Driver
// returns the state of slider switches in R0
.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000

.equ ADDR_7SEG1, 0xFF200020
.equ ADDR_7SEG2, 0xFF200030

.equ PB0, 0x00000001
.equ PB1, 0x00000002 
.equ PB2, 0x00000004
.equ PB3, 0x00000008 

.equ    PB_DATA, 0xFF200050       
.equ    PB_MASK, 0xFF200058        
.equ    PB_EDGE, 0xFF20005C

_start:

infinite_loop: 
// write infinite loop calls read and write in order 
	BL read_slider_switches_ASM 
	//save the state every time use it 
	MOV R4, R0                       //switch input 
	BL write_LEDs_ASM
	//SW9 clear all hex displays  - hex-clear
	MOV R5, #0b1000000000
	TST R5, R4
	BNE display_turnOff
	//turn on hex4 & hex5
	//hex flood use R0 to take input
	MOV R0, #0x00000030
	BL HEX_flood_ASM
	//SW 0-3
	MOV R5, #0b0000001111
	AND R5, R5, R4               //R5 <- input numbers 0-15
	BL read_PB_edgecp_ASM
	CMP R0, #0
	BLNE PB_clear_edgecp_ASM
	//hex write --R0 as integer input, R1 as hex display int
	MOV R1, R0
	MOV R0, R5
	BL HEX_write_ASM
	
	B infinite_loop 

display_turnOff:
//hex_clear has R0 as input indice
//turn everything off
	MOV R0, #0xFFFFFFFF
	BL HEX_clear_ASM
	B infinite_loop

read_slider_switches_ASM:
    LDR R1, =SW_MEMORY
    LDR R0, [R1]
    BX  LR
	
write_LEDs_ASM:
    LDR R1, =LED_MEMORY
    STR R0, [R1]
    BX  LR
 //R0 is the input dice used to pass argument
HEX_flood_ASM:
  PUSH {R3-R4}
hex_0:
  MOV R1, #0x00000001
  TST R0, R1
  BEQ hex_1
 
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0x000000FF
  ORR R3, R3, R4
  STR R3, [R2]
  
hex_1:
  MOV R1, #0x00000002
  TST R0, R1
  BEQ hex_2
  
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0x0000FF00
  ORR R3, R3, R4
  STR R3, [R2]
  
  
hex_2:
  MOV R1, #0x00000004
  TST R0, R1
  BEQ hex_3
  
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0x00FF0000
  ORR R3, R3, R4
  STR R3, [R2]
  
  
hex_3:
  MOV R1, #0x00000008
  TST R0, R1
  BEQ hex_4
  
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0xFF000000
  ORR R3, R3, R4
  STR R3, [R2]
  
hex_4:
  MOV R1, #0x00000010
  TST R0, R1
  BEQ hex_5
  
  LDR R2, =ADDR_7SEG2
  LDR R3, [R2]
  MOV R4, #0x00FF
  ORR R3, R3, R4
  STR R3, [R2]
  

hex_5:
  MOV R1, #0x00000020
  TST R0, R1
  BEQ hex_flood_end

  LDR R2, =ADDR_7SEG2
  LDR R3, [R2]
  MOV R4, #0xFF00
  ORR R3, R3, R4
  STR R3, [R2]
hex_flood_end: 
  POP {R3-R4}
  BX LR
  
HEX_clear_ASM:
//R0 input indice
  PUSH {R3-R4}
hex_0_c:
  MOV R1, #0x00000001
  TST R0, R1
  BEQ hex_1_c
  
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0xFFFFFF00
  AND R3, R3, R4
  STR R3, [R2]
  
hex_1_c:
  MOV R1, #0x00000002
  TST R0, R1
  BEQ hex_2_c
  
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0xFFFF00FF
  AND R3, R3, R4
  STR R3, [R2]
 
hex_2_c:
  MOV R1, #0x00000004
  TST R0, R1
  BEQ hex_3_c
  
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0xFF00FFFF
  AND R3, R3, R4
  STR R3, [R2]
 
hex_3_c:
  MOV R1, #0x00000008
  TST R0, R1
  BEQ hex_4_c
  
  LDR R2, =ADDR_7SEG1
  LDR R3, [R2]
  MOV R4, #0x00FFFFFF
  AND R3, R3, R4
  STR R3, [R2]
 
hex_4_c:
  MOV R1, #0x00000010
  TST R0, R1
  BEQ hex_5_c
  
  LDR R2, =ADDR_7SEG2
  LDR R3, [R2]
  MOV R4, #0xFF00
  AND R3, R3, R4
  STR R3, [R2]
 
hex_5_c:
  MOV R1, #0x00000020
  TST R0, R1
  BEQ hex_clear_end
  
  LDR R2, =ADDR_7SEG2
  LDR R3, [R2]
  MOV R4, #0x00FF
  AND R3, R3, R4
  STR R3, [R2]
hex_clear_end: 
  POP {R3-R4}
  BX LR
  
HEX_write_ASM:
//R0-integer input
//R1 hex input
PUSH {R3-R5}
display_int:
//0
  MOV R2, #0x0
  CMP R2, R0
  MOVEQ R2, #0b00111111
  BEQ hex_display
//1
  MOV R2, #0x1
  CMP R2, R0
  MOVEQ R2, #0b00000110
  BEQ hex_display
 //2
  MOV R2, #0x2
  CMP R2, R0
  MOVEQ R2, #0b01011011
  BEQ hex_display
//int_3:
  MOV R2, #0x3
  CMP R2, R0
  MOVEQ R2, #0b01001111
  BEQ hex_display
//int_4:
  MOV R2, #0x4
  CMP R2, R0
  MOVEQ R2, #0b01100110
  BEQ hex_display
//int_5:
  MOV R2, #0x5
  CMP R2, R0
  MOVEQ R2, #0b01101101
  BEQ hex_display
//int_6:
  MOV R2, #0x6
  CMP R2, R0
  MOVEQ R2, #0b01111101
  BEQ hex_display
//int_7:
  MOV R2, #0x7
  CMP R2, R0
  MOVEQ R2, #0b00000111
  BEQ hex_display
//int_8:
  MOV R2, #0x8
  CMP R2, R0
  MOVEQ R2, #0b01111111
  BEQ hex_display
//int_9:
  MOV R2, #0x9
  CMP R2, R0
  MOVEQ R2, #0b01101111
  BEQ hex_display
//int_A:
  MOV R2, #0xA
  CMP R2, R0
  MOVEQ R2, #0b01110111
  BEQ hex_display
//int_B:
  MOV R2, #0xB
  CMP R2, R0
  MOVEQ R3, #0b01111100
  BEQ hex_display
//int_C:
  MOV R2, #0xC
  CMP R2, R0
  MOVEQ R2, #0b00111001
  BEQ hex_display
//int_D:
  MOV R2, #0xD
  CMP R2, R0
  MOVEQ R2, #0b01011110
  BEQ hex_display
//int_E:
  MOV R2, #0xE
  CMP R2, R0
  MOVEQ R2, #0b1111001
  BEQ hex_display
//int_F:
  MOV R2, #0xF
  CMP R2, R0
  MOVEQ R2, #0b01110001
  BEQ hex_display
  
hex_display:
  //R2 integ input (from display_int), remember to shift
  //R1 hex display (input)
hex_0_w:
  MOV R3, #0x00000001
  TST R1, R3
  BEQ hex_1_w
  
  LDR R3, =ADDR_7SEG1
  LDR R4, [R3]
  MOV R5, #0xFFFFFF00
  AND R4, R4, R5
  ORR R4, R4, R2
  STR R4, [R3]
  

hex_1_w:
  MOV R3, #0x00000002
  TST R1, R3
  LSL R2, R2, #8
  BEQ hex_2_w
  
  LDR R3, =ADDR_7SEG1
  LDR R4, [R3]
  MOV R5, #0xFFFF00FF
  AND R4, R4, R5
  ORR R4, R4, R2
  STR R4, [R3]
  

hex_2_w:
  MOV R3, #0x00000004
  TST R1, R3
  LSL R2, R2, #8
  BEQ hex_3_w
  
  LDR R3, =ADDR_7SEG1
  LDR R4, [R3]
  MOV R5, #0xFF00FFFF
  AND R4, R4, R5
  ORR R4, R4, R2
  STR R4, [R3]
  
 
hex_3_w:
  MOV R3, #0x00000008
  TST R1, R3
  LSL R2, R2, #8
  BEQ hex_4_w
  
  LDR R3, =ADDR_7SEG1
  LDR R4, [R3]
  MOV R5, #0x00FFFFFF
  AND R4, R4, R5
  ORR R4, R4, R2
  STR R4, [R3]
  
hex_4_w:
  MOV R3, #0x00000010
  TST R1, R3
  LSR R2, R2, #24
  BEQ hex_5_w
  
  LDR R3, =ADDR_7SEG2
  LDR R4, [R3]
  MOV R5, #0xFF00
  AND R4, R4, R5
  ORR R4, R4, R2
  STR R4, [R3]
  
 hex_5_w:
  MOV R3, #0x00000020
  TST R1, R3
  LSL R2, R2, #8
  BEQ hex_write_end
 
  LDR R3, =ADDR_7SEG2
  LDR R4, [R3]
  MOV R5, #0x00FF
  AND R4, R4, R5
  ORR R4, R4, R2
  STR R4, [R3]

hex_write_end:
  POP {R3-R5}
  BX LR
  
read_PB_data_ASM:
    LDR R1, =PB_DATA
	LDR R0, [R1]
	BX LR
	
PB_data_is_pressed_ASM:
// RO input argument
    LDR R1, =PB_DATA
	LDR R0, [R1]
	LDR R3, =PB0
	TST R0, R3
	BEQ pb1
	MOV R2, #0x00000001

pb1:
	LDR R3, =PB1
	TST R0, R3
	BEQ pb2
	MOV R2, #0x00000001

pb2:
	LDR R3, =PB2
	TST R0, R3
	BEQ pb3
    MOV R2, #0x00000001

pb3:
	LDR R3, =PB3
	TST R0, R3
    MOVEQ R2, #0x00000001
	BX LR

read_PB_edgecp_ASM:
	LDR R1, =PB_EDGE
	LDR R0, [R1]
	BX  LR
PB_edgecp_is_pressed_ASM:
	// RO input argument
	LDR R1, =PB_EDGE
	LDR R0, [R1]
	
	LDR R3, =PB0
	TST R0, R3
	BEQ pb1_E
	MOV R2, #0x00000001

pb1_E:
	LDR R3, =PB1
	TST R0, R3
	BEQ pb2_E
	MOV R2, #0x00000001

pb2_E:
	LDR R3, =PB2
	TST R0, R3
	BEQ pb3_E
    MOV R2, #0x00000001

pb3_E:
	LDR R3, =PB3
	TST R0, R3
    MOVEQ R2, #0x00000001
	BX LR
	
PB_clear_edgecp_ASM:
	LDR R1, =PB_EDGE
	LDR R2, [R1]
	STR R2, [R1]
	BX LR
//Ro input indices 
enable_PB_INT_ASM:
	LDR R1, =PB_MASK
	STR R0, [R1]
	BX LR
	
disable_PB_INT_ASM: 
    LDR R1, =PB_MASK
	LDR R2, [R1]
	BIC R2, R2, R0
	STR R2, [R1]
	BX LR