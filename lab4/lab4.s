	AREA	GPIO, CODE, READWRITE	
	EXPORT lab4
	
PIODATA EQU 0x8 ; Offset to parallel I/O data register
	
prompt	= "Welcome to lab #4  ",0   	; Text to be sent to PuTTy
	ALIGN
digits_SET	
		DCD 0x00001F80  ; 0
 		DCD 0x00003000  ; 1 
						; Place other display values here
		DCD 0x00003880  ; F

	ALIGN
lab4
	STMFD SP!,{lr}	; Store register lr on stack
	
		; Your code goes here
		

	LDMFD SP!, {lr}	; Restore register lr from stack	
	BX LR
	END