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
    LDR     R0, =num1      ; Load the base address of the first 128-bit number into R0
    LDR     R1, =num2      ; Load the base address of the second 128-bit number into R1
    LDR     R2, =result    ; Load the base address where the result will be stored into R2

    MOV     R4, #0         ; Clear borrow flag (R4 = 0)

    ; Subtract the least significant 32-bit segment
    LDR     R5, [R0]       ; Load the least significant word of num1 into R5
    LDR     R6, [R1]       ; Load the least significant word of num2 into R6
    SUBS    R7, R5, R6     ; Subtract num2 from num1, store result in R7, set flags
    STR     R7, [R2], #4   ; Store result and increment the result pointer
    SBCS    R4, R4, #0     ; Subtract borrow from R4 (if any), R4 now holds the borrow

    ; Subtract the second 32-bit segment
    LDR     R5, [R0, #4]   ; Load the second word of num1 into R5
    LDR     R6, [R1, #4]   ; Load the second word of num2 into R6
    SBCS    R7, R5, R6     ; Subtract num2 from num1 including borrow, store result in R7
    STR     R7, [R2], #4   ; Store result and increment the result pointer

    ; Subtract the third 32-bit segment
    LDR     R5, [R0, #8]   ; Load the third word of num1 into R5
    LDR     R6, [R1, #8]   ; Load the third word of num2 into R6
    SBCS    R7, R5, R6     ; Subtract num2 from num1 including borrow, store result in R7
    STR     R7, [R2], #4   ; Store result and increment the result pointer

    ; Subtract the most significant 32-bit segment
    LDR     R5, [R0, #12]  ; Load the most significant word of num1 into R5
    LDR     R6, [R1, #12]  ; Load the most significant word of num2 into R6
    SBCS    R7, R5, R6     ; Subtract num2 from num1 including borrow, store result in R7
    STR     R7, [R2]       ; Store result (no need to increment the pointer)

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
result
    SPACE   16             ; Reserve 16 bytes (4 words) for the 128-bit result

    AREA    mycode, CODE, READONLY
num1
    DCD     0x11111111, 0x22222222, 0x33333333, 0x44444444 ; First 128-bit number
num2
    DCD     0xAAAAAAAA, 0xBBBBBBBB, 0xCCCCCCCC, 0xDDDDDDDD ; Second 128-bit number

    END
