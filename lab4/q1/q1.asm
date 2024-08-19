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
    LDR     R0, =hex_num       ; Load address of the hexadecimal number
    LDR     R1, =ascii_result  ; Load address of where to store ASCII result

    LDRB    R2, [R0]           ; Load the 2-digit hex number into R2

    ; Extract high nibble
    MOV     R3, R2, LSR #4     ; Shift right to get the high nibble into R3
    BL      HexToASCII         ; Convert high nibble to ASCII
    STRB    R3, [R1]           ; Store ASCII result

    ; Extract low nibble
    AND     R2, R2, #0x0F      ; Mask out the low nibble in R2
    BL      HexToASCII         ; Convert low nibble to ASCII
    STRB    R2, [R1, #1]       ; Store the second ASCII result

STOP
    B       STOP               ; Infinite loop to stop the program

; Function: Convert a hexadecimal nibble (0-15) into an ASCII value
HexToASCII
    CMP     R3, #9             ; Compare the nibble with 9
    BLE     convert_digit      ; If <= 9, it's a number (0-9)

    ; Convert letters A-F (nibbles 0xA - 0xF)
    ADD     R3, R3, #0x37      ; Convert nibble to ASCII letter (A-F)

    BX      LR                 ; Return from subroutine

convert_digit
    ADD     R3, R3, #0x30      ; Convert nibble to ASCII number (0-9)
    BX      LR                 ; Return from subroutine

    AREA    mydata, DATA, READWRITE
hex_num
    DCB     0x3A               ; Example 2-digit hex number (0x3A)
ascii_result
    DCB     0x00, 0x00         ; Reserve 2 bytes for ASCII result

    END
