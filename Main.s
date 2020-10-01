;***************************************************************
; Program section
;***************************************************************
;LABEL		DIRECTIVE	VALUE			COMMENT
            AREA 		main, READONLY, CODE
            THUMB

            EXPORT 		__main
			IMPORT		I2C_Init
			IMPORT		Timer2_Init
			IMPORT		ADC_Init
			IMPORT		Timer3_Init
			IMPORT		Timer2_Run
			IMPORT		Timer3_Run
			IMPORT		CLK_Init
			IMPORT 		ADC2_Init
			IMPORT 		ADC_Sample
			IMPORT 		BUTT_INIT
			IMPORT 		buttright
			IMPORT 		buttleft
			IMPORT 		LED_INIT
			IMPORT		RLEDON
			IMPORT		GLEDON
			IMPORT		BLEDON

__main		
			BL			CLK_Init	;Clock Initialization
			BL			BUTT_INIT	;Button initialization
			BL			LED_INIT	;Led Initialization
			BL			Timer2_Init	;Timer 2 Initialization(Playing)
			BL			Timer3_Init	;Timer 3 Initialization(Sampling)
			BL			I2C_Init	;I2C Initialization
			BL			ADC_Init	;ADC0 Initialization(Sampling)
			BL			ADC2_Init	;ADC1 Initialization(Play rate setting)
			
			BL			BLEDON		;Blue led lights
			BL			buttleft	;Check for left button pressed, after pressed it returns
			BL			RLEDON		;Red led lights 
			MOV			R6, #0x0	;Used for waiting until sampling ends
			MOV			R7, #0x0	;Used for waiting until sampling ends
			BL			Timer3_Run	;Start sampling
cmplt1		CMP			R6,R7		;Check for R6 changed or not
			BEQ			cmplt1		;Loop until R6 changes
			BL			BLEDON		;Blue led lights
			BL			buttright	;Check for rigth button pressed, after pressed it returns
			BL			GLEDON		;Green led lights
loop		BL			Timer2_Run	;Start play
			MOV			R6, #0x0	;Set R6 to 0 for check whether play operation ends
			MOV			R7, #0x0	;Set R7 to 0 for check whether play operation ends
cmplt2		CMP			R6,R7		;Check for R6 changed or not
			BEQ			cmplt2		;Loop until R6 changes
			B			loop		;Replay
done    	WFI 								; Infinite loop to
			B 			done 					; end program
			ALIGN
			END