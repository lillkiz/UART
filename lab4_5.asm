;********************************************** 
;Project 4 
;Part 5 
;Malin Andersson 
;2/28/2019
;Transmitts strings of characters from uP to PC
;**********************************************
.include "ATxmega128A1Udef.inc"

.org 0x0000
rjmp Main

Main:
	rcall LED_INIT			;setup echo
	rcall USART_INIT		;setup USART
LOOP:
	rcall IN_CHAR			;receive from PC
	rcall OUT_CHAR			;send to PC

	rjmp LOOP
LED_INIT:
	push r16

	ldi r16, 0xFF			;portC out & off
	sts PORTC_DIR, r16
	sts PORTC_OUT, r16

	pop r16

	ret
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
;This subroutine takes in a character
;******************************************
IN_CHAR:
	push r17					;push reg used

	lds r17, USARTD0_STATUS		;checking flag	
	andi r17, USART_RXCIF_bp	;bit7 mask
	cpi r17, USART_RXCIF_bp		
	brne IN_CHAR				;no flag

	lds r16, USARTD0_DATA		;echo	
	sts PORTC_OUT, r16

	pop r17	
	ret
;****************************************** 
;This subroutine outputs one char passed 
;by subroutine OUT_STRING
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
