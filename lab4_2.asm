;********************************************** 
;Project 4 
;Part 2 
;Malin Andersson 
;2/26/2019
;Transmitts a ASCII character (U) from uP to PC
;**********************************************
.include "ATxmega128A1Udef.inc"

.equ	charU = 0x55

.cseg

.org 0x0000
rjmp Main

Main:
	rcall USART_INIT		;setup USART
	ldi r16, charU			;load char U
LOOP:
	rcall OUT_CHAR			;output char U
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
;This subroutine outputs charU = 0b01010101
;******************************************
OUT_CHAR:
	push r17					;push reg used
POLLING:
	lds r17, USARTD0_STATUS		;checking flag	
	cpi r17, USART_DREIF_bm		
	brne POLLING 

	sts USARTD0_DATA, r16		;out
	pop r17						
	ret