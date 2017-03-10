    AREA    GPIO, CODE, READWRITE   
    EXPORT lab4
    EXPORT test
    EXTERN read_string
    EXTERN read_character
    EXTERN output_character
    EXTERN output_string
    EXTERN pin_connect_block_setup_for_uart0
    EXTERN display_digit_on_7_seg
    EXTERN display_digit_on_7_seg_setup
    EXTERN read_from_push_btns
    EXTERN read_from_push_btns_setup
    EXTERN illuminateLEDs
    EXTERN illuminateLEDs_setup
    EXTERN Illuminate_RGB_LED
    EXTERN Illuminate_RGB_LED_setup
    EXTERN newline
    EXTERN str_len
    EXTERN atoi


PIODATA EQU 0x8 ; Offset to parallel I/O data register
    
str_welcome = "Enter a number to select\r\n", 0       ; Text to be sent to PuTTy
str_main = "1. LEDs\r\n2. Push Buttons\r\n3. 7-Segment Display\r\n4. RGB LED\r\n5. Quit\r\n", 0
str_prompt = ">> ",0
str_error = "ERROR: Invalid input\r\n", 0
str_quit = "Bye\r\n", 0
str_LEDs_instr = "Enter a number [0-15] to display a binary value, 16 to return to main menu.\r\n", 0
str_push_btns_instr = "Push a button to display its output. Press any key to return to the main menu.\r\n", 0
str_push_btns_output = "Button Pressed: ", 0
str_hex_display_instr = "Enter a hexadecimal digit to appear on the 7-segment display\r\n16 to return to main menu.\r\n", 0
str_RGB_instr = "Select a color to illuminate the RGB LED.\r\n", 0
str_RGB_options = "0. red\r\n1. green\r\n2. blue\r\n3. purple\r\n4. yellow\r\n5.white\r\n6. Quit\r\n", 0

str_user = "user entered text goes here", 0
    ALIGN

lab4
    STMFD   SP!,{lr}
lab4_main   
    LDR     r4, =str_welcome        ; print options
    BL      output_string
    LDR     r4, =str_main
    BL      output_string
lab4_main_prompt
    LDR     r4, =str_prompt         ; print prompt
    BL      output_string
    LDR     r4, =str_user
    BL      read_string             ; read input
    BL      atoi                    ; convert iput to an int
    ; Assess input    
    CMP     r0, #1                  ; if input == '1'/LEDs
    BEQ     lab4_LEDs               ; branch to LEDs
    CMP     r0, #2                  ; if input == '2'/Push Btns
    BEQ     lab4_push_btns          ; branch to Push Btns
    CMP     r0, #3                  ; if input == '3'/7-Seg Display
    BEQ     lab4_hex_display        ; branch to 7-Seg Hex Display
    CMP     r0, #4                  ; if input == '4'/RGB LED
    BEQ     lab4_RGB                ; branch to RGB LED
    CMP     r0, #5                  ; if input == '5'/Quit
    BEQ     lab4_quit               ; branch to quit

    LDR     r4, =str_error          ; load error msg
    BL      output_string           ; print error msg
    B       lab4_main_prompt
    
lab4_LEDs
    BL      newline
    BL      illuminateLEDs_setup 
    LDR     r4, =str_LEDs_instr
    BL      output_string
lab4_LEDs_prompt    
    LDR     r4, =str_prompt         ; load prompt
    BL      output_string           ; print prompt
    LDR     r4, =str_user           ; load user
    BL      read_string             ; read and store input
    BL      atoi                    ; convert input to an int
    ; Validate input
    CMP     r0, #16                 ; if r0 == 16
    BEQ     lab4_LEDs_quit          ; branch to quit
    LDR     r4, =str_error          ; load error msg
    CMP     r0, #0                  ; if r0 < 0
    BLMI    output_string           ; then print error msg
    BMI     lab4_LEDs_prompt        ; and branch to LEDs_prompt
    CMP     r0, #16                 ; if r0 > 15
    BLPL    output_string           ; then print error msg
    BPL     lab4_LEDs_prompt        ; and branch to LEDs_prompt

    BL      illuminateLEDs          ; illuminate LEDs
    B       lab4_LEDs_prompt        ; return to prompt
lab4_LEDs_quit
    BL      newline
    B       lab4_main

lab4_push_btns
    BL      newline
    BL      read_from_push_btns_setup
    LDR     r4, =str_push_btns_instr
    BL      output_string
    LDR     r4, =str_push_btns_output
lab4_push_btns_loop
    BL      read_character
    CMP     r0, #0                  ; if user pressed keyboard
    BLNE    newline
    BNE     lab4_main               ; return to main
    BL      read_from_push_btns
    CMP     r0, #48                 ; if return value != 0, a button is pressed
    BLNE    output_string           ; then print the output string
    BLNE    output_character        ; and print the button number that was pressed
    BLNE    newline
    B       lab4_push_btns_loop

lab4_hex_display
    BL      display_digit_on_7_seg_setup
    BL      newline
    LDR     r4, =str_hex_display_instr
    BL      output_string
lab4_hex_display_loop    
    LDR     r4, =str_prompt
    BL      output_string
    LDR     r4, =str_user
    BL      read_string
    ; Validate input
    BL      str_len
    CMP     r0, #2                  ; if str_len > 1
    LDRPL   r4, =str_error          ; then load error msg
    BLPL    output_string           ; and print error msg
    BPL     lab4_hex_display_loop   ; and branch to loop

    LDRB    r0, [r4]                ; load inputted hexadecimal char [0-9, A-F]
    BL      display_digit_on_7_seg
    CMP     r0, #1                  ; check if returned error, r0 == 1
    LDREQ   r4, =str_error          ; then load error msg
    BLEQ    output_string           ; and print error msg
    B       lab4_hex_display_loop   ; branch to loop



lab4_RGB
    BL      Illuminate_RGB_LED_setup
    LDR     r4, =str_RGB_instr
    BL      output_string
    LDR     r4, =str_RGB_options
    BL      output_string
lab4_RGB_loop    
    LDR     r4, =str_prompt
    BL      output_string
    LDR     r4, =str_user
    BL      read_string

    ; Validate input
    BL      str_len
    CMP     r0, #2                  ; if str_len > 1
    LDRPL   r4, =str_error          ; then load error msg
    BLPL    output_string           ; and print error msg
    BPL     lab4_RGB_loop           ; and branch to loop

    LDR     r4, =str_user
    BL      atoi                    ; convert input to int
    LDR     r4, =str_error
    CMP     r0, #7                  ; if r0 == 7
    BEQ     lab4_main               ; then branch to main

    BLGT    output_string           ; if r0 > 7, print error message
    BGT     lab4_RGB_loop           ; and branch to loop

    CMP     r0, #0                  ; if r0 < 0
    BLPL    output_string           ; then print error msg
    BPL     lab4_RGB_loop           ; and bracnch to loop

    BL      Illuminate_RGB_LED
    B       lab4_RGB_loop           ; return to loop



lab4_quit   
    LDR     r4, =str_quit
    BL      output_string
    LDMFD   SP!, {lr}
    BX      lr


test
    STMFD   SP!, {lr}

    ; LEDs test
    ;BL      illuminateLEDs_setup
    ;LDR     r4, =str_LEDs_instr
    ;BL      output_string
    ;LDR     r4, =str_prompt
    ;BL      output_string
    ;LDR     r4, =str_user
    ;BL      read_string
    ;BL      atoi
    ;BL      illuminateLEDs
    ;B       test

    ; Hex test
    ;BL      display_digit_on_7_seg_setup
    ;LDR     r4, =str_hex_display_instr
    ;BL      output_string
    ;LDR     r4, =str_prompt
    ;BL      output_string
    ;LDR     r4, =str_user
    ;BL      read_string
    ;MOV     r0, #0
    ;LDRB    r0, [r4]
    ;BL      display_digit_on_7_seg
    ;B       test

    ; RGB test
    ;BL      Illuminate_RGB_LED_setup
    ;LDR     r4, =str_RGB_instr
    ;BL      output_string
    ;LDR     r4, =str_RGB_options
    ;BL      output_string
;loop
    ;LDR     r4, =str_prompt
    ;BL      output_string
    ;LDR     r4, =str_user
    ;BL      read_string
    ;BL      atoi
    ;BL      Illuminate_RGB_LED
    ;B       loop

    ; Push Buttons test
    ;BL      read_from_push_btns_setup
;loop
    ;LDR     r4, =str_user
    ;BL      read_from_push_btns
    ;LDR     r0, [r4]
    ;CMP     r0, #48
    ;BLNE    output_string
    ;BLNE    newline
    ;B       loop


    LDMFD   SP!, {lr}
    BX      lr

    END