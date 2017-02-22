	AREA	lib, CODE, READWRITE	
	EXPORT lab3
	EXPORT pin_connect_block_setup_for_uart0
	

U0LSR EQU 0x14			; UART0 Line Status Register

		; You'll want to define more constants to make your code easier 
		; to read and debug
	   
		; Memory allocated for user-entered strings

prompt = "Enter a number:  ",0          

		; Additional strings may be defined here

	ALIGN



lab3
	STMFD SP!,{lr}	; Store register lr on stack

	BL read_character
	BL output_character
	LDMFD sp!, {lr}
	BX lr

read_string				; base address of string passed into r4
	STMFD SP!, {lr} 	; Store register lr on stack
rs_loop
	BL 		read_character 	
	STRB 	r0, [r4], #1 		; store char into [r4], increment index
	CMP 	r0, #0x0A			; check if char LF
	BNE 	rs_loop				; loop if char != LF
	MOV 	r5, #0 			
	STRB	r5, [r4] 			; append NULL char
	
	LDMFD sp!, {lr}
	BX lr

output_string 			; base address of string passed into r4
	STMFD 	SP!, {lr}
os_loop
	LDRB	r0, [r4], #1		; char loaded into r0, r4 post-indexed base updated 
	BL 		output_character	; output char in r0 
	CMP 	r0, #0				; check if char is 0
	BNE		os_loop				; loop if char != 0
	
	LDMFD sp!, {lr}
	BX lr
	
	
read_character					; Read Data
	STMFD 	SP!,{lr}			; Store register lr on stack
	LDR 	r0, =0xE000C000		; Load UART0 Base Address
rstart
	LDRB 	r1, [r0, #U0LSR]	; Load Status Register Addresss
	;LDRB	r4, [r1]		; Load Status Register into r4
	ANDS	r2, r1, #1  	; Test RDR in Status Register
	BEQ		rstart 		 	; if RDR == 0 -> rstart
	LDRB	r3, [r0]  		; else Read byte from receive register
	MOV 	r0, r3			; Return char in r0
	LDMFD 	sp!, {lr}			
	BX 		lr

output_character    			; char passed in through r0
	STMFD 	SP!,{lr}  			; Store register lr on stack
	MOV		r3, r0				; Store char argument into r3
	LDR 	r0, =0xE000C000  	; Load UART0 Base Address
tstart
	LDRB 	r1, [r0, #U0LSR]	; Load Status Register Addresss
	;LDRB	r4, [r1]  		; Load Status Register into r4
	ANDS 	r2, r1, #32  	; test THRE in Status Register
	BEQ 	tstart  		; if THRE == 0 -> tstart
	STRB	r3, [r0]  		; else Store byte in transmit register
	LDMFD sp!, {lr}
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
