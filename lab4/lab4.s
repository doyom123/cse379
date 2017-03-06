	AREA	GPIO, CODE, READWRITE	
	EXPORT lab4
	EXPORT digits_SET
	EXPORT RGB_SET
	EXTERN read_string
	EXTERN read_character
	EXTERN output_character
	EXTERN output_string
	EXTERN pin_connect_block_setup_for_uart0
	EXTERN display_digit_on_7_seg
	EXTERN display_digit_on_7_seg_setup

PIODATA EQU 0x8 ; Offset to parallel I/O data register
	
prompt	= "Welcome to lab #4  ",0   	; Text to be sent to PuTTy
	ALIGN
digits_SET	
		DCD 0x00001F80  ; 0
 		DCD 0x00000300  ; 1 
		DCD 0x00002D80	; 2
		DCD 0x00002780	; 3
		DCD 0x00003300	; 4
		DCD 0x00003680	; 5
		DCD 0x00003E80	; 6
		DCD 0x00000380	; 7
		DCD 0x00003F80	; 8
		DCD 0x00003780	; 9
		DCD 0x00003B80	; A
		DCD 0x00003F80	; B
		DCD 0x00001C80	; C
		DCD 0x00001F80	; D
		DCD 0x00003C80	; E
		DCD 0x00003880  ; F
	ALIGN

RGB_SET
		DCD 0x00020000	; 0. red
		DCD 0x00020000 	; 1. green
		DCD 0x00040000 	; 2. blue
		DCD 0x00060000	; 3. purple
		DCD 0x00220000 	; 4. yellow
		DCD 0x00260000 	; 5. white
	ALIGN


lab4
	STMFD SP!,{lr}	; Store register lr on stack
	
		; Your code goes here
	LDR r4, =prompt
	BL	output_string

	BL read_character
	BL output_character

	BL display_digit_on_7_seg_setup
	BL display_digit_on_7_seg
	
	LDMFD SP!, {lr}	; Restore register lr from stack	
	BX LR
	
	END