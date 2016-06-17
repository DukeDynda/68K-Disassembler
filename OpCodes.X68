*-----------------------------------------------------------
*   Register Assignments
*   D0
*   D1
*   D2  
*   D3  Word operation read in from memory
*   D4  Output Counter (number of lines printed,)
*   D5  Masked op-code (original op-code with a mask applied)
*   D6 
*   D7   
*   A0  
*   A1  String to append to display buffer
*   A2
*   A3
*   A4  Last address
*   A5  Pointer to next byte after last byte in string
*   A6  Pointer to current word-op
*   A7  Stack
*   
*   Memory Assignments
*   7500 - 8000: Stack Pointer
*   7400: Start of String Pointer (display buffer)
*-----------------------------------------------------------
BEGIN               EQU    $7000
END                 EQU    $7100
DUKE_EA_FUNCTION    EQU    $3600

    ; Fake instructions that will be generated, and then disassembled
    ORG    BEGIN
    NOP
    MOVEM.W     A3/A4/A5/D0/D2/D4,-(SP)
    MOVEM.W     A3/A4/A5/D0/D2/D4,(A5)
    ADD.W       D3,D7
    ADD.L       (A3),D3
    ADD.B       D0,$1000
    ADDA.W      #$F00F,A6
    ADD.L       D0,A1
    ADDQ        #5,D3
    ADDQ        #7,$12340FF0
    AND         (A3),D1
    AND         D4,(A1)
    ASL.W       #3,D5
    ASL.B       D0,D1
    ASR.L       #1,D7
    ASR.L       D1,D0
    ASL         $1234
    ASR         $87654321
    BCC         ZZZZZZZ_END
    BVS         ZZZZZZZ_END
    BCHG        D3,(A7)
    BCHG        #16,$4444
    CMP         #$A0,D1
    CMP         D5,D4
    CMPA.W      #$FFFF,A3
    CMPA.L      A4,A7
    CMPI.B      #$12,D3
    CMPI.W      #$3456,(A7)
    CMPI.L      #$10205031,$00F03050
    DIVS        #$15,D0
    DIVS        $40AF,D4
    EOR         D0,(A3)
    EORI        #126,D5
    JSR         $4015
    LSR.L       #7,D0
    LSL.B       #4,D1
    LSR         D3,D4
    LSL         D4,D3
    LSR.W       $4000
    LSL.W       $4002
    MOVE.B      D5,D0
    MOVE.B      (A7),D6
    MOVEA.W     D0,A6
    MOVE.W      A6,D0
    MOVE.B      D0,D1
    MOVEA.L     D1,A0
    LEA         $1052,A1
    CLR.L       D0
    CLR.B       D2
    MOVEA.W     D0,A6
    MOVEA.L     D1,A0
ZZZZZZZ_END
    NOP
    
    ; 

    ORG    $2000
;START:                  ; first instruction of program
        CLR.L   D0
        CLR.L   D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
        
        ; MOVEA.L #$00004000,SP
        ;MOVEA.W #BEGIN,A6
        ;MOVEA.W #END,A4
        MOVEA.L #STRING_PTR,A5

; Begin examining op-code ID
LOOP    MOVE.W  (A6)+,D3    ; Load word-op to disassemble
        MOVE.W  D3,D5       ; Copy to another location so it's safe to modify
        ANDI.W  #$F000,D5   ; bitmask it for the last 4 bits (op-code ID)
        
        CMPI    #$0,D5
        BEQ     OP_ID_0
        
        CMPI    #$1000,D5
        BEQ     OP_ID_1
        
        CMPI    #$2000,D5
        BEQ     OP_ID_2
        
        CMPI    #$3000,D5
        BEQ     OP_ID_3
        
        CMPI    #$4000,D5
        BEQ     OP_ID_4
                
        CMPI    #$5000,D5
        BEQ     OP_ID_5
                
        CMPI    #$6000,D5
        BEQ     OP_ID_6
                
        CMPI    #$7000,D5
        BEQ     OP_ID_7
                
        CMPI    #$8000,D5
        BEQ     OP_ID_8
                
        CMPI    #$9000,D5
        BEQ     OP_ID_9
                
        CMPI    #$B000,D5
        BEQ     OP_ID_B
                
        CMPI    #$C000,D5
        BEQ     OP_ID_C
                
        CMPI    #$D000,D5
        BEQ     OP_ID_D
                
        CMPI    #$E000,D5
        BEQ     OP_ID_E
        
        BRA     BAD_INPUT
        
; End ID cases
        
OP_ID_0
        BTST.L  #$08,D3
        BNE     OP_BCHG
        
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        CMPI.W  #$0200,D5
        BEQ     OP_ANDI
        
        CMPI.W  #$0800,D5
        BEQ     OP_BCHGI
        
        CMPI.W  #$0C00,D5
        BEQ     OP_CMPI
        
        CMPI.W  #$0A00,D5
        BEQ     OP_EORI
        
        CMPI.W  #$0600,D5
        BEQ     OP_ADDI
        
        BRA     OP_SUBI

OP_ID_1 
        BRA     OP_MOVEB

OP_ID_2
        MOVE.W  D3,D5
        ANDI.W  #$01C0,D5
        CMPI.W  #$0040,D5
        BEQ     OP_MOVEAL
        BRA     OP_MOVEL

OP_ID_3
        MOVE.W  D3,D5
        ANDI.W  #$01C0,D5
        CMPI.W  #$0040,D5
        BEQ     OP_MOVEAW
        BRA     OP_MOVEW

OP_ID_4
        BTST.L  #$08,D3     ; compare the 8th bit in the op-code to 0
        BNE     OP_LEA      ; if it's a 1, it's a LEA op-code
        
        BTST.L  #11,D3      ; compare the 11th bit to 0
        BEQ     OP_CLR      ; if it's a 0, it's a CLR op-code
        
        MOVE.W  D3,D5
        ANDI.W  #$07C0,D5
        CMPI.W  #$0680,D5
        BEQ     OP_JSR
        
        CMPI.W  #$0080,D5
        BEQ     OP_MOVEMW_FROM
        
        CMPI.W  #$00C0,D5
        BEQ     OP_MOVEML_FROM
        
        CMPI.W  #$0480,D5
        BEQ     OP_MOVEMW_TO
        
        CMPI.W  #$04C0,D5
        BEQ     OP_MOVEML_TO
        
        CMPI.W  #$4E71,D3
        BEQ     OP_NOP
        
        BRA     OP_RTS

OP_ID_5
        BRA     OP_ADDQ

OP_ID_6 
        MOVE.W  D3,D5
        ANDI.W  #$0F00,D5
        CMPI.W  #$0400,D5
        BEQ     OP_BCC
        
        CMPI.W  #$0E00,D5
        BEQ     OP_BGT
        
        CMPI.W  #$0F00,D5
        BEQ     OP_BLE
        
        CMPI.W  #$0100,D5
        BEQ     OP_BSR
        
        BRA     OP_BVS
        
OP_ID_7
        BRA     OP_MOVEQ

OP_ID_8
        BRA     OP_DIVSW

OP_ID_9
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     OP_SUBA
        BRA     OP_SUB

OP_ID_B 
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     OP_CMPA
        
        BTST.L  #8,D3
        BEQ     OP_CMP
        BRA     OP_EOR

OP_ID_C 
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     OP_MULS
        BRA     OP_AND

OP_ID_D
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     OP_ADDA
        BRA     OP_ADD

OP_ID_E 
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     OP_ID_E_PART2
        
        MOVE.W  D3,D5
        ANDI.W  #$0038,D5
        CMPI.W  #$0000,D5
        BEQ     OP_ASD_I
        
        CMPI.W  #$0008,D5
        BEQ     OP_LSD_I
        
        CMPI.W  #$0018,D5
        BEQ     OP_ROD_I
        
        CMPI.W  #$0020,D5
        BEQ     OP_ASD_D
        
        CMPI.W  #$0028,D5
        BEQ     OP_LSD_D
        
        BRA     OP_ROD_D
        
OP_ID_E_PART2
        BTST.L  #09,D3
        BEQ     OP_ASD_EA
        BRA     OP_LSD_EA

; Print out code.
LOOP_END
        CMPI.B  #$FF,D7
        BEQ     LOOP_END_BAD_INPUT
        
LOOP_END_2
        MOVE.B  #0,(A5)
        MOVEA.L #STRING_PTR,A1
        MOVE.L  #13,D0
        TRAP    #15
        
        MOVEA.L #STRING_PTR,A5
        ADDQ.B  #1,D4 ; Increment output counter
        
        CMPA.L  A4,A6
        BGE     Z_END
        
        CMP.B   #30,D4
        BEQ     QUERY_CONTINUE
                
        BRA     LOOP
        
LOOP_END_BAD_INPUT
        MOVEA.L #STRING_PTR,A5
        BRA     BAD_INPUT
        
QUERY_CONTINUE
        MOVE.B  #0,D4
        LEA     TXT_QUERY,A1
        MOVE.L  #14,D0
        TRAP    #15
        
        MOVE.B  #5,D0
        TRAP    #15
        BRA     LOOP

;----------------------------------------------------------------------
; Op-Code Processing Labels (Alphabetical Order)
;----------------------------------------------------------------------
OP_ADD
        ; Verify
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5 ; Unknown size '11'
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_ADD,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        BTST.L  #8,D3
        BEQ     OP_ADD_DEST
        
OP_ADD_SOURCE
        ; ADD Dn,<ea>
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.W  #9,D0
        LSR.W   D0,D5
        ADD.B   #$30,D5
        MOVE.B  D5,(A5)+
        
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        MOVE.B  #1,D6
        ANDI.W  #$003F,D5
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_ADD_DEST
        ; ADD <ea>,Dn
        MOVE.W  D3,D5
        MOVE.B  #1,D6
        ANDI.W  #$003F,D5
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.W  #9,D0
        LSR.W   D0,D5
        ADD.B   #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_ADDA
        ; Verify
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5 ; Size must be 11
        CMPI.W  #$00C0,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_ADDA,A1
        JSR     APPEND_STRING
        
        BTST.L  #8,D3
        BEQ     OP_ADDAW
        
        MOVE.B  #'L',(A5)+
        MOVE.L  #$10,D7
        BRA     OP_ADDA_END
        
OP_ADDAW
        MOVE.B  #'W',(A5)+
        CLR.L   D7
        
OP_ADDA_END
        MOVE.B  #' ',(A5)+
        
        MOVE.W  D3,D5
        MOVE.B  #1,D6
        ANDI.W  #$003F,D5
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        
        MOVE.B  #'A',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD.W   #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_ADDI
        MOVE.W  D3,D5
        ANDI.W  #$FF00,D5
        CMPI.W  #$0600,D5
        BNE     BAD_INPUT
        
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_ADDI,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        MOVE.B  #'#',(A5)+
        MOVE.B  #'$',(A5)+
        CMPI.W  #$0080,D5
        BEQ     OP_ADDI_L
        
        MOVE.W  (A6)+,D0
        
        CMPI.W  #$0040,D5
        BEQ     OP_ADDI_W
        
OP_ADDI_B
        JSR     PRINT_HEX_BYTE
        BRA     OP_ADDI_END
        
OP_ADDI_W
        JSR     PRINT_HEX_WORD
        BRA     OP_ADDI_END
        
OP_ADDI_L
        MOVE.L  (A6)+,D0
        JSR     PRINT_HEX_LONG
        MOVE.L  #$10,D7
        
OP_ADDI_END
        MOVE.B  #',',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_ADDQ
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_ADDQ,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        MOVE.B  #'#',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADDI.B  #$30,D5
        MOVE.B  D5,(A5)+
        
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        MOVE.B  #1,D6
        ANDI.W  #$003F,D5
        MOVE.W  D3,D7
        ANDI.W  #$01C0,D7
        LSR.W   #6,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_AND
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT ; Size '11' illegal
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_AND,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        ; Move Data Register ASCII value into D0
        MOVE    D3,D0
        ANDI.W  #$0E00,D0
        MOVE.W  #9,D1
        LSR.W   D1,D0
        ADD.W   #$30,D0
        
        BTST.L  #8,D3
        BEQ     OP_AND_DEST
        
OP_AND_SOURCE
        MOVE.B  #'D',(A5)+
        MOVE.B  D0,(A5)+
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        MOVE.B  #1,D6
        ANDI.W  #$003F,D5
        MOVE.W  D3,D7
        ANDI.W  #$01C0,D7
        LSR.W   #6,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_AND_DEST
        MOVE.W  D3,D5
        MOVE.B  #1,D6
        ANDI.W  #$003F,D5
        MOVE.W  D3,D7
        ANDI.W  #$01C0,D7
        LSR.W   #6,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.B  D0,(A5)+
        
        BRA     LOOP_END
        
OP_ANDI
        MOVE.W  D3,D5
        ANDI.W  #$FF00,D5
        CMPI.W  #$0200,D5
        BNE     BAD_INPUT
        
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_ANDI,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        MOVE.B  #'#',(A5)+
        MOVE.B  #'$',(A5)+
        
        CMPI.W  #$0080,D5
        BEQ     OP_ANDI_L
        
        MOVE.W  (A6)+,D0
        MOVE.L  #0,D7
        CMPI.W  #$0040,D5
        BEQ     OP_ANDI_W
        BRA     OP_ANDI_B
        
OP_ANDI_L
        MOVE.L  (A6)+,D0
        JSR     PRINT_HEX_LONG
        BRA     OP_ANDI_END
        
OP_ANDI_W
        JSR     PRINT_HEX_WORD
        BRA     OP_ANDI_END
        
OP_ANDI_B
        JSR     PRINT_HEX_BYTE
        MOVE.L  #$10,D7
        
OP_ANDI_END
        MOVE.B  #',',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END 
        
OP_ASD_D
        JSR     PRINT_ADDRESS
        
        BTST.L  #8,D3
        BEQ     OP_ASR_D
        BRA     OP_ASL_D
        
OP_ASL_D
        LEA     TXT_OP_ASL,A1
        BRA     OP_ASD_D_END
        
OP_ASR_D
        LEA     TXT_OP_ASR,A1
        
OP_ASD_D_END
        JSR     APPEND_STRING
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D0
        ANDI.W  #$0E00,D0
        MOVE.B  #9,D1
        LSR.W   D1,D0
        ADD.B  #$30,D0
        MOVE.B  D0,(A5)+
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D0
        ANDI.W  #$0007,D0
        ADD.B  #$30,D0
        MOVE.B  D0,(A5)+
        
        BRA     LOOP_END
        
OP_ASD_I
        JSR     PRINT_ADDRESS
        
        BTST.L  #8,D3
        BEQ     OP_ASR_I
        BRA     OP_ASL_I
        
OP_ASL_I
        LEA     TXT_OP_ASL,A1
        BRA     OP_ASD_I_END
        
OP_ASR_I
        LEA     TXT_OP_ASR,A1
        
OP_ASD_I_END
        JSR     APPEND_STRING
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        MOVE.B  #'#',(A5)+
        MOVE.W  D3,D0
        ANDI.W  #$0E00,D0
        MOVE.B  #9,D1
        LSR.W   D1,D0
        ADD.B  #$30,D0
        MOVE.B  D0,(A5)+
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D0
        ANDI.W  #$0007,D0
        ADD.B  #$30,D0
        MOVE.B  D0,(A5)+
        BRA     LOOP_END
        
OP_ASD_EA
        JSR     PRINT_ADDRESS
        
        BTST.L  #8,D3
        BEQ     OP_ASR_EA
        BRA     OP_ASL_EA
        
OP_ASL_EA
        LEA     TXT_OP_ASL_EA,A1
        BRA     OP_ASD_EA_END
        
OP_ASR_EA
        LEA     TXT_OP_ASR_EA,A1
        
OP_ASD_EA_END
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #0,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_BCC
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_BCC,A1
        JSR     APPEND_STRING
        
OP_BCC_COMMON
        MOVE.L  A6,D0
        MOVE.W  D3,D5
        ANDI.W  #$00FF,D5
        CMPI.W  #$0000,D5
        BEQ     OP_BCC_2BYTE_DISPLACE
        CMPI.W  #$00FF,D5
        BEQ     OP_BCC_4BYTE_DISPLACE
        
        ;1 BYTE DISPLACE
        MOVE.W  D5,D1
        BRA     OP_BCC_END
        
OP_BCC_2BYTE_DISPLACE
        MOVE.W  (A6)+,D1
        BRA     OP_BCC_END
        
OP_BCC_4BYTE_DISPLACE
        MOVE.L  (A6)+,D1
        
OP_BCC_END
        ADD.L   D1,D0
        JSR     PRINT_HEX_LONG
        
        BRA     LOOP_END
        
OP_BGT
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_BGT,A1
        JSR     APPEND_STRING
        BRA     OP_BCC_COMMON
        
OP_BLE
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_BLE,A1
        JSR     APPEND_STRING
        BRA     OP_BCC_COMMON
        
OP_BVS
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_BVS,A1
        JSR     APPEND_STRING
        BRA     OP_BCC_COMMON
        
OP_BCHG
        MOVE.W  D3,D5
        ANDI.W  #$F1C0,D5
        CMPI.W  #$0140,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_BCHG,A1
        JSR     APPEND_STRING
        MOVE.B  #'D',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD.W   #$30,D5
        MOVE.B  D5,(A5)+
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #0,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_BCHGI
        MOVE.W  D3,D5
        ANDI.W  #$FFC0,D5
        CMPI.W  #$0840,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_BCHG,A1
        JSR     APPEND_STRING
        MOVE.B  #'#',(A5)+
        MOVE.B  #'$',(A5)+
        MOVE.W  (A6)+,D0
        JSR     PRINT_HEX_WORD
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #0,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_BSR
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_BSR,A1
        JSR     APPEND_STRING
        BRA     OP_BCC_COMMON

OP_CLR   
        ; Verify it's a CLR instruction
        MOVE.W  D3,D5
        ANDI.W  #$FF00,D5
        CMPI.W  #$4200,D5
        BNE     BAD_INPUT
        
        ; CLR cannot have bits 6 and 7 set to 11
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        ; Print instructions
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_CLR,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        MOVE.W  D3,D5
        MOVE.B  #1,D6
        ANDI.W  #$003F,D5
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_CMP
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_CMP,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        
        MOVE.W  D3,D5
        MOVE.L  #1,D6
        ANDI.W  #$003F,D5
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_CMPA
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        BTST.L  #8,D3
        BNE     OP_CMPA_L
        
OP_CMPA_W
        LEA     TXT_OP_CMPAW,A1
        BRA     OP_CMPA_END
        
OP_CMPA_L
        LEA     TXT_OP_CMPAL,A1
        
OP_CMPA_END
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        MOVE.L  #1,D6
        MOVE.L  #$11,D7
        ANDI.W  #$003F,D5
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'A',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_CMPI
        MOVE.W  D3,D5
        ANDI.W  #$FF00,D5
        CMPI.W  #$0C00,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_CMPI,A1
        JSR     APPEND_STRING
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        MOVE.B  #'#',(A5)+
        MOVE.B  #'$',(A5)+
        
        CMPI.W  #$0080,D5
        BEQ     OP_CMPI_L
        
        MOVE.W  (A6)+,D0
        JSR     PRINT_HEX_WORD
        MOVE.L  #$11,D7
        BRA     OP_CMPI_END
        
OP_CMPI_L
        MOVE.L  (A6)+,D0
        MOVE.L  #$10,D7
        JSR     PRINT_HEX_LONG
        
OP_CMPI_END
        MOVE.B  #',',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_DIVSW
        MOVE.W  D3,D5
        ANDI.W  #$F1C0,D5
        CMPI.W  #$81C0,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_DIVSW,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #11,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D1
        LSR.W   D1,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_EOR
        MOVE.W  D3,D5
        ANDI.W  #$F100,D5
        CMPI.W  #$B100,D5
        BNE     BAD_INPUT
        
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_EOR,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        MOVE.L  D5,D7
        MOVE.B  #'D',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D1
        LSR.W   D1,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_EORI
        MOVE.W  D3,D5
        ANDI.W  #$FF00,D5
        CMPI.W  #$0A00,D5
        BNE     BAD_INPUT
        
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        CMPI.W  #$00C0,D5
        BEQ     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_EORI,A1
        JSR     APPEND_STRING
        JSR     PRINT_SIZE
        MOVE.L  D5,D7
        MOVE.B  #'#',(A5)+
        MOVE.B  #'$',(A5)+
        
        CMPI.W  #$0080,D5
        BEQ     OP_EORI_L
        
        MOVE.W  (A6)+,D0
        JSR     PRINT_HEX_WORD
        BRA     OP_EORI_END
        
OP_EORI_L
        MOVE.L  (A6)+,D0
        JSR     PRINT_HEX_LONG
        
OP_EORI_END
        MOVE.B  #',',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_JSR
        MOVE.W  D3,D5
        ANDI.W  #$FFC0,D5
        CMPI.W  #$4E80,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_JSR,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #11,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END

OP_LEA
        ; Veriy it's LEA
        MOVE.W  D3,D5
        ANDI.W  #$F1C0,D5
        CMPI.W  #$41C0,D5
        BNE     BAD_INPUT
        
        ; Print
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_LEA,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.B  #1,D6
        MOVE.B  #$10,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'A',(A5)+
        
        ; Print Address Register
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD.W   #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_LSD_D
        JSR     PRINT_ADDRESS
        BTST.L  #8,D3
        BEQ     OP_LSR_D
        
        LEA     TXT_OP_LSL,A1
        BRA     OP_LSD_D_END
        
OP_LSR_D
        LEA     TXT_OP_LSR,A1
        
OP_LSD_D_END
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0007,D5
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_LSD_I
        JSR     PRINT_ADDRESS
        BTST.L  #8,D3
        BEQ     OP_LSR_I
        
        LEA     TXT_OP_LSL,A1
        BRA     OP_LSD_I_END
        
OP_LSR_I
        LEA     TXT_OP_LSR,A1
        
OP_LSD_I_END
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        MOVE.B  #'#',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0003,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_LSD_EA
        JSR     PRINT_ADDRESS
        BTST.L  #8,D3
        BEQ     OP_LSR_EA
        
        LEA     TXT_OP_LSL,A1
        BRA     OP_LSD_EA_END
        
OP_LSR_EA
        LEA     TXT_OP_LSR,A1
        
OP_LSD_EA_END
        JSR     APPEND_STRING
        MOVE.B  #'W',(A5)+
        MOVE.B  #' ',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$01,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_MOVEAB
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEAB,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$00,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'A',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_MOVEAL
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEAL,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$10,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'A',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END

OP_MOVEAW
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEAW,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$01,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'A',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END

OP_MOVEB
        ; Verify
        MOVE.W  D3,D5
        ANDI.W  #$F000,D5
        CMPI.W  #$1000,D5
        BNE     BAD_INPUT
        
        ; Print
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEB,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.B  #1,D6
        MOVE.B  #0,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0FC0,D5
        LSR.W   #6,D5
        MOVE.B  #0,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_MOVEL
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEL,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.B  #1,D6
        MOVE.B  #$10,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0FC0,D5
        LSR.W   #6,D5
        MOVE.B  #0,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_MOVEW
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEW,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.B  #1,D6
        MOVE.B  #$01,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0FC0,D5
        LSR.W   #6,D5
        MOVE.B  #0,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_MOVEMW_FROM
        MOVE.W  D3,D5
        ANDI.W  #$FFC0,D5
        CMPI.W  #$4880,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEMW,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$0038,D5
        CMPI.W  #$0020,D5
        BEQ     OP_MOVEMW_FROM_DECREMENT
        BRA     OP_MOVEMW_FROM_REGULAR
        
OP_MOVEMW_FROM_DECREMENT
        JSR     PRINT_MOVEM_LIST_DECREMENT
        BRA     OP_MOVEM_FROM_END
        
OP_MOVEMW_FROM_REGULAR
        JSR     PRINT_MOVEM_LIST_INCREMENT
        
OP_MOVEM_FROM_END
        MOVE.B  #',',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$01,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_MOVEML_FROM
        MOVE.W  D3,D5
        ANDI.W  #$FFC0,D5
        CMPI.W  #$48C0,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEML,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$0038,D5
        CMPI.W  #$0020,D5
        BEQ     OP_MOVEML_FROM_DECREMENT
        BRA     OP_MOVEML_FROM_REGULAR
        
OP_MOVEML_FROM_DECREMENT
        JSR     PRINT_MOVEM_LIST_DECREMENT
        BRA     OP_MOVEM_FROM_END
        
OP_MOVEML_FROM_REGULAR
        JSR     PRINT_MOVEM_LIST_INCREMENT
        BRA     OP_MOVEM_FROM_END
        
OP_MOVEMW_TO
        MOVE.W  D3,D5
        ANDI.W  #$FFC0,D5
        CMPI.W  #$4C80,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEMW,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$01,D7
        JSR     DUKE_EA_FUNCTION
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0038,D5
        CMPI.W  #$0020,D5
        BEQ     OP_MOVEMW_TO_DECREMENT
        BRA     OP_MOVEMW_TO_REGULAR
        
OP_MOVEMW_TO_DECREMENT
        JSR     PRINT_MOVEM_LIST_DECREMENT
        BRA     OP_MOVEM_TO_END
        
OP_MOVEMW_TO_REGULAR
        JSR     PRINT_MOVEM_LIST_INCREMENT
        
OP_MOVEM_TO_END
        BRA     LOOP_END
        
OP_MOVEML_TO
        MOVE.W  D3,D5
        ANDI.W  #$FFC0,D5
        CMPI.W  #$4CC0,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEML,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$01,D7
        JSR     DUKE_EA_FUNCTION
        MOVE.B  #',',(A5)+
        
        MOVE.W  D3,D5
        ANDI.W  #$0038,D5
        CMPI.W  #$0020,D5
        BEQ     OP_MOVEMW_TO_DECREMENT
        BRA     OP_MOVEMW_TO_REGULAR
        
OP_MOVEQ
        MOVE.W  D3,D5
        ANDI.W  #$F100,D5
        CMPI.W  #$7000,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MOVEQ,A1
        JSR     APPEND_STRING
        
        MOVE.B  #'#',(A5)+
        MOVE.B  #'$',(A5)+
        MOVE.W  D3,D0
        ANDI.W  #$00FF,D0
        JSR     PRINT_HEX_WORD
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_MULS
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_MULS,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  #$01,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_NOP
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_NOP,A1
        JSR     APPEND_STRING
        BRA     LOOP_END
        
OP_ROD_D
        JSR     PRINT_ADDRESS
        BTST.L  #8,D3
        BEQ     OP_ROR_D
        
        LEA     TXT_OP_ROL,A1
        BRA     OP_ROD_D_END
        
OP_ROR_D
        LEA     TXT_OP_ROR,A1
        
OP_ROD_D_END
        JSR     APPEND_STRING
        
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0007,D5
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_ROD_I
        JSR     PRINT_ADDRESS
        BTST.L  #8,D3
        BEQ     OP_ROR_I
        
        LEA     TXT_OP_ROL,A1
        BRA     OP_ROD_I_END
        
OP_ROR_I
        LEA     TXT_OP_ROR,A1
        
OP_ROD_I_END
        JSR     APPEND_STRING

        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        MOVE.B  #'#',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D0
        LSR.W   D0,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0003,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_RTS
        MOVE.W  D3,D5
        CMPI.W  #$4E75,D5
        BNE     BAD_INPUT
        
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_RTS,A1
        JSR     APPEND_STRING
        BRA     LOOP_END
        
OP_SUB
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_SUB,A1
        JSR     APPEND_STRING
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        BTST.L  #8,D3
        BEQ     OP_SUB_TO
        
OP_SUB_FROM
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  D3,D7
        ANDI.W  #$00C0,D7
        LSR.W   #6,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D1
        LSR.W   D1,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_SUB_TO
        MOVE.B  #'D',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D1
        LSR.W   D1,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        MOVE.B  #',',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  D3,D7
        ANDI.W  #$00C0,D7
        LSR.W   #6,D7
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END
        
OP_SUBA
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_SUBA,A1
        JSR     APPEND_STRING
                
        BTST.L  #8,D3
        BNE     OP_SUBA_L
        
OP_SUBA_W
        MOVE.B  #'W',(A5)+
        BRA     OP_SUBA_END

OP_SUBA_L
        MOVE.B  #'L',(A5)+
        
OP_SUBA_END
        MOVE.B  #' ',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        MOVE.L  D3,D7
        ANDI.W  #$00C0,D7
        LSR.W   #6,D7
        JSR     DUKE_EA_FUNCTION
        
        MOVE.B  #',',(A5)+
        MOVE.B  #'A',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$0E00,D5
        MOVE.B  #9,D1
        LSR.W   D1,D5
        ADD     #$30,D5
        MOVE.B  D5,(A5)+
        
        BRA     LOOP_END
        
OP_SUBI
        JSR     PRINT_ADDRESS
        LEA     TXT_OP_SUBI,A1
        JSR     APPEND_STRING
        MOVE.W  D3,D5
        ANDI.W  #$00C0,D5
        JSR     PRINT_SIZE
        
        MOVE.B  #'#',(A5)+
        MOVE.B  #'$',(A5)+
        
        CMPI.W  #$0080,D5
        BEQ     OP_SUBI_L
        
        MOVE.W  (A6)+,D0
        CLR.L   D7
        JSR     PRINT_HEX_WORD
        BRA     OP_SUBI_END
        
OP_SUBI_L
        MOVE.L  (A6)+,D0
        MOVE.L  #$10,D7
        JSR     PRINT_HEX_LONG
        
OP_SUBI_END
        MOVE.B  #',',(A5)+
        MOVE.W  D3,D5
        ANDI.W  #$003F,D5
        MOVE.L  #1,D6
        JSR     DUKE_EA_FUNCTION
        
        BRA     LOOP_END

;----------------------------------------------------------------------
; Printing Functions
;----------------------------------------------------------------------
;--------------------------------------------------
; Prints the Data, which is the current op-code.
; The format is "XXXXXXXX DATA YYYY" where
; XXXXXXXX is the address of this data, and YYYY
; is the data.
;--------------------------------------------------
BAD_INPUT
        JSR     PRINT_ADDRESS
        LEA     TXT_DATA,A1
        JSR     APPEND_STRING
        
        MOVE.W  D3,D0
        JSR     PRINT_HEX_WORD
        
        CMPI.B  #$FF,D7
        BNE     LOOP_END
        BRA     LOOP_END_2

;--------------------------------------------------
; Print the literal address currently in A6, 
; This should be the prevously read op-code, which
; is the op-code currently being decoded.
;--------------------------------------------------
PRINT_ADDRESS
        MOVEM.L D0-D2,-(SP)
        
        MOVE.L  A6,D0           ; Move op-code address to D0
        SUBI.L  #2,D0           ; Subtract 2 because pointer is to next op-code
        JSR     PRINT_HEX_LONG
        MOVE.B  #' ',(A5)+
        MOVE.B  #' ',(A5)+
        MOVE.B  #' ',(A5)+
        MOVE.B  #' ',(A5)+
        
        MOVEM.L (SP)+,D0-D2
        RTS
        
;--------------------------------------------------
; Prints the byte hex digits in D0
; Specifically, the least significant 8 bits.
;--------------------------------------------------
PRINT_HEX_BYTE
        MOVEM.L D0-D2,-(SP)
        
        CLR.L   D1
        MOVE.L  #2,D2
        
PRINT_HEX_BYTE_LOOP
        ROL.B   #4,D0
        MOVE.B  D0,D1
        ANDI.B  #$0F,D1
        CMPI.B  #$0A,D1
        BLT     PRINT_HEX_BYTE_DECIMAL
        ADDI.B  #$7,D1
        
PRINT_HEX_BYTE_DECIMAL
        ADDI.B  #$30,D1
        MOVE.B  D1,(A5)+
        SUBI.B  #1,D2
        CMPI.L  #0,D2
        BNE     PRINT_HEX_BYTE_LOOP
        
        MOVEM.L (SP)+,D0-D2
        RTS
        
;--------------------------------------------------
; Prints the word hex digits in D0
; Specifically, the least significant 16 bits.
;--------------------------------------------------
PRINT_HEX_WORD
        MOVE.L  D0,-(SP)
        
        ROL.W   #8,D0
        JSR     PRINT_HEX_BYTE
        ROL.W   #8,D0
        JSR     PRINT_HEX_BYTE
        
        MOVE.L  (SP)+,D0
        RTS
        
;--------------------------------------------------
; Prints the word hex digits in D0
; Specifically, the least significant 16 bits.
;--------------------------------------------------
PRINT_HEX_LONG
        MOVE.L  D0,-(SP)
        
        SWAP    D0
        JSR     PRINT_HEX_WORD
        SWAP    D0
        JSR     PRINT_HEX_WORD
        
        MOVE.L  (SP)+,D0
        RTS

;--------------------------------------------------
; Append the output buffer with the string starting
; at A1. The string at A1 must end with 0 (null).
;--------------------------------------------------
APPEND_STRING
        MOVE.B  (A1)+,(A5)+
        CMP.B   #0,(A1)
        BNE     APPEND_STRING
        
        RTS

;--------------------------------------------------
; Prints the character B, W, or L depending on the
; value in D5.
; $0000 = B     $0040 = W   anything else = L
;--------------------------------------------------
PRINT_SIZE
        CMPI.W  #$0000,D5
        BEQ     PRINT_SIZE_B
        CMPI.W  #$0040,D5
        BEQ     PRINT_SIZE_W
        BRA     PRINT_SIZE_L

PRINT_SIZE_B
        MOVE.B  #$42,(A5)+
        BRA     PRINT_SIZE_END
        
PRINT_SIZE_W
        MOVE.B  #$57,(A5)+
        BRA     PRINT_SIZE_END

PRINT_SIZE_L
        MOVE.B  #$4C,(A5)+

PRINT_SIZE_END
        MOVE.B  #' ',(A5)+
        MOVE.B  #' ',(A5)+
        MOVE.B  #' ',(A5)+
        RTS
        



PRINT_MOVEM_LIST_DECREMENT
        MOVEM.L D0/D1/D2/D7,-(SP)
        MOVE.L  #15,D0
        CLR.L   D1
        CLR.L   D2
        CLR.L   D7
        MOVE.W  (A6)+,D7
        
PRINT_MOVEM_D_LOOP
        BTST.L  D0,D7
        BEQ     PRINT_MOVEM_D_LOOP_CHECK
        
        CMPI.B  #0,D1
        BEQ     PRINT_MOVEM_D_LOOP_NOSLASH
        MOVE.B  #'/',(A5)+
        
PRINT_MOVEM_D_LOOP_NOSLASH
        CMPI.B  #8,D0
        BLT     PRINT_MOVEM_D_PRINT_A
        
        MOVE.B  #'D',(A5)+
        MOVE.B  D2,D1
        ADD     #$30,D1
        BRA     PRINT_MOVEM_D_LOOP_END
        
PRINT_MOVEM_D_PRINT_A
        MOVE.B  #'A',(A5)+
        MOVE.B  D2,D1
        ADD     #$28,D1
        
PRINT_MOVEM_D_LOOP_END
        MOVE.B  D1,(A5)+
        
PRINT_MOVEM_D_LOOP_CHECK
        ADDQ.B  #1,D2
        SUBQ.B  #1,D0
        CMPI.B  #0,D0
        BGE     PRINT_MOVEM_D_LOOP
        
        MOVEM.L (SP)+,D0/D1/D2/D7
        RTS
        


PRINT_MOVEM_LIST_INCREMENT
        MOVEM.L D0/D1/D7,-(SP)
        CLR.L   D0
        CLR.L   D1
        CLR.L   D7
        MOVE.W  (A6)+,D7
        
PRINT_MOVEM_I_LOOP
        BTST.L  D0,D7
        BEQ     PRINT_MOVEM_I_LOOP_CHECK
        
        CMPI.B  #0,D1
        BEQ     PRINT_MOVEM_I_LOOP_NOSLASH
        MOVE.B  #'/',(A5)+
        
PRINT_MOVEM_I_LOOP_NOSLASH
        CMPI.B  #8,D0
        BGE     PRINT_MOVEM_I_PRINT_A
        
        MOVE.B  #'D',(A5)+
        MOVE.B  D0,D1
        ADD     #$30,D1
        BRA     PRINT_MOVEM_I_LOOP_END
        
PRINT_MOVEM_I_PRINT_A
        MOVE.B  #'A',(A5)+
        MOVE.B  D0,D1
        ADD     #$28,D1
        
PRINT_MOVEM_I_LOOP_END
        MOVE.B  D1,(A5)+
        
PRINT_MOVEM_I_LOOP_CHECK
        ADDQ.B  #1,D0
        CMPI.B  #15,D0
        BLE     PRINT_MOVEM_I_LOOP
        
        MOVEM.L (SP)+,D0/D1/D7
        RTS
        
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Appends the decoded EA to the output buffer.
; Needs to call Duke's code instead!!!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Temp function to Print EA information
DUKE_EA
        

        
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; End the function. Return to Mark particularly!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Z_END
        ;NOP
        RTS
        

;----------------------------------------------------------------------
; End of memory variables and constants
;----------------------------------------------------------------------
TXT_DATA        DC.B    'DATA    ',0
TXT_OP_ADD      DC.B    'ADD.',0
TXT_OP_ADDA     DC.B    'ADDA.',0
TXT_OP_ADDI     DC.B    'ADDI.',0
TXT_OP_ADDQ     DC.B    'ADDQ.',0
TXT_OP_AND      DC.B    'AND.',0
TXT_OP_ANDI     DC.B    'ANDI.',0
TXT_OP_ASL      DC.B    'ASL.',0
TXT_OP_ASR      DC.B    'ASR.',0
TXT_OP_ASL_EA   DC.B    'ASL     ',0
TXT_OP_ASR_EA   DC.B    'ASR     ',0
TXT_OP_BCC      DC.B    'BCC     ',0
TXT_OP_BGT      DC.B    'BGT     ',0
TXT_OP_BLE      DC.B    'BLE     ',0
TXT_OP_BSR      DC.B    'BSR     ',0
TXT_OP_BVS      DC.B    'BVS     ',0
TXT_OP_BCHG     DC.B    'BCHG    ',0
TXT_OP_CLR      DC.B    'CLR.',0
TXT_OP_CMP      DC.B    'CMP.',0
TXT_OP_CMPAW    DC.B    'CMPA.W  ',0
TXT_OP_CMPAL    DC.B    'CMPA.L  ',0
TXT_OP_CMPI     DC.B    'CMPI.',0
TXT_OP_DIVSW    DC.B    'DVS.W   ',0
TXT_OP_EOR      DC.B    'EOR.',0
TXT_OP_EORI     DC.B    'EORI.',0
TXT_OP_JSR      DC.B    'JSR     ',0
TXT_OP_LEA      DC.B    'LEA     ',0
TXT_OP_LSL      DC.B    'LSL.',0
TXT_OP_LSR      DC.B    'LSR.',0
TXT_OP_MOVEB    DC.B    'MOVE.B  ',0
TXT_OP_MOVEL    DC.B    'MOVE.L  ',0
TXT_OP_MOVEW    DC.B    'MOVE.W  ',0
TXT_OP_MOVEAB   DC.B    'MOVEA.B ',0
TXT_OP_MOVEAL   DC.B    'MOVEA.L ',0
TXT_OP_MOVEAW   DC.B    'MOVEA.W ',0
TXT_OP_MOVEMW   DC.B    'MOVEM.W ',0
TXT_OP_MOVEML   DC.B    'MOVEM.L ',0
TXT_OP_MOVEQ    DC.B    'MOVEQ.L ',0
TXT_OP_MULS     DC.B    'MULS.W  ',0
TXT_OP_NOP      DC.B    'NOP     ',0
TXT_OP_ROL      DC.B    'ROL.',0
TXT_OP_ROR      DC.B    'ROR.',0
TXT_OP_RTS      DC.B    'RTS     ',0
TXT_OP_SUB      DC.B    'SUB.',0
TXT_OP_SUBA     DC.B    'SUBA.',0
TXT_OP_SUBI     DC.B    'SUBI.',0
TXT_QUERY       DC.B    '(Press Enter to continue)',0
TXT_DEFAULT_EA  DC.B    'XXXXXX',0
STRING_PTR      DC.B    0
    ;END    START        ; last line of source


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
