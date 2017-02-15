	AREA	LAB2, CODE, READWRITE	
	EXPORT	div_and_mod
	
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
	MOV 	r5, #0
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


	END

	
