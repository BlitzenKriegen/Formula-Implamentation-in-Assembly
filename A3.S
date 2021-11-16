; Name:   Kiril Sikov
; Email:  ksiko870@mtroyal.ca
; Course: Comp-2655
; Due: 	  October 29th,2021
; File:   A3.S
;
; Purpose: The purpose of this program is to accept
; a three-digit number and apply the formula
; (((3*x)^2)/8 + 45)%1000 to the input. Then, the
; result would be printed
;
; Details: input: A three digit number
;	   output: A second three digit number, which
;		   has had the formula above applied
;	   note: The implamentation of a "mod" function
;		 is to divide a number, swap the LW and HW
;		 and then clear the highword with a mask. To
;		 divide by 8, the system bit shift's right
;		 by 3 (as 8 is 2^3 and bit shift right is divide
;		 by 2).
;		 Additionally, the program assumes unsigned
;		 values are put in between 000 and 999.
;	   program status:
;		All needed requirements of the assignment complete.
;		   -Reading in numbers is functional
;		   -The formula specified by the assignment is
;		    implamented
;		   -Writing output works at the line below the input.
;	   Register Purpose:
;		d0: This register reads or writes values one char at a time
;		and puts it into another register or output.		
;		d1: 100's digit on input
;		d2: 10's digit on input
;		d3: 1's digit on input
;		d4: sum of d1,d2 and d3. Also gets processed with the
;		assignment formula
;		d5: 100's digit on output
;		d6: 10's digit on output
;		d7; 1's digit on output
;
;----- CONSTANTS -----
CR:		equ	10	;Carrige Return
LF:		equ	13	;Line Feed
ZERO:		equ	'0'	;ASCII zero value
;---------------------
start:		nop

read_info:	jsr 	read_char ;Read a char and store in d1
		and.l	#$00FF,d0
		sub.w	#ZERO,d0
		move.l	d0,d1
		mulu.w	#100,d1

		jsr	read_char ;Read a char and store in d2
		and.l	#$00FF,d0
		sub.w	#ZERO,d0
		move.l	d0,d2
		mulu.w	#10,d2

		jsr	read_char ;Read a char and store in d3
		and.l	#$00FF,d0
		sub.w	#ZERO,d0
		move.l	d0,d3

combine:	add.w	d1,d4	  ;Add the digits to one number
		add.w	d2,d4
		add.w	d3,d4
	
formula:	mulu.w	#3,d4	  ;Applies the formula specified
		mulu.w	d4,d4	  ;as y=(((3*x)^2)/8 + 45)%1000
		lsr.l	#3,d4
		add.l	#45,d4
		divu.w	#1000,d4
		swap	d4
		and.l 	#$FFF,d4

newline:	move.l	#CR,d0	  ;Goes to next line and clears
		jsr	write_char
		move.l	#LF,d0
		jsr	write_char

write:		move	d4,d5	  ;Getting 100's digit
		divu.w	#100,d5
		and.l	#$F,d5
		add.w	#ZERO,d5
		move 	d5,d0
		jsr	write_char

		move	d4,d6	  ;Getting 10's digit
		divu.w	#10,d6
		and.l	#$F,d6
		add.w	#ZERO,d6
		move 	d6,d0
		jsr	write_char

		move	d4,d7	  ;Getting 1's digit
		divu.w	#10,d7
		swap	d7
		and.l	#$F,d7
		add.w	#ZERO,d7
		move	d7,d0
		jsr	write_char

endline:	move.l	#CR,d0	  ;Reset the line after printing of value
		jsr	write_char
		move.l	#LF,d0
		jsr	write_char
					   	
		jsr	exit


;----- SUBROUTINE: read_char -----
;
; PURPOSE: waits for and reads a single keystroke from the keyboard.
;
; CALLER OUTPUT: returns the ASCII value of the key in the low byte
;                of D0.
;
; IMPORTANT: NOTE THAT THE HIGHER_ORDER BYTES OF D0 ARE UNDEFINED.
;            DON'T ASSUME THEY ARE ZEROED OUT!
;
; E.G. CALL:	jsr	read_char
;		... now use D0.b ...

read_char:	movem.l	d1-d2/a0-a2,-(sp)
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp	
		movem.l	(sp)+,d1-d2/a0-a2
		rts


;----- SUBROUTINE: write_char -----
;
; PURPOSE: writes a single character to the screen.
;
; CALLER INPUT: takes the ASCII value of the character in the low byte
;               of D0.
;
; E.G. CALL:	move.b	#'a',d0
;		jsr	write_char

write_char:	movem.l	d0-d2/a0-a2,-(sp)
		and.w	#$00FF,d0
		move.w	d0,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


;----- SUBROUTINE: exit -----
;
; PURPOSE: terminates the program.  This routine never returns.

exit:		clr.w	-(sp)
		trap	#1
