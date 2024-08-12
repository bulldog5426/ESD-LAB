    ; AREA    RESET, DATA, READONLY
    ; EXPORT  __Vectors	
; __Vectors
    ; DCD     0x10001000     ; Stack pointer value, stack is empty
    ; DCD     Reset_Handler  ; Reset vector
    ; ALIGN

    AREA    mycode, CODE, READONLY
    ENTRY
    ; EXPORT  Reset_Handler

; Reset_Handler
    LDR     R0, =N         ; Load the base address of source array N into R0
    LDR     R1, =DST       ; Load the base address of destination array DST into R1
    MOV     R3, #5         ; Load loop counter with 5 (for 5 32-bit numbers)

copy_loop
    LDR     R2, [R0], #4   ; Load a 32-bit word from N into R2, post-increment R0 by 4
    STR     R2, [R1], #4   ; Store the 32-bit word from R2 into DST, post-increment R1 by 4
    SUBS    R3, R3, #1     ; Decrement loop counter R3
    BNE     copy_loop      ; If R3 is not zero, branch back to copy_loop

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
N   DCD     0x12345678, 0x6A, 0x234, 0x49C, 0xA13BC  ; Source array
DST DCD     0, 0, 0, 0, 0                            ; Destination array
    END
