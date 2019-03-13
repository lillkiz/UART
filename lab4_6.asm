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
.org 0x0000
rjmp Main

Main:
	ldi YL, low(Outs)		;input	
	ldi YH, high(Outs)
	ldi XL, low(Outs)		;output
	ldi XH, high(Outs)	

	ldi r16, 0xFF			;echo test
	sts PORTC_DIR, r16
	sts PORTC_OUT, r16

	rcall USART_INIT		;setup USART
	rcall IN_STRING
	rcall OUT_STRING
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
;This subroutine takes in a string och 
;characters
;******************************************
IN_STRING:
	push r16			;push reg used
STILL_GOING:	
	rcall IN_CHAR
	st Y+, r16		
	cpi r16, 0x0D		;check if return	
	breq DONE

	cpi r16, 0x08		;check if backspace
	brne STILL_GOING

	ldi r16, 0x00		;go back and store NULL
	st -Y, r16		
DONE:
pop r16
	ret
;****************************************** 
;This subroutine outputs a string
;******************************************
OUT_STRING:
	push r16			;push reg used
AGAIN:
	ld r16, X+			
	cpi r16, 0x00		;check for end 
    breq FINISHED
	Rcall OUT_CHAR		;output char
	rjmp AGAIN
FINISHED:
	pop r16
	ret

;****************************************** 
;This subroutine takes in a character
;******************************************
IN_CHAR:
	push r17					;push reg used
POLLING_IN:
	lds r17, USARTD0_STATUS		;checking flag	
	andi r17, USART_RXCIF_bm	;bit7 mask
	cpi r17, USART_RXCIF_bm		
	brne POLLING_IN				;no flag

	lds r16, USARTD0_DATA		;testing echo	
	sts PORTC_OUT, r16			

	pop r17	
	ret
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

