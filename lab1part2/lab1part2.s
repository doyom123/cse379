	AREA Lab1Part2, CODE, READONLY
	ENTRY

main MOV r5, #17


	
	MOV r1, #1
	MOV r2, #0
LOOP ADD r1, r1, #1
	ADD r2, r1, r2
	CMP r2, r5
	BLE LOOP
	
	SUB r5, r1, #1
	
STOP MOV r0, #0x18
	LDR r1, =0x20026
	SWI 0x0123456
	
	END