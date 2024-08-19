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
    LDR     R0, =unpacked_num  ; Load the address of the unpacked number
    LDR     R1, =packed_num    ; Load the address where the packed result will be stored

    MOV     R2, #4             ; Set counter for 4 bytes (32-bit number)

pack_loop
    LDRB    R3, [R0], #1       ; Load the first unpacked digit (high nibble)
    LDRB    R4, [R0], #1       ; Load the second unpacked digit (low nibble)
    
    ; Convert ASCII digits ('0'-'9') to hex values
    SUB     R3, R3, #0x30      ; Convert first ASCII digit to binary (high nibble)
    SUB     R4, R4, #0x30      ; Convert second ASCII digit to binary (low nibble)

    LSL     R3, R3, #4         ; Shift the high nibble left by 4 bits
    ORR     R3, R3, R4         ; Combine high and low nibbles

    STRB    R3, [R1], #1       ; Store the packed byte in memory

    SUBS    R2, R2, #1         ; Decrement counter
    BNE     pack_loop          ; Repeat until all digits are processed

STOP
    B       STOP               ; Infinite loop to stop execution

    AREA    mydata, DATA, READWRITE
unpacked_num
    DCB     "1", "2", "3", "4", "5", "6", "7", "8" ; Unpacked 32-bit number in ASCII form
packed_num
    DCB     0x00, 0x00, 0x00, 0x00 ; Reserve space for the packed 32-bit number

    END
