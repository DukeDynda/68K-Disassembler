*-----------------------------------------------------------
* Title      : 68K Disassembler (Team project)
* Written by : Duke Dynda
* Date       : 02/13/2016
* Description: Effective Addressing part of 68K Disassembler
*              (OpCode = Anthony, I/O = Mark, EA = Duke)
*-----------------------------------------------------------
            ORG         $3400
************************************************************
*                     HELPER FUNCTIONS                     *
************************************************************
SETPREV
            MOVEM.L     D0-D6,-(SP)     Save data to stack so not to affect I/O or OpCode:
            BRA         HEXTOOCT        at beginning of program
GETPREV
            MOVEM.L     (SP)+,D0-D6     Get data from stack for original datas:
            BRA         DONE            at end of program

LONGTOASCII
            MOVE.L      (A6),D0         Move data to temporary data register as Long
            MOVE.B      #0,D3           Let HEXTOASCII know if 0 = Long or 1 = Word
            JSR         HEXTOASCII      Convert Hex to ASCII
            RTS
WORDTOASCII
            MOVE.W      (A6),D0         Move data to temporary data register as Word
            MOVE.B      #1,D3
            JSR         HEXTOASCII
            RTS
HEXTOASCII
		    ROL.L		#4,D0           Rotate to analyze LSB one by one
		    MOVE.L		D0,D1           Temporary data register
		    MOVE.B      #8,D2           Counter
STOREHEX    ANDI.L		#$0000000F,D1   Only get last bit of Long
		    CMPI.B		#$0A,D1         Make sure its not already ASCII
		    BLT		    STOREDEC        Store the decimal
            ADDI.B      #$7,D1          Add 7 if its a letter
STOREDEC    ADDI.B		#$30,D1         Convert to ASCII
		    CMP.B       #1,D3           Check if Word or Long
		    BEQ         CHECKCOUNT      If its a Word then check Counter
		    BNE         DOPRINT         For Word we only want to print first 4 ASCII
CHECKCOUNT  CMP.B       #5,D2           Only print first 4 ASCII (ignore leading 0's)
            BGE         DONTPRINT       Don't print Word's leading 0's
DOPRINT     MOVE.B		D1,(A5)+        Print into buffer
DONTPRINT   ROL.L		#4,D0           Next number
		    MOVE.L		D0,D1           Move into temporary data register
		    SUBI.B		#1,D2           Decrement Counter
		    CMPI.L		#0,D2           Exit if all 8 bytes checked
		    BNE		    STOREHEX        Otherwise continue
		    RTS
		    
            ORG         $3600
;START:                                  ; first instruction of program

****************** Testing example for EA ******************     ------------------- TESTING
            ;MOVE.W      #$27,D5         EA dest or src hex i will receive
            ;MOVE.B      #$0,D6          1 = source, 0 = destination
            ;MOVE.B      #$01,D7         Op size (for immediate data) 10 = Long 01 = Word
            ;LEA         $0020,A6        Data pointer, earliest space to start A6 for me
            ;MOVE.L      #$A2B4C6D8,(A6) Data that I will receive
**** Bits for EA destination or source ex: 3C = 111 100 ****     ------------------- TESTING

************************* EA Begin *************************
************************************************************
* Assumptions:                                             *
* Before program start:                                    *
*   A4 = End Address                                       *
*   A5 = Good Buffer                                       *
*   A6 = Data Pointer (Start) (for EA data)                *
*   A7 = Stack                                             *
*   D5 = Effective Address (hex) (source or destination)   *
*   D6 = Source or destination boolean (0 = dest, 1 = src) *
*   D7 = OpSize (data size either 01 = Word or 10 = Long)  *
* During program:                                          *
*   D4 = EA Register                                       *
*   D5 = Temporary storage                                 *
*   D6 = EA Mode                                           *
*   Error checking done during compilation of .L file      *
*   ASCII FF stored in buffer is bad operation (for mark)  *
************************************************************

************************************************************
* Converts hexadecimal EA to Octal EA 3 bit mode/ register *
************************************************************
            BRA         SETPREV         Set original data in stack so its not affected
HEXTOOCT
            CMP.B       #$0,D6          Check to see if destination EA
            BEQ         DESTINATION     Convert dest EA to octal mode and register
            CMP.B       #$1,D6          Check to see if source EA
            BEQ         SOURCE          Convert src EA to octal mode and register:
            BRA         ERROR           else throw an error, can only be 0 or 1
            
DESTINATION
*** Converts EA Destination Register bits (middle 3 bits) **
            MOVE.B      D5,D4           Prepare to get 3 dest register bits
            LSL.B       #2,D4           Shift 2 bits left for MSB
            LSR.B       #5,D4           Shift 5 bits right for LSB thus EA dest reg saved
************ Register complete (register saved) ************

****** Converts EA Destination Mode bits (last 3 bits) *****
            MOVE.B      D5,D6           Prepare to get 3 dest mode bits
            LSL.B       #5,D6           Shift 5 bits left for MSB
            LSR.B       #5,D6           Shift 5 bits right for LSB thus EA dest mode saved
*** Mode complete (mode # saved) next get addressing mode **
            BRA         MODETAB         Next work on address mode using mode table

SOURCE
******* Converts EA Source Mode bits (middle 3 bits) *******
            MOVE.B      D5,D6           Prepare to get 3 src mode bits
            LSL.B       #2,D6           Shift 2 bits left for MSB
            LSR.B       #5,D6           Shift 5 bits right for LSB thus EA src mode saved
*************** Mode complete (mode # saved) ***************

****** Converst EA Source Register bits (last 3 bits) ******
            MOVE.B      D5,D4           Prepare to get 3 src register bits
            LSL.B       #5,D4           Shift 5 bits left for MSB
            LSR.B       #5,D4           Shift 5 bits right for LSB thus EA dest reg saved
*Register complete (register # saved) next get address mode*

************************************************************
* EA Mode Table (retrieve EA addressing mode)              *
************************************************************
MODETAB
*** Mode table error checking before branching to execute **
            CMP.B       #0,D6           Invalid mode error (# < 0)
            BLT         ERROR
            CMP.B       #5,D6           Invalid mode error since modes 5 & 6:
            BEQ         ERROR           are not used in this project
            CMP.B       #6,D6
            BEQ         ERROR
            CMP.B       #7,D6           Invalid mode error (# > 7)
            BGT         ERROR
** Mode table to branch, convert addressing mode to ASCII **
            CMP.B       #0,D6           See if EA mode is Dn
            BEQ         DNMODE          Store Dn                    ;Dn Mode
            CMP.B       #1,D6           See if EA mode is An
            BEQ         ANMODE          Store An                    ;An Mode
            CMP.B       #2,D6           See if EA mode is (An)
            BEQ         ANPMODE         Store (An)                  ;An Pointer Mode
            CMP.B       #3,D6           See if EA mode is (An)+
            BEQ         ANPPMODE        Store (An)+                 ;An Pointer Plus Mode
            CMP.B       #4,D6           See if EA mode is -(An)
            BEQ         ANPMMODE        Store -(An)                 ;An Pointer Minus Mode
            CMP.B       #7,D6           See if EA mode is (xxx).W, (xxx).L, or #<data>
            BEQ         DATAMODE        Complete checks then store  ;Data modes

************************************************************
* EA Mode branch executions (code to store ASCII EA)       *
************************************************************
DNMODE
            MOVE.B      #'D',(A5)+      Store Dn addressing mode
            ADD.B       #48,D4          Convert register # to ASCII
            MOVE.B      D4,(A5)+        Store register # for formatting
            BRA         COMPLETE        EA complete so ending EA
ANMODE
            MOVE.B      #'A',(A5)+      Store An addressing mode
            ADD.B       #48,D4
            MOVE.B      D4,(A5)+
            BRA         COMPLETE
ANPMODE
            MOVE.B      #'(',(A5)+      Store (An) addressing mode:
            MOVE.B      #'A',(A5)+      can store in succession for formatting
            ADD.B       #48,D4
            MOVE.B      D4,(A5)+
            MOVE.B      #')',(A5)+
            BRA         COMPLETE
ANPPMODE
            MOVE.B      #'(',(A5)+      Store (An)+ addressing mode
            MOVE.B      #'A',(A5)+
            ADD.B       #48,D4
            MOVE.B      D4,(A5)+
            MOVE.B      #')',(A5)+
            MOVE.B      #'+',(A5)+
            BRA         COMPLETE
ANPMMODE
            MOVE.B      #'-',(A5)+      Store -(An) addressing mode
            MOVE.B      #'(',(A5)+
            MOVE.B      #'A',(A5)+
            ADD.B       #48,D4
            MOVE.B      D4,(A5)+
            MOVE.B      #')',(A5)+
            BRA         COMPLETE
****** EA mode 111, check register for addressing mode *****
*** Register 000 = (xxx).W, 001 = (xxx).L, 100 = #<data> ***
DATAMODE
            CMP.B       #0,D4           Branch to correct register # to convert to ASCII
            BEQ         ZEROMODE        Register 0 thus a Word data
            CMP.B       #1,D4           Register 1 thus a Long data
            BEQ         ONEMODE
            CMP.B       #4,D4           Register 4 thus a #<data> (determined by OpSize)
            BEQ         FOURMODE
            CMP.B       #2,D4           Register 2 thus not used in project thus ERROR
            BEQ         ERROR
            CMP.B       #3,D4           Register 3 thus not used in project thus ERROR
            BEQ         ERROR
            
ZEROMODE    MOVE.B      #'$',(A5)+
            JSR         WORDTOASCII     Convert Word data to ASCII and store
            MOVE.W      (A6)+,D5        Get ready for next data
            BRA         COMPLETE
ONEMODE     MOVE.B      #'$',(A5)+
            JSR         LONGTOASCII     Convert Long data to ASCII and store
            MOVE.L      (A6)+,D5
            BRA         COMPLETE
FOURMODE    MOVE.B      #'#',(A5)+      #<data> mode, must be hex:
            MOVE.B      #'$',(A5)+      thus signify by #$<data>
            CMP.B       #$10,D7         10 = Long
            BEQ         FOURMODELNG     BNE must therfore be a Word
FOURMODEWRD
            JSR         WORDTOASCII     #$<data> is a Word (01)
            MOVE.W      (A6)+,D5        Get ready for next data (useless operation)
            BRA         COMPLETE
FOURMODELNG
            JSR         LONGTOASCII     #$<data> is a Long (10)
            MOVE.L      (A6)+,D5
            BRA         COMPLETE
            
************************************************************
* EA Error Handling                                        *
************************************************************
ERROR
            *LEA         DISPERROR,A1    Display general error
            *MOVE.B      #14,D0
            *TRAP        #15
            MOVE.B      'F',D7          Store FF meaning there has been an error:
            MOVE.B      'F',D7          since FF is default in memory GIVE TO OPCODE (ANTHONY)
            BRA         COMPLETE        EA complete so finishing with EA
            
COMPLETE
            BRA         GETPREV         Sets original datas to data registers
DONE
*************************** EA End *************************
            *simhalt                                                         ------- TESTING
            RTS                         Returns to OpCode part of DisAssembler (Anthony)

CR          EQU         $0D
LF          EQU         $0A
DISPERROR   DC.B        'GENERAL EA ERROR',CR,LF,0

            ;END         START           ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
