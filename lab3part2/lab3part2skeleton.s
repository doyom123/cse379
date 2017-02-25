	AREA	lib, CODE, READWRITE	
	EXPORT lab3
	EXPORT pin_connect_block_setup_for_uart0
	

U0LSR EQU 0x14			; UART0 Line Status Register
U0LCR EQU 0x0C 			; UART0 Line Control Register
U0BA EQU 0xE000C000		; UART0 Base Address
		; You'll want to define more constants to make your code easier 
		; to read and debug
	   
		; Memory allocated for user-entered strings
prompt = "Enter a number:  ",0          
		; Additional strings may be defined here
prompt_divisor = "Enter a divisor: ", 0
prompt_dividend = "Enter a dividend: ", 0
response_quotient = "Quotient = ", 0
response_remainder = "Remainder = ", 0
	ALIGN

lab3
	STMFD SP!,{lr}	; Store register lr on stack
	
	; Enter Dividend
	LDR 	r4, =prompt_dividend	
	BL 		output_string		; print dividend prompt
	LDR		r4, =prompt_dividend
	BL 		read_string			; read user input
	BL 		output_string		; print user input
	
	MOV 	r0, #0x0A			; print LF
	BL 		output_character
	
	; Enter Divisor
	LDR 	r4, =prompt_divisor
	BL 		output_string		; print divisor prompt
	LDR		r4, =prompt_divisor			
	BL 		read_string			; read user input 
	BL 		output_string		; print user input
	
	MOV 	r0, #0x0A			; print LF
	BL 		output_character
	
	; Convert ASCII to int
	LDR 	r4, =prompt_dividend
	BL 		atoi
	MOV 	r2, r0				; save dividend_int in r2
	LDR 	r4, =prompt_divisor
	BL 		atoi
	MOV 	r1, r0				; move divisor_int in r1
	MOV 	r0, r2				; move dividend_int in r0
	
	; Perform calculation
	BL 		div_and_mod			; Return: r0 = quotient, r1 = remainder
	
	; Print Quotient
	LDR 	r4, =response_quotient
	BL 		output_string
	LDR 	r4, =prompt			; convert quotient int to ASCII
	BL		itoa
	BL 		output_string
	
	MOV 	r0, #0x0A			; print LF
	BL 		output_character
	
	; Print Remainder
	LDR 	r4, =response_remainder
	BL 		output_string
	LDR 	r4, =prompt
	MOV 	r0, r1
	BL 		itoa
	BL 		output_string
	
	LDMFD sp!, {lr}
	BX lr

read_string				; base address of string passed into r4
	STMFD SP!, {lr, r4} 	; Store register lr on stack
rs_loop
	BL 		read_character
	STRB 	r0, [r4], #1 		; store char into [r4], increment index
	BL 		output_character
	CMP 	r0, #0x0D			; check if char CR
	BNE 	rs_loop				; loop if char != CR
	MOV 	r5, #0 			
	STRB	r5, [r4, #-1]! 		; decrement buff index, then append NULL char
	
	MOV 	r0, #0x0A			; print new line
	BL 		output_character 	; 
	
	LDMFD sp!, {lr, r4}
	BX lr

output_string 			; base address of string passed into r4
	STMFD 	SP!, {lr, r0-r4}
os_loop
	LDRB	r0, [r4], #1		; char loaded into r0, r4 post-indexed base updated 
	LDR 	r1, =U0BA 			; set r1 to UART0 Base Address
	BL 		output_character	; output char in r0 
	CMP 	r0, #0				; check if char is 0
	BNE		os_loop				; loop if char != 0
	
	LDMFD sp!, {lr, r0-r4}
	BX lr
	
	
read_character					; Read Data
	STMFD 	SP!,{lr}			; Store register lr on stack
	LDR 	r0, =0xE000C000		; Load UART0 Base Address
rstart
	LDRB 	r1, [r0, #U0LSR]	; Load Status Register Addresss
	ANDS	r2, r1, #1  	; Test RDR in Status Register
	BEQ		rstart 		 	; if RDR == 0 -> rstart
	LDRB	r3, [r0]  		; else Read byte from receive register
	MOV 	r0, r3			; Return char in r0
	LDMFD 	sp!, {lr}			
	BX 		lr

output_character    			; char passed in through r0
	STMFD 	SP!,{lr, r1-r3}  			; Store register lr on stack
	
	MOV		r3, r0				; Store char argument into r3
	LDR 	r0, =0xE000C000  	; Load UART0 Base Address
tstart
	LDRB 	r1, [r0, #U0LSR]	; Load Status Register Addresss
	ANDS 	r2, r1, #32  	; test THRE in Status Register
	BEQ 	tstart  		; if THRE == 0 -> tstart
	STRB	r3, [r0]  		; else Store byte in transmit register
	MOV 	r0, r3
	LDMFD 	sp!, {lr, r1-r3}
	BX 		lr

atoi
	; Args r4 = base address of char
	; r5 = sign bit, 1 if neg, 0 if pos
	; r2 = total
	; r3 = 10
	
	; Return r0
	STMFD	SP!, {lr, r2-r4}
	MOV 	r2, #0
	MOV 	r3, #10
	; Check sign
	MOV 	r5, #0
	LDRB 	r0, [r4], #1 		; Load sign bit
	CMP 	r0, #0x2D
	MOVEQ 	r5, #1				; Set r5 = 0 if negative
atoi_loop
	LDRB	r0, [r4], #1 		; Load char
	CMP 	r0, #0
	BEQ 	atoi_end 			; Branch to end of subroutine if NULL char
	SUB 	r0, r0, #48 		; Conver to int
	MLA 	r2, r3, r2, r0
	B 		atoi_loop
atoi_end
	CMP 	r5, #1				; Convert to two's comp if negative
	MVNEQ 	r2, r2
	ADDEQ 	r2, r2, #1
	MOV 	r0, r2 				; Return in r0
	LDMFD 	sp!, {lr, r2-r4}
	BX		lr
	
itoa
	; Args r4 = base address to store result string
	; 	   r0 = int to convert
	; r2 = divisor 10
	; r3 = counter
	STMFD	SP!, {lr, r1-r4}
	MOV 	r3, #0
	MOV 	r1, #10
	; Check sign
	CMP 	r0, #0
	MOV 	r5, #0x2D		; '-' char
	STRBMI	r5, [r4], #1	; if negative, insert '-' char
	MVNMI	r0, r0			; if negative, convert to two's comp
	ADDMI	r0, r0, #1
itoa_loop
	BL 		div_and_mod
	CMP 	r1, #0			; if remainder == 0, branch to end
	BEQ		itoa_pop
	ADD		r1, r1, #48			; Convert int to ASCII
	PUSH	{r1}			; Push onto stack
	ADD		r3, r3, #1 		; Increment Counter
	B 		itoa_loop
itoa_pop
	CMP 	r3, #0			; Pop from stack until counter == 0
	BEQ		itoa_end
	POP		{r1}
	STRB	r1, [r4], #1	; Store popped char into memory
	SUB 	r3, r3, #1
	B		itoa_pop
itoa_end
	MOV 	r1, #0			; append NULL char
	STRB 	r1, [r4]
	LDMFD 	sp!, {lr, r1-r4}
	BX		lr
	
div_and_mod
	STMFD r13!, {r2-r12, r14}
			
	; Your code for the signed division/mod routine goes here.  
	; The dividend is passed in r0 and the divisor in r1.
	; The quotient is returned in r0 and the remainder in r1. 
	
	; r0 = dividend
	; r1 = divisor
	; r2 = counter
	; r3 = quotient
	; r4 = remainder
	; r5 = dividend sign
	; r6 = divisor sign
	; r7 = r5 XOR r6
	; RETURN r0 = quotient
	; 		 r1 = remainder
	
	; check sign of dividend
	CMP 	r0, #0
	MOV 	r5, #0
	MOVMI 	r5, #1
	; if dividend < 0, convert to two's comp
	MVNMI 	r0, r0
	ADDMI 	r0, r0, #1
	
	; check sign of divisor
	CMP 	r1, #0
	MOV 	r6, #0
	MOVMI 	r6, #1
	; if divisor < 0, convert to two's comp
	MVNMI 	r1, r1
	ADDMI 	r1, r1, #1
	
	MOV 	r2, #15			; Init counter to 15
	MOV 	r3, #0 			; Init quotient to 0
	LSL 	r1, r1, #15 		; lsl divisor by 15
	ADD 	r4, r0, #0 			; Set remainder to dividend
loop
	SUBS	r4, r4, r1			; rem = rem - divis
	
	; if(remainder < 0)
	ADDLT	r4, r4, r1 			; rem = rem + divis
	LSLLT	r3, #1 				; lsl quotient
	; else
	LSLGE	r3, #1				; lsl quotient
	ORRGE	r3, r3, #1 			; set LSB of quot = 1
	
	LSR		r1, r1, #1 			; right shift divis
	SUBS 	r2, r2, #1			; decrement counter
	BPL		loop				; branch if count >= 0
	
	ADD		r0, r3, #0			; set quot to r0
	ADD 	r1, r4, #0 			; set remain to r1
	
	EOR 	r7, r5, r6
	CMP 	r7, #1				
	; if dvnd != dvsr, convert answer to two's comp
	MVNEQ 	r0, r0
	ADDEQ 	r0, r0, #1
		
	LDMFD r13!, {r2-r12, r14}
	BX lr      ; Return to the C program	


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
