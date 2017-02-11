	AREA	LAB2, CODE, READWRITE	
	EXPORT	div_and_mod
	
div_and_mod
	STMFD r13!, {r2-r12, r14}
			
	; Your code for the signed division/mod routine goes here.  
	; The dividend is passed in r0 and the divisor in r1.
	; The quotient is returned in r0 and the remainder in r1. 
	
	LDMFD r13!, {r2-r12, r14}
	BX lr      ; Return to the C program	


	END

	
