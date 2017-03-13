	AREA interrupts, CODE, READWRITE
	EXPORT lab5
	EXPORT FIQ_Handler
	EXTERN output_string
	EXTERN read_character
	EXTERN output_character
	EXTERN display_digit_on_7_seg
	EXTERN display_digit_on_7_seg_setup
	EXTERN display_digit_on_7_seg_clear
	EXTERN pin_connect_block_setup_for_uart0
	EXTERN newline

prompt = "Welcome to lab #5",0
str_instr = "Enter input:\r\n0: Clear display\r\n+: Increment display\r\n-: Decrement display\r\nQ: End program\r\n", 0
str_status = "0", 0	
    ALIGN

status DCD 0x00000000
pattern DCD 0x30
	ALIGN
	
lab5	 	
	STMFD sp!, {lr}

	MOV r6, #0 	; status of display / 0 = off, 1 = on
	MOV r7, #0x30	; current hex pattern
	

	BL interrupt_init 	; initialize UART0 and button interrupts
	BL display_digit_on_7_seg_setup 	; initialize 7 seg display
	MOV r0, #0x30
	BL display_digit_on_7_seg 
	BL display_digit_on_7_seg_clear 	; clear display
lab5_loop
	
	B lab5_loop
lab5_exit
	LDMFD sp!,{lr}
	BX lr

interrupt_init      
	STMFD SP!, {r0-r1, lr}   ; Save registers 
		
	; Push button setup		 
	LDR r0, =0xE002C000
	LDR r1, [r0]
	ORR r1, r1, #0x20000000
	BIC r1, r1, #0x10000000
	STR r1, [r0]  ; PINSEL0 bits 29:28 = 10
		
	; UART0 setup
	LDR r0, =0xE000C004  ; U0IER
	LDR r1, [r0]
	ORR r1, r1, #1 	; Enable Receive Data Available Interrupt(RDA) Bit 0
	STR r1, [r0]

	; Classify sources as IRQ or FIQ
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0xC]
	ORR r1, r1, #0x8000 ; External Interrupt 1
	ORR r1, r1, #0x40 	; UART0 Interrupt
	STR r1, [r0, #0xC]

	; Enable Interrupts
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0x10] 
	ORR r1, r1, #0x8000 ; External Interrupt 1
	;ORR r1, r1, #0x40	; UART0 Interrupt
	STR r1, [r0, #0x10]

	; External Interrupt 1 setup for edge sensitive
	LDR r0, =0xE01FC148
	LDR r1, [r0]
	ORR r1, r1, #2  ; EINT1 = Edge Sensitive
	STR r1, [r0]

	; Enable FIQ's, Disable IRQ's
	MRS r0, CPSR
	BIC r0, r0, #0x40
	ORR r0, r0, #0x80
	MSR CPSR_c, r0

	LDMFD SP!, {r0-r1, lr} ; Restore registers
	BX lr             	   ; Return

enable_uart0_interrupt
	STMFD SP!, {lr, r0-r1}
	LDR r0, =0xFFFFF010
	LDR r1, [r0]
	ORR r1, r1, #0x40
	STR r1, [r0]
	LDMFD SP!, {lr, r0-r1}
	BX 	lr

disable_uart0_interrupt
	STMFD SP!, {lr, r0-r1}
	LDR r0, =0xFFFFF010
	LDR	r1, [r0]
	BIC r1, #0x40
	STR r1, [r0]
	LDMFD SP!, {lr, r0-r1}
	BX 	lr


FIQ_Handler
	STMFD SP!, {r0-r12, lr}   ; Save registers 

UART0	; Check for UART0 interrupt
	LDR r0, =0xE000C008  ; UART0 Interrupt Identification Register(U0IIR)
	LDR r1, [r0]
	TST r1, #1	; Bit 0 / 0 = pending, 1 = no pending interrupts
	BNE EINT1
	
	STMFD SP!, {r0-r12, lr}
	
	LDR r0, =status
	LDR r1, [r0]
	CMP r1, #0				   
	BEQ UART0_end

	
	BL read_character
	MOV r2, r0
	BL output_character
	BL newline

	LDR r0, =pattern
	LDR r1, [r0]
	CMP r2, #0x2B  ; '+'
	ADDEQ r1, r1, #1
	BLEQ display_digit_on_7_seg 
	

	;LDR r4, =str_instr
	;BL 	output_string

UART0_end	
	LDMFD SP!, {r0-r12, lr}
	B FIQ_Exit

EINT1	; Check for EINT1 interrupt
	LDR r0, =0xE01FC140 ; EXTINT External Interrupt Flag Register
	LDR r1, [r0]
	TST r1, #2
	BEQ FIQ_Exit
	
	STMFD SP!, {r0-r12, lr}   ; Save registers 
	
	;LDR 	r4, =str_status  ; get status / 0 = off, 1 = on
	;LDRB 	r6, [r4]
	LDR 	r0, =status
	LDR 	r6, [r0]
	CMP 	r6, #0 ; if display off, turn on
	BNE 	display_off
	MOV 	r6, #1 ; set status to '1' / on
	STR		r6, [r0]
	
	LDR 	r0, =pattern
	LDR 	r7, [r0]
	MOV 	r0, r7
	BL	 	display_digit_on_7_seg	; turn on display
	;BL		enable_uart0_interrupt	; turn on UART0 interrupt
	LDR 	r4, =str_instr
	BL 		output_string	
	B	 	display_on
display_off	
	LDR 	r0, =status
	MOV 	r1, #0 	; set status to '0' / off
	STR 	r1, [r0]
	BL 	display_digit_on_7_seg_clear ; turn off display
	;BL	disable_uart0_interrupt ; turn off UART0 interrupt
			
	;ldr r0, =prompt
	;ldr r1, =0x01234567
	;str r1, [r0]
display_on	
	LDMFD SP!, {r0-r12, lr}   ; Restore registers
		
	ORR r1, r1, #2		; Clear Interrupt
	STR r1, [r0]
	
FIQ_Exit
	LDMFD SP!, {r0-r12, lr}
	SUBS pc, lr, #4

	END