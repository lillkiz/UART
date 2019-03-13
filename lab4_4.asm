;********************************************** 
;Project 4 
;Part 4 
;Malin Andersson 
;2/26/2019
;Transmitts strings of characters from uP to PC
;**********************************************
.include "ATxmega128A1Udef.inc"

.equ	charU = 0x55

.org 0x2000
DATA:	.db		"Malin Andersson", 0

.org 0x0000
rjmp Main

Main:
	rcall USART_INIT		;setup USART

	ldi ZL, byte1(DATA<<1)	;load address
	ldi ZH, byte2(DATA<<1) 

	rcall OUT_STRING		;output strings
LOOP:
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
;This subroutine outputs a string from a 
;preset data table DATA utalizing 
;subroutine OUT_CHAR
;******************************************
OUT_STRING:
	push r16			;push reg used

	lpm r16, Z+			
	cpi r16, 0			;check for end 
    breq DONE

	Rcall OUT_CHAR		;output char
	rjmp OUT_STRING
DONE:
	ret
;****************************************** 
;This subroutine outputs one char passed 
;by subroutine OUT_STRING
;******************************************
OUT_CHAR:
	push r17					;push reg used
POLLING:
	lds r17, USARTD0_STATUS		;checking flag	
	cpi r17, USART_DREIF_bm		
	brne POLLING 

	sts USARTD0_DATA, r16		;out char U
	pop r17						
	ret
