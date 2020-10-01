;Timer2 Registers
TIMER2_CFG			EQU 0x40032000
TIMER2_TAMR 		EQU	0x40032004
TIMER2_CTL			EQU	0x4003200C
TIMER2_IMR			EQU 0x40032018
TIMER2_RIS			EQU 0x4003201C
TIMER2_MIS			EQU 0x40032020
TIMER2_ICR			EQU 0x40032024
TIMER2_TAILR		EQU 0x40032028
TIMER2_TAR			EQU 0x40032048
TIMER2_TAV			EQU 0x40032050	
	
;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPIO Gate Control
NVICINT0			EQU 0xE000E100 ;0-31

MEMORY_START		EQU 0x20000500
MEMORY_END			EQU 0x20007FF0 ;0x200062C0
	
;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	Timer2_Init			; Timer2 initialization
			EXPORT	Timer2_Run			; Timer2 starts to play recorded sound
			EXPORT	TM2_Handler			; Play subroutine
			IMPORT	Write_I2C			; Send a sample to the DAC
			IMPORT  ADC_Sample			; Get a reading from ADC in order to change the period of timer2
				
Timer2_Init	PROC
			LDR R1, =SYSCTL_RCGCTIMER 	; start timer Clock
			LDR R0, [R1]
			ORR R0, R0, #0x4 			; set bit 2
			STR R0, [R1]

			LDR R1, =NVICINT0 			; Enable interrupt for timer2
			LDR R0, [R1]
			ORR R0, R0, #0x800000 		; set bit 23
			STR R0, [R1]
			
			NOP
			NOP
			NOP
			NOP
			NOP

			LDR R1, =TIMER2_CTL ; Stop timer
			LDR	R0, [R1]
			BIC R0, R0, #0x1 ; clear bit 0
			STR R0, [R1]
			
			LDR R1, =TIMER2_CTL ; Set stall timer
			LDR	R0, [R1]
			ORR R0, R0, #0x2 ; set bit 1
			STR R0, [R1]

			LDR R1, =TIMER2_CFG ; Set 16 bit
			MOV R0, #0x4 ; set bit 2
			STR R0, [R1]
			
			LDR R1, =TIMER2_TAMR ; Set periodic down counter
			MOV R0, #0x2 ; set bit 1
			STR R0, [R1]
			
			LDR R1, =TIMER2_TAILR ; Set frequency to 10 kHz for initial sampling rate
			MOV R0, #2000 ; set 2000 clock as period
			STR R0, [R1]
			
			LDR R1, =TIMER2_IMR ; Set interrupt mask for timeout
			LDR R0, [R1]
			ORR R0, R0, #0x1 ; set bit 0
			STR R0, [R1]
			BX	LR			
			ENDP
				
Timer2_Run	PROC
			PUSH {R0-R1}
			
			LDR	R10, =MEMORY_START
			
			LDR R1, =TIMER2_CTL ; Start timer
			LDR	R0, [R1]
			ORR R0, R0, #0x1 ; set bit 0
			STR R0, [R1]
			
			POP	{R0-R1}
			BX	LR
			ENDP
				
TM2_Handler PROC
			PUSH {LR}
			
			LDR R1, =TIMER2_ICR ;Cleat interrupt 
			LDR	R0, [R1]
			MOV R0, #0x1 ; clear bit 0
			STR R0, [R1]
			
			BL	ADC_Sample ;Get a sample from ADC and map it according to 2-10 kHz
			
			LDR R1, =TIMER2_CTL ; Stop timer
			LDR	R0, [R1]
			BIC R0, R0, #0x1 ; clear bit 0
			STR R0, [R1]
			
			LDR R1, =TIMER2_TAILR ; Set the timer period
			STR R8, [R1] ; R8 is set by ADC_Sample subroutine
			
			LDR R1, =TIMER2_CTL ; Start timer
			LDR	R0, [R1]
			ORR R0, R0, #0x1 ; set bit 0
			STR R0, [R1]
			
			BL	Write_I2C ;Send a sample from memory pointed by R10
			
			LDR	R0, =MEMORY_END
			CMP	R0, R10	;Compare if memory pointer reached to end
			BNE not_fin	;If not reached return from subroutine
						;Else
			LDR R1, =TIMER2_CTL ; Stop timer
			LDR	R0, [R1]
			BIC R0, R0, #0x1 ; clear bit 0
			STR R0, [R1]
			
			LDR R10, =MEMORY_START ;Refresh memory pointer to the initial byte
			MOV	R6, #0x5 ;Set R6 to a different value other than 0x0 to let flow in the main
			
not_fin		POP	{LR}
			BX	LR
			ENDP					

			ALIGN
			END