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
U0BA  EQU 0xE000C000            ; UART0 Base Address
U0LSR EQU 0x14                  ; UART0 Line Status Register
U0LCR EQU 0x0C                  ; UART0 Line Control Register

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
        DCD 0x00020000  ; 1. green
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
    BL      output_character    ; 
    
    LDMFD sp!, {lr, r0, r4, r5}
    BX lr

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
    
    LDMFD sp!, {lr, r0, r1, r4}
    BX lr

; ***************************
; Convert hexadecimal char to int
; ARGS  : r0 = hex char to convert
; RETURN: r0 = converted int
; ***************************
hex_to_int
    STMFD   SP!, {lr}
    CMP     r0, #65
    SUBMI   r0, r0, #48         ; if r0 == [0-9]
    BMI     htoi_end
    SUB     r0, r0, #55         ; else r0 == [A-F]
htoi_end
    LDMFD   SP!, {lr}
    BX lr


; ***************************
; Display hexadcimal on the seven-segment display
; ARGS  : r0 = digit to display
; RETURN: none
; ***************************
display_digit_on_7_seg        
    STMFD   SP!, {lr, r0-r3}
    BL      hex_to_int          ; convert hex char to int
    LDR     r1, =0xE002800C     ; load IO0CLR Base Address
    LDR     r2, =0x00003F80     ; mask for p0.7-p0.13
    STR     r2, [r1];           ; clear display
    LDR     r1, =0xE0028C04     ; load IO0SET Base Address
    LDR     r3,= digits_SET
    MOV     r0, r0, LSL #2      ; increment * 4
    LDR     r2, [r3, r0]        ; Load pattern for digit
    STR     r2, [r1]            ; store in IO0SET to display  

    LDMFD   SP!, {lr, r0-r3}
    BX lr

display_digit_on_7_seg_setup
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =0xE002C000     ; load Pin Connect Block
    LDR     r2, =0x0FFFC000     ; mask for p0.07 - p0.13
    LDR     r3, [r1]
    BIC     r3, r3, r2          ; Clear bits
    STR     r3, [r1]            ; Set p0.7 - p0.13 as GPIO
    LDR     r1, =0xE0028008     ; load I0DIR Base Address 
    LDR     r2, =0x00003F80     
    STR     r2, [r1];           ; Set pins p0.7 - p0.13 as output 
    LDMFD   SP!, {lr, r1-r3}
    BX lr


; ***************************
; Reads the momentary push buttons
; ARGS  : none
; RETURN: r0 = value read / 0 if no btn_pressed
; ***************************
read_from_push_btns
    STMFD   SP!, {lr, r1-r3}
    LDR     r1, =0xE0028010     ; load IO1PIN Base Address
    LDR     r2, [r1]            ; load IO1PIN value 
    
    MOV     r0, #0
    LDR     r3, =0x00100000     ; btn_1 mask = 0x00100000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #1              ; set return value to 1
    BEQ     btns_end            ; branch to end

    LDR     r3, =0x00200000     ; btn_2 mask = 0x00200000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #2              ; set return value to 2
    BEQ     btns_end            ; branch to end    

    LDR     r3, =0x00400000     ; btn_3 mask = 0x00400000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #3              ; set return value to 3
    BEQ     btns_end            ; branch to end

    LDR     r3, =0x00800000     ; btn_4 mask = 0x00800000
    AND     r0, r2, r3
    CMP     r0, r3              ; if IO1PIN && mask
    MOVEQ   r0, #4              ; set return value to 4
    BEQ     btns_end            ; branch to end

    MOV     r0, #0              ; return 0 if no btn pressed
btns_end     
    LDMFD   SP!, {lr, r1-r3}
    BX lr

read_from_push_btns_setup
    STMFD   SP!, {lr}


    LDMFD   SP!, {lr}
    BX lr


; ***************************
; Illuminates a selected set of LEDs
; ARGS: r0 = pattern indicating which LEDs to illuminate
; RETURN: none
; ***************************
illuminateLEDs
    STMFD   SP!, {lr}


    LDMFD   SP!, {lr}
    BX lr
illuminateLEDs_setup
    STMFD   SP!, {lr}


    LDMFD   SP!, {lr}
    BX lr

; ***************************
; Illuminates the RGB LED
; ARGS: r0 = color to display
;            0. red
;            1. green
;            2. blue
;            3. purple
;            4. yellow
;            5. white
; RETURN: none
; ***************************
Illuminate_RGB_LED
    STMFD   SP!, {lr}

    BL      hex_to_int          ; convert hex char to int
    LDR     r1, =0xE0028018     ; load IO0CLR Base Address
    LDR     r2, =0x00260000     ;  
    STR     r2, [r1];           ; clear RGB_LED
    LDR     r1, =0xE0028C04     ; load IO0SET Base Address
    LDR     r3,= RGB_SET
    MOV     r0, r0, LSL #2      ; increment * 4
    LDR     r2, [r3, r0]        ; Load pattern for digit
    STR     r2, [r1]            ; store in IO0SET to display  

    LDMFD   SP!, {lr}
    BX lr

Illuminate_RGB_LED_setup
    STMFD   SP!, {lr}


    LDMFD   SP!, {lr}
    BX lr


pin_connect_block_setup_for_uart0
    STMFD sp!, {r0, r1, lr}
    LDR r0, =0xE002C000  ; PINSEL0
    LDR r1, [r0]
    ORR r1, r1, #5
    BIC r1, r1, #0xA
    STR r1, [r0]
    LDMFD sp!, {r0, r1, lr}
    BX lr

    END    