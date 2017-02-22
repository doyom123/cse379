	AREA	lib, CODE, READWRITE	
	EXPORT lab3
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT read_character
	EXPORT output_character
	
U0LSR EQU 0x14			; UART0 Line Status Register

lab3
	STMFD SP!,{lr}	; Store register lr on stack
    BL read_character;
	BL output_character;
	LDMFD sp!, {lr}
	BX lr

read_character		; Read Data
	STMFD SP!,{lr}	; Store register lr on stack
	
	LDR r0, =0xE000C000
	LDRB r1, [r0, #U0LSR]
rstart
	; Load Status Register into r4
	LDRB	r4, [r1]
	; Test RDR in Status Register
	ANDS	r2, r4, #1
	; if RDR == 0 -> rstart
	BEQ		rstart
	; else Read byte from receive register
	LDRBGT	r3, [r0]

	LDMFD sp!, {lr}
	BX lr

output_character    ; Transmit Data
	STMFD SP!,{lr}	; Store register lr on stack	

	LDR r0, =0xE000C000
	LDRB r1, [r0, #U0LSR]
tstart
	; Load Status Register into r4
	LDRB	r4, [r1]
	; test THRE in Status Register
	ANDS 	r2, r4, #32
	; if THRE == 0 -> tstart
	BEQ 	tstart
	; else Store byte in transmit register
	STRBGT	r3, [r0]
	
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
