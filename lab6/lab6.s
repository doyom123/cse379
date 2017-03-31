; Do Om / doom
; Arunan Bala Krishnan / arunanba
	AREA interrupts, CODE, READWRITE
	EXPORT lab6
	EXPORT FIQ_Handler
	EXTERN output_string
	EXTERN read_character
	EXTERN output_character
	EXTERN display_digit_on_7_seg
	EXTERN display_digit_on_7_seg_setup
	EXTERN display_digit_on_7_seg_clear
	EXTERN pin_connect_block_setup_for_uart0
	EXTERN newline
	EXTERN DISPLAY_DIGIT
	EXPORT lab6_exit
	EXPORT pattern

str_user = "*@#X", 0

str_exit = "goodbye", 0							   
    ALIGN

status DCD 0x00000000
pattern DCD 0x30
	ALIGN

; TimerCounter (T0TC) = 0xE0004008
; TimerCounter (T1TC) = 0xE0008008

lab6	 	
	STMFD sp!, {lr} 	
    LDR r4, =str_user
    BL output_string
    BL timer0_init
	BL interrupt_init 	; initialize UART0 and button interrupts
	
lab6_loop
	
	B lab6_loop
lab6_exit
	
	LDR r4, =str_exit
	BL output_string
	LDMFD sp!,{lr}
	BX lr 

timer0_init
	STMFD SP!, {r4-r5, lr}
    ;LDR r4, =0xFFFFF00C 	; InterruptSelectRegister
	;LDR r5, [r4]
    ;ORR r5, r5, #8 			; set bit 4 to classify T0 as FIQ
							; set bit 5 to classify T1 as FIQ
	;STR r5, [r4]

    ;LDR r4, =0xFFFFF010 	; VIC Interrupt Enable register
    ;LDR r5, [r4]
	;ORR r5, r5, #8  	 	; bit 4 to enable Timer0Interrupt
							; bit 5 to enable Timer1Interrupt
	;STR r5, [r4]
        
    ;LDR r4, =0xE0004014 	; T0MCR - Timer0MatchControlRegister
	;LDR r5, [r4]
    ;ORR r5, r5, #0x18 		; Interrupt and Reset for MR1
    ;STR r5, [r4]

	; Enable Timer
	LDR r4, =0xE000401C 	; Match Register 0
	LDR r5, =0xDEADBEEF		; Set time to match time
	STR r5, [r4]

	LDMFD SP!, {r4-r5, lr}
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
    ORR r1, r1, #0x8    ; TIMER 0
	STR r1, [r0, #0xC]

	; Enable Interrupts
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0x10] 
	ORR r1, r1, #0x8000 ; External Interrupt 1
	ORR r1, r1, #0x40	; UART0 Interrupt
    ORR r1, r1, #0x8    ; TIMER 0
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
Timer0Int ; Check for Timer 0 Interrupt
	LDR r0, =0xE0004000  	; T0InterruptRegister
	LDR r1, [r1]
	TST r1, #2 	;  1 if pending interrupt due to Match Register 1
	BNE UART0

	LDR r4, =str_user
	BL output_string

	LDR r0, =0xE0004000 	; Clear interrupt for MR1
	LDR r1, [r0]			; by writing 1 to bit 2
	ORR r1, #2
	STR r1, [r0]
	BEQ FIQ_Exit

UART0	; Check for UART0 interrupt
	LDR r0, =0xE000C008  ; UART0 Interrupt Identification Register(U0IIR)
	LDR r1, [r0]
	TST r1, #1	; Bit 0 / 0 = pending, 1 = no pending interrupts
	BNE EINT1
	
	STMFD SP!, {r0-r12, lr}
	
	BL read_character
	
	LDMFD SP!, {r0-r12, lr}
	B FIQ_Exit

EINT1	; Check for EINT1 interrupt
	LDR r0, =0xE01FC140 ; EXTINT External Interrupt Flag Register
	LDR r1, [r0]
	TST r1, #2
	BEQ FIQ_Exit
																
	STMFD SP!, {r0-r12, lr}   ; Save registers 
	

	
	LDMFD SP!, {r0-r12, lr}   ; Restore registers
		
	ORR r1, r1, #2		; Clear Interrupt
	STR r1, [r0]
	
FIQ_Exit
	LDMFD SP!, {r0-r12, lr}
	SUBS pc, lr, #4

	END