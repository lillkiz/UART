;********************************************** 
;Project 4 
;Part 6 
;Malin Andersson 
;3/1/2019
;Transmitts strings of characters from uP to PC
;**********************************************
.include "ATxmega128A1Udef.inc"

.dseg		
.org 0x2000		
Outs:  .BYTE 3	
	
.cseg	

.org USARTD0_RXC_vect		;UART interrupt
rjmp RECEIVED
		
.org 0x0000
rjmp Main

Main:
	ldi r16, 0xFF				;echo test
	sts PORTC_DIR, r16
	sts PORTC_OUT, r16

	rcall USART_INIT			;setup USART

	ldi r16, 0x20				;LED out
	sts PORTD_DIR, r16 
	ldi r16, 0x10				;priority
	sts  USARTD0_CTRLA, r16
    ldi r16, PMIC_LOLVLEX_bm	;PMIC
    sts PMIC_CTRL, r16
	sei 

	ldi r18, 0x00				;waiting for char
	ldi r19, 0x20
LOOP:	
	sts PORTD_OUTTGL, r19		;toggle LED
	cpi r18, 0x00				;no char yet			
	breq LOOP
	rcall OUT_CHAR				;recevied char
	ldi r18, 0x00				;wait for char
	rjmp LOOP

;****************************************** 
;This subroutine initializes the USART
;frame = 8	stop = 1	parity = odd
;baud = 115200	USART = PORT D
;******************************************
USART_INIT:
	push r16					;push reg used

	ldi r16, 0x08				;Rx out, rest in
	sts PORTD_DIRSET, r16

	ldi r16, 0x18				;Tx and Rx enables
	sts USARTD0_CTRLB, r16		

	ldi r16, 0x33				;00 - async, 11 - odd
	sts USARTD0_CTRLC, r16		;0 - 1 stop, 011 - 8 bit

	ldi r16, 0x0B				;lower BSEL = 11
	sts USARTD0_BAUDCTRLA, r16	

	ldi r16, 0x90				;BSCLAE = -7
	sts USARTD0_BAUDCTRLB, r16	;high BSEL = 0

	pop r16						
	ret

;****************************************** 
;This interrupt starts when char received
;******************************************
RECEIVED:
	push r17				;push status
	lds r17, CPU_SREG
	push r17

	lds r16, USARTD0_DATA	;reading input
	com r18					;done with char

	pop r17					;pop status
	sts CPU_SREG, r17
	pop r17
	RETI
;****************************************** 
;This subroutine outputs one char
;******************************************
OUT_CHAR:
	push r17					;push reg used
POLLING_OUT:
	lds r17, USARTD0_STATUS		;checking flag	
	andi r17, USART_DREIF_bm	;bit6 mask
	cpi r17, USART_DREIF_bm		
	brne POLLING_OUT 

	sts USARTD0_DATA, r16		;out char
	pop r17						
	ret

