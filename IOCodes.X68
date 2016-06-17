*-----------------------------------------------------------
* Title      :Read in address
* Written by : Mark Moerdyk
* Date       : 2/15/2016
* Description: Asks user for starting and ending address
*-----------------------------------------------------------
    INCLUDE OpCodes.X68
    INCLUDE EACodes.X68
    
    ORG    $1000
START:                  ; first instruction of program
*-----------------intro message
        LEA     INTROMESSAGE,A1 Display intro message
        MOVE.B  #14, D0     TRAP task 14 calls to print data in D0 to screen
        TRAP    #15         Execute task 14
        
GET_START_ADDR
        LEA     START_ADDR_MES,A1 Display starting address message        
        MOVE.B  #14, D0     TRAP task 14 calls to print data in D0 to screen
        TRAP    #15         Execute task 14
        LEA     START_INPUT, A1 store input into memory
        MOVEQ   #2,D0       Trap task 2 scans input from console
        TRAP    #15         Execute task 2
        JSR     CORRECT_LENGTH Check to see if number entered is correct length
        CMP.B   #1,D4       If D4 equals 1, then entered value is correct length
        BEQ     CONTINUE_START_1 If correct, then continue checks with input
  
INPUT_FAIL
        LEA     FAIL_MESSAGE,A1 Display address error message if failed test
        MOVE.B  #14,D0        TRAP task 14 calls to print data in D0 to screen
        TRAP    #15         Execute task 14
        BRA     GET_START_ADDR  Go back and get new starting address
        
CONTINUE_START_1    *Start address is right length, check to see if odd address
        JSR     ASCII_2_HEX     Converts the Ascii value typed in into hex value
        MOVEA.L D3,A6       Move starting address into address A5
        JSR     ODD_TEST    Check to see if value is odd
        CMP.B   #1, D4      If D4 equals 1, then passed test.
        BEQ     CONTINUE_START_2    Passed test, last check
        BRA     GET_START_ADDR  failed test so get new starting address
        
CONTINUE_START_2
        MOVEA.L D3, A2
        JSR RANGE_TEST  check to see if value is in range
        CMP.B   #0,D4   check to see if failed range test
        BEQ     GET_START_ADDR  if equal, then get start address again
        MOVE.L  D3,D7   Move address so it can be compared to end address later
        MOVEA.L D3,A6   start address all good, so move on to getting end address
        
GET_END_ADDR
        LEA     END_ADDR_MES,A1 Print out message that asks user for end address
        MOVE.B  #14,D0
        TRAP #15    execute task 14 to display message on screen
        LEA     END_INPUT, A1  store end address input into memory
        MOVEQ   #2,D0       get ready for task 2 for trap 15
        TRAP    #15     Execute task 2        
        CLR.L   D3      Clears register D3 so ending address can be stored
        JSR     CORRECT_LENGTH Check to see if number entered is correct length
        CMP.B   #1,D4       If D4 equals 1, then entered value is correct length
        BEQ     CONTINUE_END_1 If correct, then continue checks with input
        LEA     FAIL_MESSAGE,A1 Else it failed so send fail message and ask again
        MOVE.B  #14,D0
        TRAP    #15     Display error message
        BRA     GET_END_ADDR    Get another end address from user
        
CONTINUE_END_1 
        JSR     ASCII_2_HEX    convert ascii to hex value
        MOVEA.L D3,A4   Store the ending address into A6 (A5) has start address
        JSR     ODD_TEST    check to see if end address is odd value
        CMP.B   #1, D4  compares the results. If D4 == 1 then continue  
        BEQ     CONTINUE_END_2  results are good, so continue with test
        BRA     GET_END_ADDR    did not pass, so get new end address

CONTINUE_END_2
        MOVEA.L D3, A2
        JSR     RANGE_TEST  test to see if input is in valid range
        CMP.B   #0,D4    check to see if range test failed
        BEQ     GET_END_ADDR    failed test so get new end address
        MOVEA.L D3,A4       input end address passed all tests
        JSR     START_VS_END    compares to see if start address is smaller than end address
        CMP.B   #0, D4   check if start< end results
        BEQ     GET_END_ADDR    failed test, so get new end address
        MOVEA.L D3,A4       input addresses passed all tests
        MOVE.B  #11, D0     task that clears screen
        MOVE.W  #$FF00, D1  Clears screen when D1 is set to $FF00
        TRAP    #15
*----------------------------------
*--------Jump to Op code to print all outputs
*------------------------------------    
        JSR     $2000    
        BRA     ASK_USER_FOR_INPUT
*--------------------------------------------------------------------------------------------- 
       
CORRECT_LENGTH *-----Makes sure that the adress is the length of a longword
        CLR.L   D4      Clear D4 for new check and store new result
        MOVEQ   #$0,D5  Empty out D5 to see if null input
        CMP.B   D5,D1   Check to see if input is null
        BEQ     LENGTH_FAIL
        CMPI    #$8,D1  Check to see if input is longer than a longword(8 bytes)
        BGT     LENGTH_FAIL
        MOVE.B  #$1, D4     Length is good so give a 1 to tell code that this test pass passes.
        RTS
LENGTH_FAIL
        MOVEQ   #$0,D4  tell code it failed(0 is a failed result)
        RTS
*-----------------------------------------------------------------------------------------------       
        
        
ASCII_2_HEX *-------Converts the ascii values to hex number
        CMPI.B  #$0,D1      Checks to see if all ASCII characters are converted
        BEQ     ALL_CONVERTED        If all ascii characters converted, return to procedure
        MOVE.B  (A1)+, D2   Move Ascii value in order to be checked
        CMPI.B  #$39,D2     Compare and see if Ascii value is number value
        BLE     CONVERT_NUMBER  If number do to number, else letter
        CMPI.B  #$46,D2     See if letter is upper case
        BLE     CONVERT_LETTER
CONVERT_LOWER_LETTER
        SUBI.B  #$57,D2     Convert lower case letter to hex value
        BRA     COUNTER        
CONVERT_LETTER
        SUBI.B  #$37, D2    Convert Ascii letter to hex letter
        BRA     COUNTER
CONVERT_NUMBER
        SUBI.B  #$30, D2    Convert Ascii number to hex number
        BRA     COUNTER
COUNTER
        SUBI.B  #$1,D1  Decrement counter
        ADD.B   D2,D3   Add converted hex value to rest of hex values
        CMPI.B  #$0,D1
        BEQ     ASCII_2_HEX
        ROL.L   #4, D3  
        BRA     ASCII_2_HEX
ALL_CONVERTED
        RTS
*------------------------------------------------------------------------
ODD_TEST    *------Checks to see if address is odd, as an odd address will result in memory issues
        CLR.L   D2  Clear D2 
        CLR.L   D4  Clear D4 for test result
        
        BTST    #0,D3   Check to see if last bit is 0
        BNE     ODD_TEST_FAIL
        MOVE.B  #$1, D4     Odd test passed so store 1 in D4
        RTS
ODD_TEST_FAIL
        LEA     ODD_ADDR_MES, A1    Print out odd address error message
        MOVE.B  #14,D0
        TRAP    #15
        MOVEQ   #$0, D4     set result to bad so ask again for address
        CLR.L   D3      Clear D3 for new address
        RTS
*---------------------------------------------------------------------------

RANGE_TEST  *----------Make sure input is in range of test code
        CLR.L   D4  Clear D4 for new test result
        MOVEA.L  #MIN_START_ADDR, A3     Load min start address for comparison
        CMPA.L  A3,A2   Compare address with min starting addr $7000
        BLT     TOO_LOW_ERROR
CONTINUE_RANGE_TEST        
        MOVE.L  #MAX_END_ADDR, D1   Compare address with max addr
        CMP.L   D1, D3      Compare
        BGT     TOO_HIGH_ERROR  Print out too high error message
        MOVEQ   #$1, D4     test passed so send good result back
        RTS
TOO_LOW_ERROR
        BCC CONTINUE_RANGE_TEST If carry bit is not set then address is fine
        
        LEA TOO_LOW_MES, A1 Print too low message
        MOVE.B  #14, D0
        TRAP    #15
        MOVE.B  #$0,D4
        CLR.L   D3
        RTS
        
TOO_HIGH_ERROR
        LEA TOO_LOW_MES, A1
        MOVE.B  #14, D0
        TRAP    #15
        MOVE.B  #$0,D4
        CLR.L   D3
        RTS
*----------------------------------------------------------------------
START_VS_END
        CLR.L   D4  Clear for new check
        CMP.L   D3, D7 Compare the starting address with the ending address
        BGT     START_END_ERROR     If start is bigger than end, then error message
        MOVEQ   #$1,D4  Start < End so send good response back
        RTS
START_END_ERROR
        LEA    START_END_MES, A1    Print out error message for end < start
        MOVE.B  #14,D0
        TRAP    #15
        MOVE.B  #$0,D4     Return test failed
        CLR.L   D3      Clear address for new address
        RTS
*------------------------------------------------------------------     
ASK_USER_FOR_INPUT
        LEA     ASK_USER_MES, A1    Ask the user for input from keyboard
        MOVE.B  #14,D0  
        TRAP    #15
        
        MOVE.B  #12,D0  Keyboard echo task
        MOVE.B  #0, D1  Turn off the keyboard echo
        TRAP    #15     Reset keyboard input for new input by user
        MOVE.B  #5,D0   Read a single character from the keyboard, and place it into D1
        TRAP    #15
        *Compare values of keyboard to see where to go next
        CMP.B   #$51, D1    See if input was Q
        BEQ     END_PROGRAM     go to end program and quit program
        CMP.B   #$71, D1    see if input was q
        BEQ     END_PROGRAM
        CMP.B   #$52,D1     see if input was R
        BEQ     RESTART_PROGRAM
        CMP.B   #$72,D1     see if input was r
        BEQ     RESTART_PROGRAM
        BRA     ASK_USER_FOR_INPUT  not good input = retry 
        
*------------------------------------------------------
*Restart the program by clearing all register, clear screen, and go back to the beginning of the program
RESTART_PROGRAM
        MOVE.B  #11, D0     task that clears screen
        MOVE.W  #$FF00, D1  Clears screen when D1 is set to $FF00
        TRAP    #15
        MOVE.B  #12,D0  Allow user to see input being typed
        MOVE.B  #1,D1   Makes keyboard echo visible to users
        TRAP    #15
        CLR.L   D1      clear data register D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        *Reset addresses
        MOVE.L  #$00000000,A0   Reset A0
        MOVE.L  #$00000000,A1
        MOVE.L  #$00000000,A2
        MOVE.L  #$00000000,A3
        MOVE.L  #$00000000,A4
        MOVE.L  #$00000000,A5
        MOVE.L  #$00000000,A6
        MOVE.L  #$00000000,A7
        BRA     START   Once all cleared, go back to beginning of the program
        
*-----------------------------------------------------------------------------

SETUP_FOR_OPCODE
               
        
        
        
        


* Put program code here

END_PROGRAM
    SIMHALT             ; halt simulator

* Put variables and constants here
CR  EQU $0D
LF  EQU $0A
MIN_START_ADDR  EQU     $00007000   min starting address
MAX_END_ADDR    EQU     $00FFFFFE   max ending address

INTROMESSAGE    DC.B    'Welcome to the decoder',CR,LF,0
START_ADDR_MES  DC.B    'Please enter a Start Address(CAPS please): ',0
END_ADDR_MES    DC.B    'Please enter a End Address(CAPS please): ',0
FAIL_MESSAGE    DC.B    'Sorry. Invalid address. Please try again',CR,LF,0
ODD_ADDR_MES    DC.B    'Sorry. Odd address. Please try again',CR,LF,0
TOO_HIGH_MES  DC.B    'Sorry. Entered address too high. Please try again',CR,LF,0
TOO_LOW_MES   DC.B    'Sorry. Entered address too low. Please try again',CR,LF,0
START_END_MES   DC.B    'Sorry. END address smaller then START. Please try again.',CR,LF,0 
GOOD_MESSAGE    DC.B    'Both values are good!',CR,LF,0

ASK_USER_MES    DC.B    'Press r to restart, or q to exit the program',CR,LF,0
  
BAD_BUFFER      DC.L    1
GOOD_BUFFER     DC.L    1
START_INPUT     DS.B    80      Stores the starting address input  
END_INPUT       DS.B    80      Stores the end address input 


    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
