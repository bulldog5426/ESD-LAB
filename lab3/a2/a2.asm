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
    LDR     R0, =n         ; Load address of the number n
    LDR     R1, =result    ; Load address where the result will be stored

    LDR     R2, [R0]       ; Load the value of n into R2
    MOV     R3, #0         ; Initialize the sum to 0
    MOV     R4, #1         ; Initialize the loop counter to 1

    ; Loop to compute the sum using MLA
sum_loop
    MLA     R3, R4, R4, R3 ; R3 = R3 + R4 * R4
    ADD     R4, R4, #1     ; Increment the loop counter
    CMP     R4, R2         ; Compare loop counter with n
    BLE     sum_loop       ; If loop counter <= n, repeat the loop

    ; Divide the sum by 2 to get the final result
    MOV     R5, #2
    UDIV    R3, R3, R5     ; Divide the accumulated sum by 2

    STR     R3, [R1]       ; Store the result in memory

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
n   DCD     10             ; Number of natural numbers (change as needed)
result
    DCD     0              ; Reserve a word to store the result

    END
