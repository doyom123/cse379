	AREA	GPIO, CODE, READWRITE	
	EXPORT lab4
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

PIODATA EQU 0x8 ; Offset to parallel I/O data register
	
str_welcome	= "Welcome to lab #4\n", 0   	; Text to be sent to PuTTy
str_main = "1. LEDs\n2. Push Buttons\n3. 7-Segment Display\n4. RGB LED\n5. Quit\n", 0
str_prompt = "Enter choice: ",0
	ALIGN

lab4
	STMFD 	SP!,{lr}	; Store register lr on stack
	
	LDR 	r4, =str_welcome
	BL		output_string
	LDR 	r4, =str_main
	BL 		output_string
	LDR 	r4, =str_prompt
	BL 		output_string
	BL 		read_character
	BL 		output_character

	BL 		display_digit_on_7_seg_setup
	BL 		display_digit_on_7_seg
	
	LDMFD 	SP!, {lr}	; Restore register lr from stack	
	BX 		lr
	
	END