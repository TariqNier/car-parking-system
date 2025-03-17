ORG 0H
; SERVO REQUIRES A SIGNAL OF 50Hz WHICH IS 20ms.
; Position "0" ( 1.5 ms of 20 ms pulse) turns in the middle.
; Position "+90" ( 2ms of 20 ms pulse) turns all the way to the right.
; Position "-90" ( 1ms of 20 ms pulse) turns all the way to the left.
; Position "+45" ( 1.75ms of 20 ms pulse) turns half the way to the right.
; Position "-45" ( 1.25ms of 20 ms pulse) turns half the way to the left.	
RS EQU P2.1
RW EQU P2.2
E EQU P2.3
CSG EQU P2.4
PARK1 EQU P0.1
PARK2 EQU P0.2
PARK3 EQU P0.3

;LCD INITIALIZATION

		MOV A, #00111000B	; INITIATE LCD #38H
		ACALL COMMANDWRT
		ACALL DELAY

		MOV A, #00001110B	; DISPLAY ON CURSOR OFF #0CH
		ACALL COMMANDWRT
		ACALL DELAY
		
		
		
		MOV A, #00000001B	; CLEAR LCD #01H
		ACALL COMMANDWRT
		ACALL DELAY
		
;PRINTING A STRING

		MOV DPTR, #STRINGDATA1
STRING1:	CLR A
		MOVC A, @A+DPTR
		ACALL DATAWRT
		ACALL DELAYMSG
		INC DPTR
		
		JNZ STRING1
		


ACALL PARKCHECK











JB P0.0, $ ;not read in hardware 			
		
		
		
	
	




MOV TMOD, #00010000B ;TIMER 1, MODE 1 - 16BIT MODE

MAIN:

JB P0.0, CON1

SJMP TURN_LEFT_90

CON1: 
CALL CENTER_POS
SJMP MAIN

TURN_LEFT_90:
ACALL CLEARMSG 	
SETB CSG

CALL LEFT_POS
		SJMP MAIN


;;;;;;;;;;;;;;;;;;SERVO POSITIONS;;;;;;;;;;;;;;;;;;;;;;

CENTER_POS:
; Position "0" (1.5 ms  pulse) is middle.
; High Part = 1.5ms
; 1.5ms / (1 / 11.0592 MHz) = 1.5 ms / 1.085 탎 = 1382
; 65536 - 1382 = 64154 Dec = FA9A Hex
; Low Part = 18.5ms
; 18.5ms / (1 / 11.0592 MHz) = 18.5 ms / 1.085 탎 = 17050
; 65536 - 17050 = 48486 Dec = BD66 Hex





	SETB P2.0
	MOV TL1, #0B2H	;LET THIS VALUE = 0B2 FOR A PRECISE CENTER ANGLE AS MUCH AS POSSIBLE
	MOV TH1, #0FAH   ;Puts it back to the center
	SETB TR1	; Run Timer

	CALL HIGH_SIGNAL
	
	MOV TL1, #66H
	MOV TH1, #0BDH   ;	Allow it to turn
	SETB TR1	; Run Timer

	CALL LOW_SIGNAL
JNB CSG,CONTINUE
	ACALL STR3WRT
CONTINUE:
	
	RET
	
LEFT_POS:
; Position "-90" (1 ms  pulse) is 90 degrees to the left.
; High Part = 1 ms
; 1 ms / (1 / 11.0592 MHz) = 1 ms / 1.085 탎 = 921
; 65536 - 921 = 64615 Dec = FC67 Hex
; Low Part = 19 ms
; 19 ms / (1 / 11.0592 MHz) = 19 ms / 1.085 탎 = 17511
; 65536 - 17511 = 48025 Dec = BB99 Hex
		ACALL CLEARMSG
		MOV DPTR, #STRINGDATA2
STRING2:	CLR A
		MOVC A, @A+DPTR	
		ACALL DATAWRT
		INC DPTR
		

		
		JNZ STRING2
		ACALL CLEARMSG


	
	MOV TL1, #7CH	;LET THIS VALUE = 7C FOR A PRECISE -90 ANGLE
	MOV TH1, #0FFH
	SETB TR1	; Run Timer

	CALL HIGH_SIGNAL
	
	MOV TL1, #99H
	MOV TH1, #0BBH
	SETB TR1	; Run Timer
	
	CALL LOW_SIGNAL
	

	 
	 

	
	RET		



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;TIMER OF SIGNALS;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
HIGH_SIGNAL:
	JNB TF1, $ 	;Wait till Timer overflow
	CLR TR1
	CLR P2.0	;HIGH TO LOW TRANSITION 
	CLR TF1
	RET
	
LOW_SIGNAL:
	JNB TF1, $ 	;Wait till Timer overflow
	CLR TR1
	SETB P2.0	;LOW TO HIGH TRANSITION 
	CLR TF1
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;COMMAND SUB-ROUTINE FOR LCD CONTROL
COMMANDWRT:

    MOV P1, A ;SEND DATA TO P1
	CLR RS	;RS=0 FOR COMMAND
	CLR RW	;R/W=0 FOR WRITE
	SETB E	;E=1 FOR HIGH PULSE
	ACALL DELAY ;SOME DELAY
	CLR E	;E=0 FOR H-L PULSE
	
	RET

;SUBROUTINE FOR DATA LACTCHING TO LCD
DATAWRT:

	MOV P1, A
    	SETB RS	;;RS=1 FOR DATA
    	CLR RW
    	SETB E
	ACALL DELAY
	CLR E
	
	RET
		


DELAY:
	MOV R0, #255
X:	MOV R1, #255
	DJNZ R1, $
	DJNZ R0, X
	RET
	
	
DELAYMSG:
 	MOV R0, #1
Y:	MOV R1, #1
	DJNZ R1, $
	DJNZ R0, Y
	RET
	
CLEARMSG: MOV A, #00000001B	; CLEAR LCD #01H
ACALL COMMANDWRT
ACALL DELAYMSG
RET

STR3WRT:
CLR CSG
MOV DPTR, #STRINGDATA3

STRING3:	CLR A
		MOVC A, @A+DPTR
		ACALL DATAWRT
		ACALL DELAYMSG
		INC DPTR
		
		
		JNZ STRING3
ACALL PARKCHECK

RET

STR4WRT:

MOV DPTR, #STRINGDATA4
STRING4:	CLR A
		MOVC A, @A+DPTR
		ACALL DATAWRT
		ACALL DELAYMSG
		INC DPTR
		
		
		JNZ STRING4

RET

STR5WRT:

MOV DPTR, #STRINGDATA5
STRING5:	CLR A
		MOVC A, @A+DPTR
		ACALL DATAWRT
		ACALL DELAYMSG
		INC DPTR
		
		
		JNZ STRING5

RET	



STR6WRT:

MOV DPTR, #STRINGDATA6
STRING6:	CLR A
		MOVC A, @A+DPTR
		ACALL DATAWRT
		ACALL DELAYMSG
		INC DPTR
		
		
		JNZ STRING6

RET


STR7WRT:
	MOV DPTR, #STRINGDATA7
	STRING7:	CLR A
		MOVC A, @A+DPTR
		ACALL DATAWRT
		ACALL DELAYMSG
		INC DPTR
		
		
		JNZ STRING7

RET

PARKCHECK:

MOV A,#0C0H ;Goes to the second line
ACALL COMMANDWRT

;0000 -> 0H
;0010 -> 2H
;0100 -> 4H
;0110 -> 6H
;1000 -> 8H
;1010 -> AH
;1100 -> CH
;1110 -> EH



MOV A,P0
ANL A,#00001110B


CJNE A,#0H,NEXT1 ;0000 000   0
ACALL STR4WRT
NEXT1:
CJNE A,#2H,NEXT2 ;0000 001   0
ACALL STR5WRT
NEXT2:
CJNE A,#4H,NEXT3 ;0000 010   0
ACALL STR5WRT
NEXT3:
CJNE A,#8H,NEXT4 ;0000 100   0
ACALL STR5WRT
NEXT4:
CJNE A,#6H,NEXT5 ;0000 011   0 
ACALL STR6WRT
NEXT5:
CJNE A,#0AH,NEXT6 ;0000 101   0
ACALL STR6WRT
NEXT6:
CJNE A,#0CH,NEXT7 ; 0000 110   0
ACALL STR6WRT
NEXT7:
CJNE A,#0EH,NEXT8 ; 0000 111  0
ACALL STR7WRT
NEXT8:

RET

ORG 300H

STRINGDATA1:	DB	"Welcome !!!" ,0 
STRINGDATA2:	DB	"Gate Opening " ,0
STRINGDATA3:	DB	"Gate Closed" ,0
STRINGDATA4:	DB	"Slots Left: 3" ,0
STRINGDATA5:	DB	"Slots Left: 2" ,0
STRINGDATA6:	DB	"Slots Left: 1" ,0
STRINGDATA7:	DB	"Slots Left: 0" ,0
	
	

	
	
	
END