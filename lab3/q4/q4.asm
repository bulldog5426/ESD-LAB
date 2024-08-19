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
    LDR     R0, =a         ; Load address of first number (a)
    LDR     R1, =b         ; Load address of second number (b)
    LDR     R2, =result    ; Load address where the result will be stored

    LDR     R3, [R0]       ; Load the value of a into R3
    LDR     R4, [R1]       ; Load the value of b into R4

    MOV     R5, #1         ; Initialize counter i to 1

calculate_lcm
    MUL     R6, R5, R3     ; Calculate i * a
    MOV     R7, R4         ; Copy b to R7
    UDIV    R8, R6, R7     ; Divide (i * a) by b, quotient is in R8
    MUL     R9, R8, R7     ; Calculate (i * a) - (i * a // b) * b
    SUB     R9, R6, R9     ; R9 = (i * a) % b (remainder)

    CMP     R9, #0         ; Check if remainder == 0
    BEQ     found_lcm      ; If zero, we found the LCM

    ADD     R5, R5, #1     ; Increment i
    B       calculate_lcm  ; Repeat the process

found_lcm
    STR     R6, [R2]       ; Store the result (i * a)

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
a   DCD     12             ; First number (change as needed)
b   DCD     15             ; Second number (change as needed)
result
    DCD     0              ; Reserve a word to store the result

    END
