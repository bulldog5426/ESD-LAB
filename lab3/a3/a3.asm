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
    LDR     R0, =a         ; Load address of the first number (a)
    LDR     R1, =b         ; Load address of the second number (b)
    LDR     R2, =result    ; Load address where the result will be stored

    LDR     R3, [R0]       ; Load the value of a into R3
    LDR     R4, [R1]       ; Load the value of b into R4

    ; GCD calculation loop
gcd_loop
    CMP     R3, R4         ; Compare a and b
    BEQ     done           ; If a == b, we are done
    
    BGT     subtract_a     ; If a > b, subtract b from a
    SUB     R4, R4, R3     ; Else subtract a from b
    B       gcd_loop       ; Repeat the loop

subtract_a
    SUB     R3, R3, R4     ; Subtract b from a
    B       gcd_loop       ; Repeat the loop

done
    STR     R3, [R2]       ; Store the result (GCD) in memory

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
a   DCD     56             ; First number (change as needed)
b   DCD     98             ; Second number (change as needed)
result
    DCD     0              ; Reserve a word to store the result

    END
