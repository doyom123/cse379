	AREA Evaluate , CODE, READONLY
	EXPORT	evaluate

evaluate
	ADD r2, r1, #17
	MUL r3, r2, r0
	SUB r0, r3, #25
	MOV pc, lr
	
	END