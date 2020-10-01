;********************************************************************
;	100 msec delay is adjusted by using clock period and a number of
;instructions. Frequency of microprocessor is 16MHz then period is 62.5
;nsec. Then the amount of instructions to be used is calculated as 
;100msec/62.5nsec = 1,600,00 instruction. its done by using a loop that
;has 10 instruction and called 160,000 times. By the way ADD, CMP, BEQ,
;B and NOP instructions takes one clock per instruction.
;********************************************************************
M100SEC	EQU			160000
;LABEL	DIRECTIVE	VALUE 					COMMENT
		AREA     	|.text| , READONLY, CODE
		THUMB
		EXPORT 		d100ms
			
d100ms  PROC	
		PUSH	{LR}
		PUSH	{R0-R1}
		LDR		R1,=M100SEC
loop	ADD		R0,R0,#0x1 				;#1
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		CMP		R0,R1
		BEQ		return
		B		loop					;#10
return  POP		{R0-R1}
		POP		{LR}
		BX		LR
		ALIGN
		ENDP		
	    END