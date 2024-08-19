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
    LDR     R0, =num1      ; Load the address of the first number into R0
    LDR     R1, =num2      ; Load the address of the second number into R1
    LDR     R2, =result    ; Load the address where the result will be stored into R2

    LDR     R3, [R0]       ; Load the value of num1 into R3
    LDR     R4, [R1]       ; Load the value of num2 into R4

    SUB     R5, R3, R4     ; Subtract num2 from num1, result in R5
    STR     R5, [R2]       ; Store the result in memory

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
num1
    DCD     0x12345678     ; First 32-bit number (change as needed)
num2
    DCD     0x87654321     ; Second 32-bit number (change as needed)
result
    DCD     0              ; Reserve a word to store the result

    END
