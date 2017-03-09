    AREA    lib, CODE, READWRITE
    EXPORT read_string
    EXPORT output_string
    EXPORT uart_init
    EXPORT pin_connect_block_setup_for_uart0
    EXPORT read_character
    EXPORT output_character
    EXPORT display_digit_on_7_seg
    EXPORT display_digit_on_7_seg_setup
    EXPORT read_from_push_btns
    EXPORT read_from_push_btns_setup
    EXPORT illuminateLEDs
    EXPORT illuminateLEDs_setup
    EXPORT Illuminate_RGB_LED
    EXPORT Illuminate_RGB_LED_setup
    EXPORT newline
    EXPORT str_len
    EXPORT atoi

U0BA  EQU 0xE000C000            ; UART0 Base Address
U0LSR EQU 0x14                  ; UART0 Line Status Register
U0LCR EQU 0x0C                  ; UART0 Line Control Register
PINSEL0 EQU 0xE002C000          ; Pin Connect Block Port 0
PINSEL1 EQU 0xE002C004
IO0DIR  EQU 0xE0028008          ; GPIO Direction Registers
IO1DIR  EQU 0xE0028018
IO0SET  EQU 0xE0028004          ; GPIO Output Set Registers
IO1SET  EQU 0xE0028014
IO0CLR  EQU 0xE002800C          ; GPIO Output Clear Registers
IO1CLR  EQU 0xE002801C
IO0PIN  EQU 0xE0028000          ; GPIO Port Pin Value Registers
IO1PIN  EQU 0xE0028010

digits_SET  
        DCD 0x00001F80  ; 0
        DCD 0x00000300  ; 1 
        DCD 0x00002D80  ; 2
        DCD 0x00002780  ; 3
        DCD 0x00003300  ; 4
        DCD 0x00003680  ; 5
        DCD 0x00003E80  ; 6
        DCD 0x00000380  ; 7
        DCD 0x00003F80  ; 8
        DCD 0x00003780  ; 9
        DCD 0x00003B80  ; A
        DCD 0x00003F80  ; B
        DCD 0x00001C80  ; C
        DCD 0x00001F80  ; D
        DCD 0x00003C80  ; E
        DCD 0x00003880  ; F
    ALIGN

RGB_SET
        DCD 0x00020000  ; 0. red
        DCD 0x00200000  ; 1. green
        DCD 0x00040000  ; 2. blue
        DCD 0x00060000  ; 3. purple
        DCD 0x00220000  ; 4. yellow
        DCD 0x00260000  ; 5. white
    ALIGN

LED_SET
        DCD 0x00000000  ; 0
        DCD 0x00080000  ; 1
        DCD 0x00040000  ; 2
        DCD 0x000C0000  ; 3
        DCD 0x00020000  ; 4
        DCD 0x000A0000  ; 5
        DCD 0x00060000  ; 6
        DCD 0x000E0000  ; 7
        DCD 0x00010000  ; 8
        DCD 0x00090000  ; 9
        DCD 0x00050000  ; 10
        DCD 0x000D0000  ; 11
        DCD 0x00030000  ; 12
        DCD 0x000B0000  ; 13
        DCD 0x00070000  ; 14
        DCD 0x000F0000  ; 15
    ALIGN   

; ***************************
; Initialize UART0
; ARGS  : none
; RETURN: none 
; ***************************
uart_init
    STMFD   SP!, {lr}
    ; 8-bit word length, 1 stop bit, no parity
    ; Disable break control
    ; Enable divisor latch access
    MOV     r1, #131             
    LDR     r4, =0xE000C00C
    STR     r1, [r4]
    ; Set lower divisor latch for 9,600 baud
    MOV     r1, #120
    LDR     r4, =0xE000C000
    STR     r1, [r4]
    ; Set upper divisor latch for 9,600 baud
    MOV     r1, #0
    LDR     r4, =0xE000C004
    STR     r1, [r4]
    ; 8-bit word length, 1 stop bit, no parity
    ; Disable break control
    ; Disable divisor latch access
    MOV     r1, #3
    LDR     r4, =0xE000C00C
    STR     r1, [r4]
    LDMFD   SP!, {lr}
    BX      lr

; ***************************
; Read char from UART0
; ARGS  : none
; RETURN: r0 = read char
; ***************************
read_character
    STMFD   SP!,{r1-r3,lr}      ; Store register lr on stack
    LDR     r0, =0xE000C000     ; Load UART0 Base Address
rstart
    LDRB    r1, [r0, #U0LSR]    ; Load Status Register Addresss
    ANDS    r2, r1, #1          ; Test RDR in Status Register
    BEQ     rstart              ; if RDR == 0 -> rstart
    LDRB    r3, [r0]            ; else Read byte from receive register
    MOV     r0, r3              ; Return char in r0
    LDMFD   sp!, {r1-r3,lr}           
    BX      lr

; ***************************
; Output char to UART0
; ARGS  : r0 = char to output
; RETURN: none
; ***************************
output_character
    STMFD   SP!,{lr, r1-r3}     ; Store register lr on stack
    
    MOV     r3, r0              ; Store char argument into r3
    LDR     r0, =0xE000C000     ; Load UART0 Base Address
tstart
    LDRB    r1, [r0, #U0LSR]    ; Load Status Register Addresss
    ANDS    r2, r1, #32         ; test THRE in Status Register
    BEQ     tstart              ; if THRE == 0 -> tstart
    STRB    r3, [r0]            ; else Store byte in transmit register
    MOV     r0, r3
    LDMFD   sp!, {lr, r1-r3}
    BX      lr
 

; ***************************
; Read and display NULL terminated string from UART0
; ARGS  : r4 = base address to store read string
; RETURN: none
; ***************************
read_string
    STMFD SP!, {lr, r0, r4, r5}     ; Store register lr on stack
rs_loop
    BL      read_character
    STRB    r0, [r4], #1        ; store char into [r4], increment index
    BL      output_character
    CMP     r0, #0x0D           ; check if char CR
    BNE     rs_loop             ; loop if char != CR
    MOV     r5, #0          
    STRB    r5, [r4, #-1]!      ; decrement buff index, then append NULL char
    
    MOV     r0, #0x0A           ; print new line
    BL      output_character     
    LDMFD   sp!, {lr, r0, r4, r5}
    BX      lr

; ***************************
; Output NULL terminated string to UART0
; ARGS  : r4 = base address of string to output
; RETURN: none
; ***************************
output_string
    STMFD   SP!, {lr, r0, r1, r4}
os_loop
    LDRB    r0, [r4], #1        ; char loaded into r0, r4 post-indexed base updated 
    LDR     r1, =U0BA           ; set r1 to UART0 Base Address
    BL      output_character    ; output char in r0 
    CMP     r0, #0              ; check if char is 0
    BNE     os_loop             ; loop if char != 0
    LDMFD   sp!, {lr, r0, r1, r4}
    BX      lr

; ***************************
; Convert a single hexadecimal char to int
; ARGS  : r0 = hex char to convert
; RETURN: r0 = converted int, 16 on error
; ***************************
hex_to_int
    STMFD   SP!, {lr, r3, r4}
    MOV     r3, #0              
    MOV     r4, #0
    ; check if input == [0-9]
    SUBS    r3, r0, #48         
    RSBS    r4, r0, #57         
    CMP     r3, #0              ; if r0 >= '0'
    CMPPL   r4, #0              ; AND r <= '9'
    BPL     htoi_num
    ; check if input == [A-F]
    SUBS    r3, r0, #65
    RSBS    r4, r0, #70
    CMP     r3, #0              ; if r0 >= 'A'
    CMPPL   r4, #0              ; and r0 <= 'F'
    BPL     htoi_alpha  
    ; if error
    MOV     r0, #16             ; set return error, r0 = 16
    B       htoi_end
htoi_num    
    SUB   r0, r0, #48           ; if r0 == [0-9]
    B     htoi_end
htoi_alpha
    SUB     r0, r0, #55         ; else r0 == [A-F]
htoi_end
    LDMFD   SP!, {lr, r3, r4}
    BX      lr


; ***************************
; Display hexadcimal on the seven-segment display
; ARGS  : r0 = char to display
; RETURN: r0 = 1 on error
; ***************************
display_digit_on_7_seg        
    STMFD   SP!, {lr, r1-r3}
    BL      hex_to_int          ; convert hex char to int
    CMP     r0, #16             ; check for invalid input
    MOVEQ   r0, #1              ; set error return
    BEQ     seven_seg_end 
    LDR     r1, =IO0CLR         ; load IO0CLR Base Address
    LDR     r2, =0x00003F80     ; mask for p0.7-p0.13
    STR     r2, [r1];           ; clear display
    LDR     r1, =0xE0028C04     ; load IO0SET Base Address
    LDR     r3,= digits_SET
    MOV     r0, r0, LSL #2      ; increment * 4
    LDR     r2, [r3, r0]        ; Load pattern for digit
    STR     r2, [r1]            ; store in IO0SET to display
seven_seg_end
    LDMFD   SP!, {lr, r1-r3}
    BX lr

display_digit_on_7_seg_setup
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =PINSEL0        ; load Pin Connect Block
    LDR     r2, =0x0FFFC000     ; mask for p0.07 - p0.13
    LDR     r3, [r1]
    BIC     r3, r3, r2          ; Clear bits
    STR     r3, [r1]            ; Set p0.7 - p0.13 as GPIO
    LDR     r1, =IO0DIR         ; load IO0DIR Base Address 
    LDR     r2, =0x00003F80     
    LDR     r3, [r1]
    ORR     r3, r3, r2
    STR     r3, [r1];           ; Set pins p0.7 - p0.13 as output 
    LDMFD   SP!, {lr, r1-r3}
    BX      lr


; ***************************
; Reads the momentary push buttons
; ARGS  : none
; RETURN: r0 = value read as char / '0' if no btn_pressed
; ***************************
read_from_push_btns
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =IO1PIN         ; load IO1PIN Base Address
    LDR     r2, [r1]            ; load IO1PIN value 
    
    MOV     r0, #0
    LDR     r3, =0x00100000     ; btn_1 mask = 0x00100000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #49             ; set return value to '1'
    BEQ     btns_end            ; branch to end

    LDR     r3, =0x00200000     ; btn_2 mask = 0x00200000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #50             ; set return value to '2'
    BEQ     btns_end            ; branch to end

    LDR     r3, =0x00400000     ; btn_3 mask = 0x00400000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #51             ; set return value to '3'
    BEQ     btns_end            ; branch to end

    LDR     r3, =0x00800000     ; btn_4 mask = 0x00800000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #52             ; set return value to '4'
    BEQ     btns_end            ; branch to end

    MOV     r0, #48             ; return '0' if no btn pressed
btns_end     
    LDMFD   SP!, {lr, r1-r3}
    BX lr

read_from_push_btns_setup
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =IO1DIR         ; load IO1DIR
    LDR     r2, =0x000F0000     ; mask for p1.20 - p1.23
    LDR     r3, [r1];
    BIC     r3, r3, r2          ; set to 0 for input
    STR     r3, [r1]            ; set p1.20 -p1.23 as input
    LDMFD   SP!, {lr, r1-r3}
    BX      lr


; ***************************
; Illuminates a selected set of LEDs
; ARGS  : r0 = pattern indicating which LEDs to illuminate
; RETURN: none
; ***************************
illuminateLEDs
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =IO1CLR         ; load IO1CLR Base Address
    LDR     r2, =0x000F0000     ; mask for p1.16-p1.19
    STR     r2, [r1]            ; clear LEDs
    LDR     r1, =IO1SET         ; load IO1SET Base Address
    MOV     r0, r0, LSL #2      ; increment * 4
    LDR     r3, =LED_SET        
    LDR     r2, [r3, r0]        ; load pattern for LED
    LDR     r3, [r1]            
    ORR     r3, r3, r2          ; ORR with IO1SET value with mask to set
    STR     r3, [r1]            ; store in IO1SET to display
    LDMFD   SP!, {lr, r1-r3}
    BX      lr
illuminateLEDs_setup
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =IO1DIR         ; load IO1DIR
    LDR     r2, =0x000F0000     ; mask for p1.16-p1.19
    LDR     r3, [r1]
    ORR     r3, r3, r2
    STR     r3, [r1]            ; set p1.16-p1.19 as output
    LDMFD   SP!, {lr, r1-r3}
    BX      lr

; ***************************
; Ilumiantes the RGB LED
; ARGS: r0 = color to display
;            0. red
;            1. green
;            2. blue
;            3. purple
;            4. yellow
;            5. white
;            6. quit
; RETURN: none
; ***************************
Illuminate_RGB_LED
    STMFD   SP!, {lr, r0-r3}
    BL      hex_to_int          ; convert hex char to int
    LDR     r1, =IO0CLR         ; load IO0CLR Base Address
    LDR     r2, =0x00260000     ;  
    STR     r2, [r1];           ; clear RGB_LED
    LDR     r1, =0xE0028C04     ; load IO0SET Base Address
    LDR     r3,= RGB_SET
    MOV     r0, r0, LSL #2      ; increment * 4
    LDR     r2, [r3, r0]        ; Load pattern for digit
    STR     r2, [r1]            ; store in IO0SET to display  
    LDMFD   SP!, {lr, r0-r3}
    BX lr

Illuminate_RGB_LED_setup
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =IO0DIR         ; load IO0DIR Base Address
    LDR     r2, =0x00260000     ; mask for p0.17, p0.18, p0.21
    LDR     r3, [r1]
    ORR     r3, r3, r2
    STR     r3, [r1]            ; set p0.17,18,21 as output
    LDMFD   SP!, {lr, r1-r3}
    BX      lr

; ***************************
; Print new line using LF, CR
; ARGS  : none
; RETURN: none
; ***************************
newline
    STMFD   SP!, {lr, r0}
    MOV     r0, #0x0A           ; print LF
    BL      output_character
    MOV     r0, #13             ; print CR
    BL      output_character
    LDMFD   SP!, {lr, r0}
    BX      lr

; ***************************
; Returns length of string
; ARGS  : r4 = base address of string to assess
; RETURN: r0 = length of string (does not include NULL terminator)
; ***************************
str_len
    STMFD   SP!, {lr, r1, r2, r4}
    MOV     r1, #0              ; initialize r1 as counter
str_len_loop    
    LDRB    r2, [r4], #1        ; load byte
    CMP     r2, #0              ; check to see if r2 == NULL terminator
    ADDNE   r1, #1              ; if r2 != NULL, increment counter
    BNE     str_len_loop        ; and branch to loop
    MOV     r0, r1
    LDMFD   SP!, {lr, r1, r2, r4}
    BX      lr

; ***************************
; Converts a signed number string to an int value
; ARGS  : r4 = base address of string to assess
; RETURN: r0 = converted int
; ***************************
atoi
    STMFD   SP!, {lr, r2-r4}
    MOV     r2, #0              ; initialize running total
    MOV     r3, #10             ; initialize multiplier
    ; Check sign
    MOV     r5, #0              ; initialize r5 to store sign flag
    LDRB    r0, [r4]            ; Load first char byte
    CMP     r0, #0x2D
    MOVEQ   r5, #1              ; Set r5 = 1 if negative, 0 if positive
    ADDEQ   r4, #1              ; increment place in address by 1
atoi_loop
    LDRB    r0, [r4], #1        ; Load next char byte
    CMP     r0, #0              ; if r0 == NULL terminator then
    BEQ     atoi_end            ; branch to end of subroutine
    SUB     r0, r0, #48         ; Conver to int
    MLA     r2, r3, r2, r0      ; r2 = (r3 * r2) + r0
    B       atoi_loop
atoi_end
    CMP     r5, #1              ; Convert to two's comp if negative
    MVNEQ   r2, r2              ; Take complement of r2
    ADDEQ   r2, r2, #1          ; then add 1
    MOV     r0, r2              ; Return in r0
    LDMFD   SP!, {lr, r2-r4}
    BX      lr


pin_connect_block_setup_for_uart0
    STMFD SP!, {lr, r0, r1}
    LDR r0, =PINSEL0            ; PINSEL0
    LDR r1, [r0]
    ORR r1, r1, #5
    BIC r1, r1, #0xA
    STR r1, [r0]
    LDMFD SP!, {lr, r0, r1}
    BX lr

    END    