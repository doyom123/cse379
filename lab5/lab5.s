	AREA interrupts, CODE, READWRITE
	EXPORT lab5
	EXPORT FIQ_Handler
	EXTERN output_string
	EXTERN read_character
	EXTERN display_digit_on_7_seg
	EXTERN display_digit_on_7_seg_setup
	EXTERN pin_connect_block_setup_for_uart0

prompt = "Welcome to lab #5",0
str_instr = "Enter input:\r\n0: Clear display\r\n+: Increment display\r\n-Decrement display\r\nQ: End program\r\n", 0
	
    ALIGN

lab5	 	
	STMFD sp!, {lr}

	; Your lab 5 code goes here...
	
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

		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0xC]
		ORR r1, r1, #0x8000 ; External Interrupt 1
		STR r1, [r0, #0xC]

		; Enable Interrupts
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] 
		ORR r1, r1, #0x8000 ; External Interrupt 1
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



FIQ_Handler
		STMFD SP!, {r0-r12, lr}   ; Save registers 

EINT1			; Check for EINT1 interrupt
		LDR r0, =0xE01FC140 ; EXTINT External Interrupt Flag Register
		LDR r1, [r0]
		TST r1, #2
		BEQ FIQ_Exit
	
		STMFD SP!, {r0-r12, lr}   ; Save registers 
			
		; Push button EINT1 Handling Code
		
		; My code
		
		ldr r0, =prompt
		ldr r1, =0x01234567
		str r1, [r0]
		


		; End My code

		LDMFD SP!, {r0-r12, lr}   ; Restore registers
		
		ORR r1, r1, #2		; Clear Interrupt
		STR r1, [r0]
	
FIQ_Exit
		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4

	END