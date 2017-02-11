	AREA	SquareTest, CODE, READONLY	
	ENTRY
	
	
main	MOV r5, #40		; Replace the contents of register r5 
						; with the square root of the largest
						; perfect square less than or equal to 
						; the value originally in r5.
		MOV r1, #1
	
LOOP	ADD r1, r1, #1	; Increment r1 by 1
		MOV r3, r1		; Load r3 for multiplication
		
		SUB	r2, r3, #1	; Start of multiplication 
						; routine r3 = r3 * r1
MULT	ADD r3, r3, r1	; 
		SUB r2, r2, #1	; Decrement counter
		CMP r2, #0
		BGT MULT
			
		CMP r3, r5		; Has the value been found?
		BLE LOOP		; If not, try check for the next integer
		
		SUB r5, r1, #1	; Answer  
		
STOP	MOV	r0, #0x18
		LDR	r1, =0x20026
		SWI	0x0123456
				
		END	
