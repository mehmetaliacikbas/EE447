;GPIO Registers
GPIO_PORTA_DEN 		EQU 0x4000451C 	; Port Direction
GPIO_PORTA_AFSEL	EQU 0x40004420 	; Alt Function enable
GPIO_PORTA_ODR	 	EQU 0x4000450C 	; Analog enable
GPIO_PORTA_PCTL 	EQU 0x4000452C 	; Alternate Functions

;I2C Registers
I2C1_MSA			EQU 0x40021000	; Slave address register
I2C1_MCS			EQU	0x40021004	; 
I2C1_MDR			EQU	0x40021008	; Data register
I2C1_MTPR			EQU 0x4002100C	; Rate register
I2C1_MCR			EQU 0x40021020	; Control register
	
;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCI2C	 	EQU 0x400FE620 ; GPIO Gate Control
	
;I2C Run Modes
START_WRITE			EQU	0x03	   ; Start condition with a byte write
STOP				EQU	0x05

;PA6 set as I2C1SCL
;PA7 set as I2C1SDA

;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
					
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT 	I2C_Init	;I2C1 Initialization
			EXPORT 	Write_I2C	;I2C1 a sample send SR
				
I2C_Init	PROC
			LDR R1, =SYSCTL_RCGCI2C ; start I2C Clock
			LDR R0, [R1]
			ORR R0, R0, #0x2 ; set bit 1 
			STR R0, [R1]

			LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x01 ; set bit 1
			STR R0, [R1]
			
			NOP
			NOP
			NOP
			NOP
			NOP

;GPIO Initialization

			LDR R1, =GPIO_PORTA_AFSEL ; Set as Alt function pin
			LDR R0, [R1]
			ORR R0, R0, #0xC0 ; set bit 7,6 for port A
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTA_ODR ; Set as open-drain
			LDR R0, [R1]
			ORR R0, R0, #0x80 ; set bit 7 for port A
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTA_DEN ; Enable digital pins
			LDR R0, [R1]
			ORR R0, R0, #0xC0 ; set bit 7,6 for port A
			STR R0, [R1]
			
			LDR R1, =GPIO_PORTA_PCTL ; Select function as I2C
			LDR R0, [R1]
			BIC	R0, R0, #0xFF000000
			ORR R0, R0, #0x33000000 ; write 0x3 to 31:28, 27:24 port A
			STR R0, [R1]
			
;I2C_Initialization		

			LDR R1, =I2C1_MCR ; Enable as master
			MOV R0, #0x10 ; set bit 4
			STR R0, [R1]
			
			LDR R1, =I2C1_MTPR ; Set speed as 400 Kbps
			MOV R0, #0x01 ; set bit 0
			STR R0, [R1]
			
			BX	LR			
			ENDP
					
Write_I2C	PROC
			PUSH {LR}
			PUSH {R0-R2}
			LDRB R2, [R10], #0x1	; Read a sample from memory pointed by R10
			
			LDR R1, =I2C1_MSA 		; Set slave address
			MOV R0, #0xC4 			; DEV_ID = 0x62 || R/W = 0x0
			STR R0, [R1]
			
			LDR R1, =I2C1_MDR 		; Set first byte
			MOV	R0, #0x0			; Most significant 1 hex is sent
			STR R0, [R1]			
			
			LDR R1, =I2C1_MCS 		; Transmission starts and first byte send 
			LDR R0, =START_WRITE 	; Start = 0x4
			STR R0, [R1]	
			
I2Cloop1	LDR R1, =I2C1_MCS 		; Busy bit checked for end of transmission
			LDR	R0, [R1]
			ANDS R0, R0, #0x1
			BNE	I2Cloop1
			
			LDR R1, =I2C1_MDR 		; Set second byte
			AND R0, R2, #0xFF 		; Least significant 1 hex is sent
			STR R0, [R1]		
			
			LDR R1, =I2C1_MCS 		; Second byte starts and transmission stops
			MOV R0, #STOP			; STOP = 0x5
			STR R0, [R1]
			
I2Cloop2	LDR R1, =I2C1_MCS 		; Busy bit checked
			LDR	R0, [R1]
			ANDS R0, R0, #0x1
			BNE	I2Cloop2
			
			POP	{R0-R2}
			POP	{LR}
			BX	LR					; A sample is sent to DAC returning from SR
			
			ENDP
			ALIGN
			END