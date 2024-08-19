    AREA    RESET, DATA, READONLY
    EXPORT  __Vectors
__Vectors
    DCD     0x10001000         ; Stack pointer value, stack is empty
    DCD     Reset_Handler      ; Reset vector
    ALIGN

    AREA    mycode, CODE, READONLY
    ENTRY
    EXPORT  Reset_Handler

Reset_Handler
    LDR     R0, =hex_num       ; Load the address of the hexadecimal number
    LDR     R1, =bcd_result    ; Load the address to store the BCD result

    LDRB    R2, [R0]           ; Load the 2-digit hex number into R2
    MOV     R3, #0             ; Initialize R3 to hold the decimal equivalent

    ; Convert hexadecimal to decimal
    MOV     R4, #0             ; Initialize R4 for result
    MOV     R5, #10            ; Initialize base 10 for decimal division

convert_loop
    CMP     R2, #0             ; Check if the hex number is zero
    BEQ     conversion_done    ; If zero, we're done converting

    UDIV    R6, R2, R5         ; Divide R2 by 10 (R6 = R2 / 10)
    MLS     R7, R6, R5, R2     ; R7 = R2 - (R6 * 10) -> remainder
    ORR     R3, R3, R7, LSL #4 ; Shift the remainder and store it in R3
    MOV     R2, R6             ; Set R2 to the quotient for the next iteration
    B       convert_loop       ; Continue the loop

conversion_done
    STRB    R3, [R1]           ; Store the resulting BCD in memory

STOP
    B       STOP               ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
hex_num
    DCB     0x3A               ; Example 2-digit hex number (0x3A = 58 in decimal)
bcd_result
    DCB     0x00               ; Reserve a byte to store the BCD result

    END
