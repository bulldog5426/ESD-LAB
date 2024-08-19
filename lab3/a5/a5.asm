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
    LDR     R0, =bcd1      ; Load address of the first BCD number into R0
    LDR     R1, =bcd2      ; Load address of the second BCD number into R1
    LDR     R2, =result    ; Load address where the result will be stored

    LDRB    R3, [R0]       ; Load the first BCD number into R3
    LDRB    R4, [R1]       ; Load the second BCD number into R4

    ; Extract the upper and lower nibbles of BCD1
    MOV     R5, R3, LSR #4 ; Extract upper nibble of bcd1 (high BCD digit)
    AND     R3, R3, #0x0F  ; Extract lower nibble of bcd1 (low BCD digit)

    ; Extract the upper and lower nibbles of BCD2
    MOV     R6, R4, LSR #4 ; Extract upper nibble of bcd2 (high BCD digit)
    AND     R4, R4, #0x0F  ; Extract lower nibble of bcd2 (low BCD digit)

    ; Multiply the lower digits of both numbers
    MUL     R7, R3, R4     ; R7 = (low BCD1) * (low BCD2)

    ; Multiply the upper digit of BCD1 with the lower digit of BCD2
    MLA     R7, R5, R4, R7 ; R7 += (high BCD1) * (low BCD2)

    ; Multiply the upper digit of BCD2 with the lower digit of BCD1
    MLA     R7, R6, R3, R7 ; R7 += (high BCD2) * (low BCD1)

    ; Multiply the upper digits of both numbers
    MLA     R7, R5, R6, R7 ; R7 += (high BCD1) * (high BCD2)

    ; Adjust the result to BCD format using the carry
    MOV     R8, #0         ; Clear carry

adjust_bcd
    CMP     R7, #100       ; Compare result with 100
    SUBCS   R7, R7, #100   ; Subtract 100 if carry
    ADDCS   R8, R8, #1     ; Add carry to R8

    CMP     R8, #10        ; Compare upper nibble with 10
    BGE     adjust_bcd     ; Repeat adjustment if greater than 9

    ; Store the result in BCD format
    MOV     R7, R7, LSL #4 ; Shift result by 4 bits to the left
    ORR     R7, R7, R8     ; Combine result with the carry
    STRB    R7, [R2]       ; Store the BCD result in memory

STOP
    B       STOP           ; Infinite loop to stop the program

    AREA    mydata, DATA, READWRITE
bcd1
    DCB     0x12           ; First BCD number (example: 12 in BCD format)
bcd2
    DCB     0x34           ; Second BCD number (example: 34 in BCD format)
result
    DCB     0x00           ; Reserve a byte to store the result in BCD format

    END
