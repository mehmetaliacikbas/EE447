;Timer3 Registers
TIMER3_CFG			EQU 0x40033000
TIMER3_TAMR 		EQU	0x40033004
TIMER3_CTL			EQU	0x4003300C
TIMER3_IMR			EQU 0x40033018
TIMER3_RIS			EQU 0x4003301C
TIMER3_MIS			EQU 0x40033020
TIMER3_ICR			EQU 0x40033024
TIMER3_TAILR		EQU 0x40033028
TIMER3_TAR			EQU 0x40033048
TIMER3_TAV			EQU 0x40033050	
	
;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPIO Gate Control
NVICINT1			EQU 0xE000E104 ;32-63

MEMORY_START		EQU	0x20000500
MEMORY_END			EQU 0x20007FF0 ;0x200062C0
	
MERABALAR			EQU	0x200003db

;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	Timer3_Init
			EXPORT	Timer3_Run
			EXPORT 	TM3_Handler
			IMPORT	ADC_Store
				
Timer3_Init	PROC
			LDR R1, =SYSCTL_RCGCTIMER ; start timer Clock
			LDR R0, [R1]
			ORR R0, R0, #0x8 ; set bit 2,3
			STR R0, [R1]

			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x2 ; set bit 1
			STR R0, [R1]
			
			LDR R1, =NVICINT1 ; Enable interrupt for timer3
			LDR R0, [R1]
			ORR R0, R0, #0x8; set bit 3
			STR R0, [R1]
			
			NOP
			NOP
			NOP
			NOP
			NOP

			LDR R1, =TIMER3_CTL ; Stop timer
			LDR	R0, [R1]
			BIC R0, R0, #0x1 ; clear bit 0
			STR R0, [R1]
			
			LDR R1, =TIMER3_CTL ; Stop timer
			LDR	R0, [R1]
			ORR R0, R0, #0x22 ; 
			STR R0, [R1]

			LDR R1, =TIMER3_CFG ; Set 16 bit
			MOV R0, #0x4 ; set 0x4
			STR R0, [R1]
			
			LDR R1, =TIMER3_TAMR ; Set periodic down counter
			MOV R0, #0x2 ; set 0x1 for I2C 1
			STR R0, [R1]
			
			LDR R1, =TIMER3_TAILR ; Set frequency to 8KHz
			MOV R0, #2500 ; set 2500 clock as period
			STR R0, [R1]
			
			LDR R1, =TIMER3_IMR ; Set interrupt mask for timeout
			LDR R0, [R1]
			ORR R0, R0, #0x1 ; set bit 0
			STR R0, [R1]
			BX	LR			
			ENDP
				
Timer3_Run	PROC
			PUSH {R0-R1}
			
			LDR	R10, =MEMORY_START ; Initial value of memory is loaded to memory pointer
			
			LDR R1, =TIMER3_CTL ; Start timer
			LDR	R0, [R1]
			ORR R0, R0, #0x1 ; set bit 0
			STR R0, [R1]
			
			POP	{R0-R1}
			BX	LR
			ENDP
				
TM3_Handler PROC
			PUSH {LR}
			
			LDR R1, =TIMER3_ICR ; Stop timer
			LDR	R0, [R1]
			MOV R0, #0x1 ; clear bit 0
			STR R0, [R1]
			
			BL	ADC_Store 
			
			LDR	R0, =MEMORY_END
			CMP	R0, R10
			BNE not_fin
			
			LDR R1, =TIMER3_CTL ; Stop timer
			LDR	R0, [R1]
			BIC R0, R0, #0x1 ; clear bit 0
			STR R0, [R1]
			
			MOV	R6, #0x5 ;End record
			
			LDR R10, =MEMORY_START
			
not_fin		POP	{LR}
			BX	LR
			ENDP

			ALIGN
			END