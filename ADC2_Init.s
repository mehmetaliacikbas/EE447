;GPIO Registers
GPIO_PORTE_DIR 		EQU 0x40024400 ; Port Direction
GPIO_PORTE_AFSEL	EQU 0x40024420 ; Alt Function enable
GPIO_PORTE_AMSEL 	EQU 0x40024528 ; Analog enable
GPIO_PORTE_PCTL 	EQU 0x4002452C ; Alternate Functions
	
;Timer2 Registers
ADC1_ACTSS			EQU 0x40039000
ADC1_EMUX 			EQU	0x40039014
ADC1_TSSEL			EQU	0x4003901C
ADC1_SSMUX3			EQU 0x400390A0
ADC1_SSCTL3			EQU 0x400390A4
ADC1_CTL			EQU 0x40039038
ADC1_PC				EQU 0x40039FC4
ADC1_RIS			EQU 0x40039004
ADC1_SSFIFO3		EQU 0x400390A8
ADC1_ISC			EQU	0x4003900C
ADC1_PSSI			EQU 0x40039028
	
;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCADC	 	EQU 0x400FE638 ; GPIO Gate Control
	
OFFSET				EQU	0x640
	
;PB0 set as timer2

;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	ADC2_Init
			EXPORT	ADC_Sample
				
ADC2_Init	PROC
			LDR R1, =SYSCTL_RCGCADC ; start timer Clock
			LDR R0, [R1]
			ORR R0, R0, #0x2 
			STR R0, [R1]

			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x10 
			STR R0, [R1]	
			
			NOP
			NOP
			NOP
			NOP
;GPIO_Init
			LDR R1, =GPIO_PORTE_AFSEL ; Alternative function
			LDR R0, [R1]
			ORR R0, R0, #0x4
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTE_PCTL ; Default alternate function
			LDR R0, [R1]
			BIC R0, R0, #0x0000F00
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTE_DIR ; set direction of PE3
			LDR R0, [R1]
			BIC R0, R0, #0x4 ; clear bit 4 for input
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTE_AMSEL ; enable analog
			LDR	R0, [R1]
			ORR R0, R0, #0x4
			STR R0, [R1]
;ADC_Init
			LDR R1, =ADC1_ACTSS; Disable sampler
			LDR R0, [R1]
			BIC R0, R0, #0x8 ; clear bit 3 
			STR R0, [R1]			

			LDR R1, =ADC1_EMUX ; Trigger source selected
			LDR R0, [R1]
			BIC R0, R0, #0xF000 ; clear bit 4 for input
			STR R0, [R1]
			
			LDR R1, =ADC1_SSMUX3 ; Set input port
			LDR R0, [R1]
			BIC R0, R0, #0xF ; clear bit 4 for input
			ORR R0, R0, #0x1
			STR R0, [R1]
			
			LDR R1, =ADC1_SSCTL3 ; set interrupt and single sampling
			LDR R0, [R1]
			ORR R0, R0, #0x6 ; set bit 1 and bit 2
			STR R0, [R1]
			
			LDR R1, =ADC1_PC ; set sampling rate
			LDR R0, [R1]
			ORR R0, R0, #0x7 ; set 0x7 for 1Msps
			STR R0, [R1]
			
			LDR R1, =ADC1_ACTSS; Enable sampler 3
			LDR R0, [R1]
			ORR R0, R0, #0x8 ; set bit 3 
			STR R0, [R1]
			BX	LR
			ENDP
ADC_Sample	PROC
	
			LDR R1, =ADC1_PSSI
			LDR	R0, [R1]
			ORR R0, R0, #0x8
			STR	R0, [R1]
			
			LDR	R1, =ADC1_RIS
poll		LDR	R0, [R1]
			ANDS R0, R0, #0x8
			BEQ	poll
			
			LDR	R1, =ADC1_SSFIFO3
			LDR	R8, [R1]
			ADD R0, R8, R8
			ADD R8, R0, R8
			MOV R8, R8, LSR #0x1
			ADD R8, R8, #OFFSET
			
			
			LDR	R1, =ADC1_ISC
			MOV	R0, #0x8
			STR	R0, [R1]
			
			BX	LR
			ENDP
				
			ALIGN
			END