    AREA    RESET, DATA, READONLY
    EXPORT  __Vectors
__Vectors
    DCD     0x10001000     ; Stack pointer value, stack is empty
    DCD     Reset_Handler  ; Reset vector
    ALIGN

    AREA    mycode, CODE, READONLY
    ENTRY
    EXPORT  Reset_Handler

Reset_Handler
    LDR     R0, =num1      ; Load address of the first number into R0
    LDR     R1, =num2      ; Load address of the second number into R1
    LDR     R2, =result    ; Load address where the result will be stored into R2

    LDR     R3, [R0]       ; Load the value of num1 into R3
    LDR     R4, [R1]       ; Load the value of num2 into R4

    MOV     R5, #0         ; Initialize sum to 0
    MOV     R6, #0         ; Initialize carry to 0 (R6 will be used for carry)

multiply_loop
    CMP     R4, #0         ; Compare R4 (num2) with 0
    BEQ     done           ; If R4 == 0, exit the loop
    
    ADD     R5, R5, R3     ; Add R3 (num1) to sum
    SUBS    R4, R4, #1     ; Decrement R4 (num2) by 1
    ADCS    R6, R6, #0     ; Add carry to sum (if there was a carry from previous addition)

    B       multiply_loop  ; Repeat the loop

done
    STR     R5, [R2]       ; Store the result in memory

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
num1
    DCD     12             ; First 32-bit number (change as needed)
num2
    DCD     15             ; Second 32-bit number (change as needed)
result
    DCD     0              ; Reserve a word to store the result

    END
