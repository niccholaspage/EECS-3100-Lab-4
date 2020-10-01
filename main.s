;*******************************************************************
; main.s
; Author: Nicholas Nassar
; Date Created: 09/24/2020
; Last Modified: 09/24/2020
; Section Number: 002
; Instructor: Devinder Kaur
; Lab number: 4
; This program emulates an interactive alarm. When the switch is pressed,
; the LED output will go on and off just like an alarm. Otherwise, the LED
; output will be off.
; The overall objective of this system is an interactive alarm
; Hardware connections
;   PF4 is switch input  (1 = switch not pressed, 0 = switch pressed)
;   PF3 is LED output    (1 activates green LED) 
; The specific operation of this system 
;   1) Make PF3 an output and make PF4 an input (enable PUR for PF4). 
;   2) The system starts with the LED OFF (make PF3 =0). 
;   3) Delay for about 100 ms
;   4) If the switch is pressed (PF4 is 0),
;      then toggle the LED once, else turn the LED OFF. 
;   5) Repeat steps 3 and 4 over and over
;*******************************************************************

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
GPIO_PORTF_LOCK_R  	    EQU   0x40025520
GPIO_PORTF_CR_R         EQU   0x40025524

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
InitPortF
	; SYSCTL_RCGCGPIO_R = 0x20
	MOV R0, #0x20
	LDR R1, =SYSCTL_RCGCGPIO_R
	STR R0, [R1]
	
	LDR R0, [R1] ; Delay before continuing

	; Before writing to the CR register,
	; we must first unlock Port F.
	; Since we can't write a 32-bit constant
	; directly, we use MOV & MOVT together to
	; do it in two 16-bit parts.
	; GPIO_PORTF_LOCK_R = 0x4C4F434B
	MOV R0, #0x434B
	MOVT R0, #0x4C4F
	LDR R1, =GPIO_PORTF_LOCK_R
	STR R0, [R1]

	; GPIO_PORTF_CR_R = 0x18
	MOV R0, #0x18
	LDR R1, =GPIO_PORTF_CR_R
	STR R0, [R1]

	; GPIO_PORTF_AMSEL_R = 0x00
	MOV R0, #0x00
	LDR R1, =GPIO_PORTF_AMSEL_R
	STR R0, [R1]
	
	; GPIO_PORTF_PCTL_R = 0x00
	MOV R0, #0x00
	LDR R1, =GPIO_PORTF_PCTL_R
	STR R0, [R1]

	; GPIO_PORTF_DIR_R = 0x08
	MOV R0, #0x08
	LDR R1, =GPIO_PORTF_DIR_R
	STR R0, [R1]

	; GPIO_PORTF_AFSEL_R = 0x00
	MOV R0, #0x00
	LDR R1, =GPIO_PORTF_AFSEL_R
	STR R0, [R1]

	; GPIO_PORTF_PUR_R = 0x10
	MOV R0, #0x10
	LDR R1, =GPIO_PORTF_PUR_R
	STR R0, [R1]

	; GPIO_PORTF_DEN_R = 0x18
	MOV R0, #0x18
	LDR R1, =GPIO_PORTF_DEN_R
	STR R0, [R1]
main
	; No initialization necessary
loop
	; Read switch and test if switch is pressed
	; If switch is pressed (PF4 == 0) toggle PF3 else clear PF3 so LED is off
	LDR R1, =GPIO_PORTF_DATA_R ; Load the address of Port F data into R1
	LDR R0, [R1] ; Load the value at the address in R1 into R0
	LSR R0, #4 ; Shift the register 4 bits to the right, since we only care about pin 4
	CBZ R0, toggle_led
	; Turn off the LED, since the switch is not pressed
	MOV R0, #0x00
	LDR R1, =GPIO_PORTF_DATA_R
	STR R0, [R1]
	B loop
toggle_led ; Toggles the LED
	; Read Port F data so we can check if LED is on or not
	LDR R1, =GPIO_PORTF_DATA_R
	LDR R0, [R1] ; Load the value at the address in R1 into R0
	LSR R0, #3 ; Shift the register 3 bits to the right, since we only care about pin 3
	CBZ R0, turn_on_led ; If the LED is off, then we turn it on
	; Turn off the LED
	MOV R0, #0x00
	LDR R1, =GPIO_PORTF_DATA_R
	STR R0, [R1]
	BL Delay100ms ; Delay 100 ms
	B loop ; Loop again
turn_on_led
	; Turns on the LED
	MOV R0, #0x08
	LDR R1, =GPIO_PORTF_DATA_R
	STR R0, [R1]
	BL Delay100ms ; Delay 100 ms
	B    loop ; Loop again

; A subroutine that delays for 100 ms then returns to the original line
Delay100ms
	MOV R12, #0x0000 ; set R12 to our big number to get us our 100 ms delay
	MOVT R12, #0x7
WaitForDelay
	SUBS R12, R12, #0x01
	BNE WaitForDelay
	BX LR


	ALIGN      ; make sure the end of this section is aligned
	END        ; end of file
       