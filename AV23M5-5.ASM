; *****************************************************
; *    V23 MODEM ANALOGUE MODULATOR (8035) SOFTWARE   *
; *****************************************************

;       DATE CREATE :           14.01.92  11:55 AM
;       LAST EDIT :             01.10.92  02:08 PM
;       VERSION :               1.05

; *****************************************************

        WIDTH   80

NBIT    EQU     29      ; R5 OF RB1 ADRESS

SV1     EQU     31H     ; "1" FRQ. PARAMETERS
SV0     EQU     34H     ; "0" FRQ. PARAMETERS
STOPBIT EQU     37H     ; NUMBER OF TRANSMITED STOP BITS
BUFBIT  EQU     38H     ; TRANSMIT BUFFER

        ORG     0000H

        ENT0    CLK
        JMP     START

        ORG     0007H

        ; ---------------------------------------------
        ;    INTERRUPTION VECTOR OF TIMER COUNTER
        ;    R5 OF RB1  -  NUMBER OF TRANSMITED BITS
        ;    R7 OF RB1  -  POSITION OF ACCUMULATOR
        ;          FORMAT OF TRANSMITION :
        ;    START BIT + BYTE + STOP BIT IN BUFBIT
        ; ---------------------------------------------

INTTIM: SEL     RB1
        MOV     R7,A            ; R7 OF RB1 = ACC
        MOV     A,R5
        JZ      IT              ; NO BYTE TO TRANSMIT
        JMP     INTTIM1         ; ENTER BYTE

IT:     MOV     A,R7            ; RESTORE ACCUMULATOR
        RETR                    ; *** END INTTIM  ***

        ; BYTE INPUT PROCEDURE
INTTIM1:
        MOV     R0,#BUFBIT
        MOV     A,@R0
        RRC     A
        MOV     @R0,A
        INC     R0              ; R0 = BUFBIT+1
        MOV     A,@R0
        RRC     A
        MOV     @R0,A
        JC      INTTIM2         ; CY <=> BIT FOR TRANSMITION
        CLR     F0
        JMP     INTTIM3
INTTIM2:
        CLR     F0
        CPL     F0
INTTIM3:
        CALL    PARTIM

        DEC     R5
        MOV     A,R7
        RETR

; *****************************************************
; *             MODULE OF TRANSMITION                 *
; *****************************************************

                ORG     100H

        ; ---------------------------------------------
        ; PROCESSING OF TRANSMITION PARAMETERS OF TIMER
        ; ---------------------------------------------
PARTIM:
        JF0     SC1     ; FOR "1" POINTER TO SV1
        MOV     R0,#SV0
        JMP     SC2
SC1:    MOV     R0,#SV1

        ; TIMER INITIALISATION

SC2:    ANL     P2,#11001111B   ; CHAN. TIM2
        ORL     P2,#00100000B
        MOV     A,@R0
        OUTL    BUS,A           ; LOW BYTE TO TIM2
        INC     R0
        MOV     A,@R0
        OUTL    BUS,A           ; HIGH BYTE TO TIM2
        INC     R0
        MOV     A,@R0           ; NUMBER OF PERIODES
        CPL     A               ; TO 8035-CPU TIMER
        INC     A               ; IN INVERTED CODE
        MOV     T,A
        RET

; -----------------------------------------------------

START:  SEL     RB0

        ; ENTERING OF TRANSMITION PARAMETERS
        ; 8253 TIMER INITIALISATION:  P2.4=A0
        ;                             P2.5=A1

; ---------- RECIVE INITIALISATION --------------------

; 1 PAR.
        ORL     P2,#00110000B   ; TIMPSW A0=1 A1=1
        CALL    INCENTR         ; PSW OF TIMER CHAN.-0
        OUTL    BUS,A           ;
; 2 PAR.

        ANL     P2,#11001111B   ; TIM0
        CALL    INCENTR         ; LOW BYTE OF FRQ.
        OUTL    BUS,A
; 3 PAR.
        CALL    INCENTR         ; HIGH BYTE OF FRQ.
        OUTL    BUS,A
; 4 PAR.
        ORL     P2,#00110000B   ; TIMPSW  A0=1 A1=1
        CALL    INCENTR         ; PSW OF TIMER CHAN.-1
        OUTL    BUS,A
; 5 PAR
        ANL     P2,#11101111B   ; TIM1
        ORL     P2,#00100000B
        CALL    INCENTR         ; LOW BYTE OF FRQ.
        OUTL    BUS,A
; 6 PAR.
        CALL    INCENTR         ; HIGH BYTE OF FRQ.
        OUTL    BUS,A

; -------------- TRANSMIT INITIALISATION --------------

; 7 PAR.
        MOV     R0,#SV1
        CALL    INCENTR         ; LOW BYTE OF FRQ. OF "1"
        MOV     @R0,A

; ----------------------------------------------------

        ANL     P1,#11111101B   ; P1.1=0 - DISCONNECTION
                                ; OF PARALLEL TELEPHONE
; ---------------------------------------------------

; 8 PAR.
        INC     R0
        CALL    INCENTR         ; HIGH BYTE OF FRQ. OF "1"
        MOV     @R0,A
; 9 PAR.
        MOV     R0,#SV0         ; POINTER ON SV0
        CALL    INCENTR         ; LOW BYTE OF FRQ. OF "0"
        MOV     @R0,A
; 10 PAR.
        INC     R0
        CALL    INCENTR         ; HIGH BYTE OF FRQ. OF "0"
        MOV     @R0,A
; 11 PAR.
        MOV     R0,#SV1+2       ; NUMBER OF "1" PERIODES
        CALL    INCENTR
        MOV     @R0,A
; 12 PAR.
        MOV     R0,#SV0+2       ; NUMBER OF "0" PERIODES
        CALL    INCENTR
        MOV     @R0,A
; 13 PAR.
        MOV     R0,#STOPBIT     ; NUMBER OF STOP BITS
        CALL    INCENTR         ; 0 -> 1 STOP BIT
                                ; 1 -> 2 STOP BITS
        INC     A
        MOV     @R0,A

        ; TRANSMITION TIMER INITIALISATION
        ; AND ENABLE OF WR SIGNAL

        ORL     P2,#00110000B
        MOV     A,#10110110B    ; MODE 3 TO CHAN.-2
        OUTL    BUS,A

        CLR     F0
        CPL     F0              ; STOP BIT TRANSMITION
        CALL    PARTIM

        ; ENABLE OF TRANSMITION

        ANL     P1,#11111110B   ; P1.0="0"
        ORL     P1,#00000001B   ; P1.0="1"

        ; CHECK OF TRANSMITION BYTE

BL3:    ORL     P2,#10000000B   ; SET P2.7 FOR INPUT
        IN      A,P2
        JB7     BL3             ; WAIT FOR BYTE TO TRANSMIT

BL31:   INS     A,BUS           ; GET BYTE FOR TRANSMITION
        MOV     R0,#BUFBIT+1    ; POINTER ON BUFFER
        XCH     A,@R0           ; STORE BYTE IN BUFFER
        DEC     R0
        MOV     @R0,#0FFH       ; SET 1 POSITION
        INC     R0
        CLR     C               ; CY=0
        XCH     A,@R0
        RLC     A
        XCH     A,@R0
        DEC     R0
        XCH     A,@R0
        RLC     A
        XCH     A,@R0           ; BUFFER IS READY TO TRANSMIT
                                ; BUFBIT   =  1111111*
                                ; BUFBIT+1 =  *******0
        ; SET READY CONDITION

        ANL     P2,#10111111B   ; P2.6=0
        ORL     P2,#01000000B   ; P2.6=1

        ; ---------------------------------------------
        ; TRANSMITION OF BYTE
        ; ---------------------------------------------
BL4:
        SEL     RB1             ; SET OF TRANS. REGISTERS
        MOV     R0,#STOPBIT
        MOV     A,#9
        ADD     A,@R0
        MOV     R5,A            ; NUMBER OF BIT TO TRANSMIT
        SEL     RB0             ; + STOP BIT


        MOV     A,#0FFH         ; TRANSMIT
        MOV     T,A
        EN      TCNTI
        STRT    CNT

        ; CHECK THE END OF TRANSMITION
PSYMB1:
        MOV     R0,#NBIT
        MOV     A,@R0
        JNZ     PSYMB1

        ; DISABLE TRANSMITION

        DIS     TCNTI
        STOP    TCNT
        JMP     BL3             ; CONTINUE JOB

        ; ---------------------------------------------
        ; GET BYTE FROM PARALLEL INTERFACE
        ; ---------------------------------------------

INCENTR:
        ORL     P2,#10000000B   ; SET P2.7 FOR INPUT
        IN      A,P2
        JB7     INCENTR         ; WAIT FOR DATA
        INS     A,BUS

        ; SET READY CONDITION

        ANL     P2,#10111111B   ; P2.6=0
        ORL     P2,#01000000B   ; P2.6=1
        RET                     ; *** END INCENTR ***

	; -------------------------------------------

        END
