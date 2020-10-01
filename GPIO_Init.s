BUTTON_L         EQU 0x40025040
BUTTON_R         EQU 0x40025004
RBG_LED          EQU 0x40025038
GPIO_PORTF_DIR   EQU 0x40025400
GPIO_PORTF_AFSEL EQU 0x40025420
GPIO_PORTF_DEN   EQU 0x4002551C
GPIO_PORTF_PUR   EQU 0x40025510
GPIO_PORTF_LOCK  EQU 0x40025520
GPIO_PORTF_CR    EQU 0x40025524
SYSCTL_RCGCGPIO  EQU 0x400FE608

LOCK			 EQU 0x4C4F434B

LED_GREEN        EQU 0x8
LED_BLUE         EQU 0x4
LED_RED          EQU 0x2
BUTTLEFT         EQU 0x10
BUTTRIGHT        EQU 0x1
;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	BUTT_INIT
			EXPORT 	buttright
			EXPORT 	buttleft
			IMPORT  d100ms

BUTT_INIT 	PROC
			LDR R1, =SYSCTL_RCGCGPIO
			LDR R0, [R1]
			ORR R0, R0, #0x20
			STR R0, [R1]

			NOP
			NOP
			NOP 
			
			LDR R1, =GPIO_PORTF_LOCK
			LDR R0, =LOCK ;unlock GPIO Port F
			STR R0, [R1]

			LDR R1, =GPIO_PORTF_CR
			MOV R0, #0x1F; allow changes to PF4-0
			STR R0, [R1]

			LDR R1, =GPIO_PORTF_DIR
			LDR R0, [R1]
			BIC R0, R0, #0x11
			STR R0, [R1]

			LDR R1, =GPIO_PORTF_AFSEL
			LDR R0, [R1]
			BIC R0, R0, #0x11
			STR R0, [R1]

			LDR R1, =GPIO_PORTF_PUR
			LDR R0, [R1]
			ORR R0, R0, #0x11
			STR R0, [R1]

			LDR R1, =GPIO_PORTF_DEN
			LDR R0, [R1]
			ORR R0, R0, #0x11
			STR R0, [R1]
			BX	LR
			ENDP

buttleft 	PROC
			PUSH {LR}
		
loopL		LDR R1, =BUTTON_L
			LDR R0, [R1]
			ANDS R0, R0, #BUTTLEFT         
			BNE  loopL
		
			BL d100ms
		

			LDR R1, =BUTTON_L
			LDR R0, [R1]
			ANDS R0, R0, #BUTTLEFT         
			BNE  loopL

loopL2		LDR R1, =BUTTON_L
			LDR R0, [R1]
			ANDS R0, R0, #BUTTLEFT         
			BEQ  loopL2
		
			BL d100ms
		

			LDR R1, =BUTTON_L
			LDR R0, [R1]
			ANDS R0, R0, #BUTTLEFT         
			BEQ  loopL2
			
			POP	{LR}
			BX LR
			ENDP

buttright 	PROC
			PUSH {LR}
		
loopR		LDR R1, =BUTTON_R
			LDR R0, [R1]
			ANDS R0, R0, #BUTTRIGHT 
			BNE  loopR

			BL d100ms

			LDR R1, =BUTTON_R
			LDR R0, [R1]
			ANDS R0, R0, #BUTTRIGHT 
			BNE  loopR
			
loopR2		LDR R1, =BUTTON_R
			LDR R0, [R1]
			ANDS R0, R0, #BUTTRIGHT 
			BEQ  loopR2

			BL d100ms

			LDR R1, =BUTTON_R
			LDR R0, [R1]
			ANDS R0, R0, #BUTTRIGHT 
			BEQ  loopR2

			POP	{LR}
			BX LR
			ENDP
			ALIGN
			END