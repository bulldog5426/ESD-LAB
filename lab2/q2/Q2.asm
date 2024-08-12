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
    LDR     R0, =array     ; Load the base address of the array into R0
    LDR     R1, =array_end ; Load the end address of the array into R1
    SUB     R1, R1, #4     ; Adjust R1 to point to the last element of the array

reverse_loop
    CMP     R0, R1         ; Compare start and end pointers
    BGE     end_reverse    ; If start >= end, exit the loop

    LDR     R2, [R0]       ; Load the value at R0 into R2
    LDR     R3, [R1]       ; Load the value at R1 into R3

    STR     R2, [R1]       ; Store the value from R0 into R1
    STR     R3, [R0]       ; Store the value from R1 into R0

    ADD     R0, R0, #4     ; Move R0 to the next element
    SUB     R1, R1, #4     ; Move R1 to the previous element

    B       reverse_loop   ; Repeat the process

end_reverse
    B       end_reverse    ; Infinite loop to end the program

    AREA    mydata, DATA, READWRITE
array
    DCD     0x11111111, 0x22222222, 0x33333333, 0x44444444, 0x55555555
    DCD     0x66666666, 0x77777777, 0x88888888, 0x99999999, 0xAAAAAAAA
array_end
    END
