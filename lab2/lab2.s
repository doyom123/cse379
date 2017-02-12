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
	
	; RETURN r0 = quotient
	; 		 r1 = remainder

	MOV 	r2, #15			; Init counter to 15
	MOV 	r3, #0 			; Init quotient to 0
	LSL 	r1, r1, #15 		; lsl divisor by 15
	ADD 	r4, r0, #0 			; Set remainder to dividend
	
loop
	SUBS	r4, r4, r1			; rem = rem - divis
	
	; if(remainder < 0)
	ADDMI	r4, r4, r1 			; rem = rem + divis
	LSLMI	r3, #1 				; lsl quotient
	; else
	LSLPL	r3, #1				; lsl quotient
	ORRPL	r3, r3, #1 			; set LSB of quot = 1
	
	LSR		r1, r1, #1 			; right shift divis
	SUBS 	r2, r2, #1			; decrement counter
	BPL		loop				; branch if count >= 0
	
	ADD		r0, r3, #0			; set quot to r0
	ADD 	r1, r4, #0 			; set remain to r1
	
	LDMFD r13!, {r2-r12, r14}
	BX lr      ; Return to the C program	


	END

	
