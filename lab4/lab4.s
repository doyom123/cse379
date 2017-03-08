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
    EXTERN strlen
    EXTERN atoi


PIODATA EQU 0x8 ; Offset to parallel I/O data register
    
str_welcome = "Enter a number to select\n", 0       ; Text to be sent to PuTTy
str_main = "1. LEDs\n2. Push Buttons\n3. 7-Segment Display\n4. RGB LED\n5. Quit\n", 0
str_prompt = ">> ",0
str_error = "ERROR: Invalid input\n", 0
str_quit = "Bye\n", 0
str_LEDs_instr = "Enter a number [0-15] to display a binary value, 16 to return to the main menu.\n", 0
str_push_btns_instr = "Push a button to display its output. Press any key to return to the main menu.\n", 0
str_push_btns_output = "Button Pressed: ", 0
str_hex_display_instr = "Enter a hexadecimal digit to appear on the 7-segment display\n", 0
str_RGB_instr = "Select a color to illuminate the RGB LED.\n", 0
str_RGB_options = "1. red\n2. green\n3. blue\n4. purple\n5. yellow\n6.white\n7. Quit\n"

str_user = "user entered text goes here", 0
    ALIGN

lab4
    STMFD   SP!,{lr}    ; Store register lr on stack
lab4_main   
    LDR     r4, =str_welcome    ; print options
    BL      output_string
    LDR     r4, =str_main
    BL      output_string
lab4_main_prompt
    LDR     r4, =str_prompt     ; print prompt
    BL      output_string
    BL      read_character      ; read input
    BL      output_character
    BL      newline
    ; Validate input    
    LDR     r4, =str_error      ; load error msg
    CMP     r0, #49             ; if input is < '1'
    BLMI    output_string       ; print error msg
    BMI     lab4_main_prompt    ; loop to prompt
    CMP     r0, #53             ; if input is > '5'
    BLPL    output_string       ; print error msg
    BPL     lab4_main_prompt    ; loop to prompt

    CMP     r0, #49             ; if input == '1'/LEDs
    BEQ     lab4_LEDs           ; branch to LEDs
    CMP     r0, #50             ; if input == '2'/Push Btns
    BEQ     lab4_push_btns      ; branch to Push Btns
    CMP     r0, #51             ; if input == '3'/7-Seg Display
    BEQ     lab4_hex_display    ; branch to 7-Seg Hex Display
    CMP     r0, #52             ; if input == '4'/RGB LED
    BEQ     lab4_RGB            ; branch to RGB LED
    CMP     r0, #53             ; if input == '5'/Quit
    BEQ     lab4_quit           ; branch to quit
    
lab4_LEDs
    BL      illuminateLEDs_setup 
    LDR     r4, =str_LEDs_instr
    BL      output_string
lab4_LEDs_prompt    
    LDR     r4, =str_prompt     ; load prompt
    BL      output_string       ; print prompt
    LDR     r4, =str_user       ; load user
    BL      read_string         ; read and store input
    BL      atoi                ; convert input to an int
    ; Validate input
    CMP     r0, #16             ; if r0 == 16
    B       lab4_LEDs_quit      ; branch to quit
    LDR     r4, =str_error      ; load error msg
    CMP     r0, #0              ; if r0 < 0
    BLMI    output_string       ; then print error msg
    BMI     lab4_LEDs_prompt    ; and branch to LEDs_prompt
    CMP     r0, #16             ; if r0 > 15
    BLPL    output_string       ; then print error msg
    BPL     lab4_LEDs_prompt    ; and branch to LEDs_prompt

    BL      illuminateLEDs      ; illuminate LEDs
    B       lab4_LEDs_prompt    ; return to prompt
lab4_LEDs_quit
    BL      newline
    B       lab4_main

lab4_push_btns
    MOV     r0, #0
    BL      read_from_push_btns_setup
    LDR     r4, =str_push_btns_instr
    BL      output_string
    LDR     r4, =str_push_btns_output
lab4_push_btns_loop
    BL      read_character
    CMP     r0, #0              ; if user pressed keyboard
    BNE     lab4_main           ; return to main
    BL      read_from_push_btns
    CMP     r0, #48             ; if a button is pressed
    BLNE    output_string       ; then print the output string
    BLNE    output_character    ; and print the button number that was pressed
    BLNE    newline

lab4_hex_display
    LDR     r4, =str_hex_display_instr
    BL      output_string

    BL      display_digit_on_7_seg_setup
    BL      display_digit_on_7_seg

lab4_RGB
    LDR     r4, =str_RGB_instr
    BL      output_string
    LDR     r4, =str_RGB_options
    BL      output_string
    LDR     r4, =str_prompt
    BL      output_string
lab4_quit   
    LDR     r4, =str_quit
    BL      output_string
    LDMFD   SP!, {lr}
    BX      lr


test
    STMFD   SP!, {lr}



    LDMFD   SP!, {lr}
    BX      lr

    END