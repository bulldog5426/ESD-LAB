	; AREA	RESET , DATA , READONLY
	; EXPORT __Vectors	
; __Vectors
	; DCD 0X10001000 ;stack pointer value stack is empty
	; DCD Reset_Handler ;reset vector
	; ALIGN
	AREA mycode , CODE, READONLY
	ENTRY
	; EXPORT Reset_Handler
; Reset_Handler
	MOV R3, #5
	LDR R0, =N;
	LDR R1, =DST;
BACK 
	LDR R2, [R0], #4
	STR R2, [R1], #4 
	SUB R3, #1
	CMP R3, #0
	BNE BACK	
STOP
	B STOP

	AREA mydata , DATA , READWRITE
N DCD 0X12345678,0x6A,0x234,0x49C,0xA13BC
DST DCD 0,0,0,0,0
	END