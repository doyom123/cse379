AREA lib, CODE, READWRITE
	EXPORT lab3
	EXPORT pin_connect_block_setup_for_uart0

	U0LSR EQU 0x14 ; UART0 Line Status Register
	; You'll want to define more constants to make your code easier
	; to read and debug

	; Memory allocated for user-entered strings
	prompt = "Enter a number: ",0
	; Additional strings may be defined here
	ALIGN

lab3
	STMFD SP!,{lr} ; Store register lr on stack

	; Your code is placed here

	LDMFD sp!, {lr}
	BX lr
 
pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000 ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr
	END