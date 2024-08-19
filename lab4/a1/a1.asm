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
    LDR     R0, =ascii_num     ; Load address of the ASCII unpacked hex digits
    LDR     R1, =packed_hex    ; Load address to store the packed hex result

    LDRB    R2, [R0]           ; Load the first ASCII digit into R2 (high nibble)
    LDRB    R3, [R0, #1]       ; Load the second ASCII digit into R3 (low nibble)

    ; Convert ASCII high nibble ('0'-'9', 'A'-'F') to hex value
    BL      ConvertASCIIToHex  ; Call subroutine for high nibble
    MOV     R4, R2             ; Store high nibble in R4
    LSL     R4, R4, #4         ; Shift high nibble left by 4 bits to make space for low nibble

    ; Convert ASCII low nibble ('0'-'9', 'A'-'F') to hex value
    MOV     R2, R3             ; Move low nibble into R2 for conversion
    BL      ConvertASCIIToHex  ; Call subroutine for low nibble

    ; Combine high and low nibbles into packed hex
    ORR     R4, R4, R2         ; Combine the high nibble in R4 with the low nibble in R2

    ; Store the packed hex result
    STRB    R4, [R1]           ; Store the packed hexadecimal value in memory

STOP
    B       STOP               ; Infinite loop to stop execution

; Subroutine: Convert ASCII hex digit to binary hex value
ConvertASCIIToHex
    CMP     R2, #'9'           ; Compare with '9'
    BLS     is_digit           ; If <= '9', it's a digit (0-9)
    SUB     R2, R2, #0x37      ; Convert 'A'-'F' to 0xA-0xF (subtract 0x37 for uppercase)
    BX      LR                 ; Return from subroutine

is_digit
    SUB     R2, R2, #0x30      ; Convert '0'-'9' to 0x0-0x9 (subtract 0x30)
    BX      LR                 ; Return from subroutine

    AREA    mydata, DATA, READWRITE
ascii_num
    DCB     "3", "A"           ; ASCII unpacked form of hex number '3A'
packed_hex
    DCB     0x00               ; Reserve a byte to store the packed hex result

    END
