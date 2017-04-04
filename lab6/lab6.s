; Do Om / doom
; Arunan Bala Krishnan / arunanba
	AREA interrupts, CODE, READWRITE
	EXPORT lab6
	EXPORT FIQ_Handler
    EXPORT TCR
	EXTERN output_string
	EXTERN read_character
	EXTERN output_character
	EXTERN display_digit_on_7_seg
	EXTERN display_digit_on_7_seg_setup
	EXTERN display_digit_on_7_seg_clear
	EXTERN pin_connect_block_setup_for_uart0
	EXTERN div_and_mod
    EXTERN newline
	EXTERN rng
	EXTERN itoa
    EXPORT lab6_exit
    

line_00 = "Walls =       \r\n", 0
line_01 = "|-------------|\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|             |\r\n|-------------|\r\n", 0							   
str_users = "*@#X", 0
str_user = " ", 0
str_clear = "\033[J", 0
str_pos = "\033[08;08f", 0
str_pause = "PAUSED", 0
str_exit = "bye", 0
str_instructions = "Press a key to start", 0
    ALIGN
score DCD 0
    ALIGN
y_pos DCD 0x8
x_pos DCD 0x8    
    ALIGN
vel_down DCD 0
vel_right DCD 1
paused DCD 0
start DCD 0
    ALIGN
pos
    DCD 0x3030 ; 00
    DCD 0x3130 ; 01
    DCD 0x3230 ; 02
    DCD 0x3330 ; 03
    DCD 0x3430 ; 04
    DCD 0x3530 ; 05
    DCD 0x3630 ; 06
    DCD 0x3730 ; 07
    DCD 0x3830 ; 08
    DCD 0x3930 ; 09
    DCD 0x3031 ; 10
    DCD 0x3131 ; 11
    DCD 0x3231 ; 12
    DCD 0x3331 ; 13
    DCD 0x3431 ; 14
    DCD 0x3531 ; 15
    DCD 0x3631 ; 16
    DCD 0x3731 ; 17
    ALIGN
        
TCR EQU 0xE0004008 	; Timer 0 Counter Register
    ALIGN
        
lab6	 	
	STMFD sp!, {lr} 	; r7 = status  
	BL interrupt_init 	; initialize UART0, timer0, button interrupts
    
    LDR r4, =str_instructions
    BL output_string
lab6_start_loop
    ; check if started
    LDR r0, =start
    LDR r1, [r0]
    CMP r1, #0
    BEQ lab6_start_loop

    ; get initial random position
    MOV r0, #12     ; get random num in range of 13
    BL rng
    LDR r1, =y_pos
    ADD r0, r0, #3  ; add 3 to compensate for borders
    STR r0, [r1]    ; store in y_pos
    MOV r0, #13     ; get random num in range of 13
    BL rng
    ADD r0, r0, #2  ; add 2 to compensate for borders
    LDR r1, =x_pos  ; store in x_pos
    STR r0, [r1]
    
    ; get random user character
    MOV r0, #4
    BL rng
    LDR r1, =str_users
    LDR r2, =str_user
    LDRB r3, [r1, r0]
    STRB r3, [r2]
    
    ; get initial random direction
    ;MOV r0, #4
    ;BL rng
    ;CMP r0 #0
    ;BNE
    
    ;B lab6_loop
    
lab6_loop
	B lab6_loop
lab6_exit
	LDMFD sp!,{lr}
	BX lr

interrupt_init      
	STMFD SP!, {r0-r1, r4-r5, lr}   ; Save registers 
		
	; Push button setup		 
	LDR r0, =0xE002C000
	LDR r1, [r0]
	ORR r1, r1, #0x20000000
	BIC r1, r1, #0x10000000
	STR r1, [r0]  ; PINSEL0 bits 29:28 = 10
		
	; UART0 setup
	LDR r0, =0xE000C004  ; U0IER
	LDR r1, [r0]
	ORR r1, r1, #1 	; Enable Receive Data Available Interrupt(RDA) Bit 0
	STR r1, [r0]

	; Classify sources as IRQ or FIQ
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0xC]
	ORR r1, r1, #0x8000 ; External Interrupt 1
	ORR r1, r1, #0x40 	; UART0 Interrupt
    ORR r1, r1, #0x10   ; TIMER 0
	STR r1, [r0, #0xC]

	; Enable Interrupts
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0x10] 
	ORR r1, r1, #0x8000 ; External Interrupt 1
	ORR r1, r1, #0x40	; UART0 Interrupt
    ORR r1, r1, #0x10    ; TIMER 0
	STR r1, [r0, #0x10]
	
    LDR r4, =0xE0004014 	; T0MCR - Timer0MatchControlRegister
	LDR r5, [r4]
    ORR r5, r5, #0x18 		; Interrupt and Reset for MR1
    STR r5, [r4]

	; Set match register
	LDR r4, =0xE000401C 	; Match Register 1
	LDR r5, =0x000FF000		; Set time to match time
	STR r5, [r4]

	; Enable Timer0
	LDR r4, =0xE0004004	    ; T0TCR - Timer0ControlRegister
    LDR r5, [r4]
	ORR r5, r5, #1
	STR r5, [r4]
	
	; External Interrupt 1 setup for edge sensitive
	LDR r0, =0xE01FC148
	LDR r1, [r0]
	ORR r1, r1, #2  ; EINT1 = Edge Sensitive
	STR r1, [r0]

	; Enable FIQ's, Disable IRQ's
	MRS r0, CPSR
	BIC r0, r0, #0x40
	ORR r0, r0, #0x80
	MSR CPSR_c, r0

	LDMFD SP!, {r0-r1, r4-r5, lr} ; Restore registers
	BX lr             	   ; Return

FIQ_Handler
	STMFD SP!, {r0-r12, lr}   ; Save registers 
Timer0Int ; Check for Timer 0 Interrupt
	LDR r0, =0xE0004000  	; T0InterruptRegister
	LDR r1, [r0]
	TST r1, #2 	;  1 if pending interrupt due to Match Register 1
	BEQ UART0
	
    ; check if started
    LDR r0, =start
    LDR r1, [r0]
    CMP r1, #0
    BEQ Timer0Int_Exit
    
    ; check if paused
    LDR r0, =paused         ; skip position updates if paused
    LDR r1, [r0]
    CMP r1, #1
    BEQ Timer0Int_Draw
    
    ; update vertical position
    LDR r0, =vel_down       ; get vel_down
    LDR r1, [r0]
    LDR r4, =y_pos          ; get y_pos
    LDR r5, [r4]
    ADD r5, r5, r1          ; y_pos = y_pos + vel_down
    ; check y_pos collision
    ; if y_pos == 16
    CMP r5, #16
    ADDEQ r5, r5, #-2       ; y_pos -= 2
    MVNEQ r1, r1            ; two's comp vel_down
    ADDEQ r1, r1, #1
    STREQ r1, [r0]          ; store new vel_down
    LDREQ r0, =score        ; increment score
    LDREQ r1, [r0]
    ADDEQ r1, r1, #1
    STREQ r1, [r0]    
    ; if y_pos == 2
    CMP r5, #2
    ADDEQ r5, r5, #2        ; y_pos += 2
    MVNEQ r1, r1            ; two's comp vel_down
    ADDEQ r1, r1, #1
    STREQ r1, [r0]          ; store new vel_down
    LDREQ r0, =score        ; increment score
    LDREQ r1, [r0]
    ADDEQ r1, r1, #1
    STREQ r1, [r0]
    STR r5, [r4]            ; store new y_pos
    
    ; update horizontal position
    LDR r0, =vel_right      ; get vel_right
    LDR r1, [r0]
    LDR r4, =x_pos          ; get x_pos
    LDR r5, [r4]
    ADD r5, r5, r1          ; x_pos = x_pos + vel_right
    ; check x_pos collision
    ; if x_pos == 14
    CMP r5, #14
    ADDEQ r5, r5, #-2       ; x_pos -= 2
    MVNEQ r1, r1            ; two's comp vel_right
    ADDEQ r1, r1, #1
    STREQ r1, [r0]          ; store new vel_right
    LDREQ r0, =score        ; increment score
    LDREQ r1, [r0]
    ADDEQ r1, r1, #1
    STREQ r1, [r0]
    ; if y_pos == 0
    CMP r5, #0
    ADDEQ r5, r5, #2        ; x_pos += 2
    MVNEQ r1, r1            ; two's comp vel_right
    ADDEQ r1, r1, #1
    STREQ r1, [r0]          ; store new vel_right
    LDREQ r0, =score        ; increment score
    LDREQ r1, [r0]
    ADDEQ r1, r1, #1
    STREQ r1, [r0]
    STR r5, [r4]            ; store new x_pos   
    
    ; update score
    LDR r4, =line_00        ; get line_00
    ADD r4, r4, #9
    LDR r1, =score          ; get score
    LDR r0, [r1]
    BL itoa             ; convert decimal to str and store in line_00   
    
Timer0Int_Draw
    ; clear screen
    LDR r4, =str_clear
    BL output_string
	
    LDR r4, =line_00
    BL output_string
    BL newline
    LDR r4, =line_01
    BL output_string            ; print box
    
    ; Set user char coordinates
    LDR r0, =str_pos
    LDR r1, =pos      
    
    LDR r2, =y_pos      ; place y_pos into str_pos
    LDR r3, [r2]        ; get hex y_pos
    LSL r3, r3, #2      ; multiply by 2 
    LDRH r4, [r1, r3]   ; load y_pos string
    STRH r4, [r0, #2]
    
    LDR r2, =x_pos      ; place x_pos into str_pos
    LDRB r3, [r2]       ; get hex x_pos
    LSL r3, r3, #2      ; multiply by 2
    LDRH r4, [r1, r3]   ; load x_pos string
    ; due to non-even alignment,
    ; must store x_pos byte by byte into str_pos
    STRB r4, [r0, #5]   ; store first byte into str_pos
    LSR r4, r4, #8      ; shift second byte int LSB
    STRB r4, [r0, #6]   ; store second byte into str_pos
    
    LDR r4, =str_pos
    BL output_string    ; move cursor to str_pos
    
    ; Print user character onto screen
    LDR r4, =str_user
    LDRB r0, [r4]
    BL output_character

Timer0Int_Exit
    ; Clear Interrupt
	LDR r0, =0xE0004000 	; get T0InterruptRegister
	LDR r1, [r0]			; by writing 1 to bit 1
	ORR r1, #2              ; Clear interrupt for MR1
	STR r1, [r0]            ; by writing to bit 1
	BEQ FIQ_Exit

UART0	; Check for UART0 interrupt
	LDR r0, =0xE000C008  ; UART0 Interrupt Identification Register(U0IIR)
	LDR r1, [r0]
	TST r1, #1	; Bit 0 / 0 = pending, 1 = no pending interrupts
	BNE EINT1
	
	STMFD SP!, {r0-r12, lr}
	BL read_character
    
    ; set started if not
    LDR r4, =start
    LDR r6, [r4]
    CMP r6, #0
    MOV r5, #1
    STR r5, [r4]
    BEQ UART0_Exit
        
    CMP r0, #0x75       ; r0 == 'u'
    BNE UART0_d
    LDR r0, =vel_down   ; get vel_down
    MOV r1, #-1          ; vel_down = -1
    STR r1, [r0]
    
    LDR r0, =vel_right  ; get vel_right
    MOV r1, #0          ; vel_right = 0
    STR r1, [r0]
    
    B UART0_Exit
UART0_d
    CMP r0, #0x64
    BNE UART0_r
    LDR r0, =vel_down   ; get vel_down
    MOV r1, #1          ; vel_down = 1
    STR r1, [r0]
    
    LDR r0, =vel_right  ; get vel_right
    MOV r1, #0          ; vel_right = 0
    STR r1, [r0]
    B UART0_Exit
UART0_r
    CMP r0, #0x72
    BNE UART0_l
    LDR r0, =vel_down   ; get vel_down
    MOV r1, #0          ; vel_down = 0
    STR r1, [r0]
    
    LDR r0, =vel_right  ; get vel_right
    MOV r1, #1          ; vel_right = 1
    STR r1, [r0]
    
    B UART0_Exit

UART0_l
    CMP r0, #0x6C
    BNE UART0_space
    LDR r0, =vel_down   ; get vel_down
    MOV r1, #0          ; vel_down = 0
    STR r1, [r0]
    
    LDR r0, =vel_right  ; get vel_right
    MOV r1, #-1          ; vel_right = -1
    STR r1, [r0]
    
    B UART0_Exit

UART0_space
    CMP r0, #0x20
    BNE UART0_q
    LDR r0, =paused
    LDR r1, [r0]
    CMP r1, #0
    MOVEQ r1, #1
    MOVNE r1, #0
    STR r1, [r0]
    B UART0_Exit
UART0_q
    CMP r0, #0x71
    BNE UART0_plus
    LDR r4, =str_exit
    BL output_string
    B lab6_exit
UART0_plus
    CMP r0, #0x2B
    BNE UART0_minus
   
    B UART0_Exit
UART0_minus
    CMP r0, #0x2D
    BNE UART0_Exit
   
    B UART0_Exit    

UART0_Exit
	LDMFD SP!, {r0-r12, lr}
	B FIQ_Exit

EINT1	; Check for EINT1 interrupt
	LDR r0, =0xE01FC140 ; EXTINT External Interrupt Flag Register
	LDR r1, [r0]
	TST r1, #2
	BEQ FIQ_Exit
																
	STMFD SP!, {r0-r12, lr}   ; Save registers 
	
	;LDR r4, =str_user
	;BL	output_string
	
	LDMFD SP!, {r0-r12, lr}   ; Restore registers
		
	ORR r1, r1, #2		; Clear Interrupt
	STR r1, [r0]
	
FIQ_Exit
	LDMFD SP!, {r0-r12, lr}
	SUBS pc, lr, #4


	END