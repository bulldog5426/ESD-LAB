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
    LDR     R0, =numbers   ; Load the base address of the numbers into R0
    MOV     R1, #10        ; Load the loop counter with 10 (for 10 numbers)
    MOV     R2, #0         ; Clear R2 to accumulate the sum

sum_loop
    LDR     R3, [R0], #4   ; Load the next number into R3, post-increment R0
    ADD     R2, R2, R3     ; Add the number in R3 to the accumulator R2
    SUBS    R1, R1, #1     ; Decrement the loop counter
    BNE     sum_loop       ; If R1 is not zero, branch back to sum_loop

    LDR     R0, =result    ; Load the address of the result variable
    STR     R2, [R0]       ; Store the accumulated sum into the result

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
result
    DCD     0              ; Reserve a word to store the result

    AREA    mycode, CODE, READONLY
numbers
    DCD     0x11111111, 0x22222222, 0x33333333, 0x44444444, 0x55555555
    DCD     0x66666666, 0x77777777, 0x88888888, 0x99999999, 0xAAAAAAAA

    END
