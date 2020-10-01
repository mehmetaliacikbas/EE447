;GPIO Registers
GPIO_PORTE_DIR 		EQU 0x40024400 ; Port Direction
GPIO_PORTE_AFSEL	EQU 0x40024420 ; Alt Function enable
GPIO_PORTE_AMSEL 	EQU 0x40024528 ; Analog enable
GPIO_PORTE_PCTL 	EQU 0x4002452C ; Alternate Functions
	
;Timer2 Registers
ADC0_ACTSS			EQU 0x40038000
ADC0_EMUX 			EQU	0x40038014
ADC0_TSSEL			EQU	0x4003801C
ADC0_SSMUX3			EQU 0x400380A0
ADC0_SSCTL3			EQU 0x400380A4
ADC0_CTL			EQU 0x40038038
ADC0_PC				EQU 0x40038FC4
ADC0_RIS			EQU 0x40038004
ADC0_SSFIFO3		EQU 0x400380A8
ADC0_ISC			EQU	0x4003800C
	
;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCADC	 	EQU 0x400FE638 ; GPIO Gate Control
	
;PB0 set as timer2

;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	ADC_Init
			EXPORT	ADC_Store
				
ADC_Init	PROC
			LDR R1, =SYSCTL_RCGCADC ; start timer Clock
			LDR R0, [R1]
			ORR R0, R0, #0x1 ; set bit 2,3
			STR R0, [R1]

			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x10 ; set bit 1
			STR R0, [R1]	
			
			NOP
			NOP
			NOP
			NOP
;GPIO_Init
			LDR R1, =GPIO_PORTE_AFSEL ; Alternative function
			LDR R0, [R1]
			ORR R0, R0, #0x8
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTE_PCTL ; Default alternate function
			LDR R0, [R1]
			BIC R0, R0, #0x000F000
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTE_DIR ; set direction of PE3
			LDR R0, [R1]
			BIC R0, R0, #0x8 ; clear bit 4 for input
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTE_AMSEL ; enable analog
			LDR	R0, [R1]
			ORR R0, R0, #0x8
			STR R0, [R1]
;ADC_Init
			LDR R1, =ADC0_ACTSS; Disable sampler
			LDR R0, [R1]
			BIC R0, R0, #0x8 ; clear bit 3 
			STR R0, [R1]			

			LDR R1, =ADC0_EMUX ; Trigger source selected
			LDR R0, [R1]
			BIC R0, R0, #0xF000 ; clear bit 4 for input
			ORR R0, R0, #0x5000 ; set 0x5 for timer
			STR R0, [R1]
			
			LDR R1, =ADC0_SSMUX3 ; Set input port
			LDR R0, [R1]
			BIC R0, R0, #0xF ; clear bit 4 for input
			STR R0, [R1]
			
			LDR R1, =ADC0_SSCTL3 ; set interrupt and single sampling
			LDR R0, [R1]
			ORR R0, R0, #0x6 ; set bit 1 and bit 2
			STR R0, [R1]
			
			LDR R1, =ADC0_PC ; set sampling rate
			LDR R0, [R1]
			ORR R0, R0, #0x7 ; set 0x7 for 1Msps
			STR R0, [R1]
			
			LDR R1, =ADC0_ACTSS; Enable sampler 3
			LDR R0, [R1]
			ORR R0, R0, #0x8 ; set bit 3 
			STR R0, [R1]
			BX	LR
			ENDP
ADC_Store	PROC
			
			LDR	R1, =ADC0_RIS
poll		LDR	R0, [R1]
			ANDS R0, R0, #0x8
			BEQ	poll
			
			LDR	R1, =ADC0_SSFIFO3
			LDR	R0, [R1]
			MOV	R0, R0, LSR #0x4
			STRB R0, [R10], #0x1
			
			LDR	R1, =ADC0_ISC
			MOV	R0, #0x8
			STR	R0, [R1]
			
			BX	LR
			ENDP
				
			ALIGN
			END