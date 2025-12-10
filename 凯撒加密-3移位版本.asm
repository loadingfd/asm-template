.MODEL SMALL
.STACK 100H

.DATA
    PROMPT  DB  'Enter a string: $'
    RESULT  DB  0DH, 0AH, 'Encrypted: $'
    BUFFER  DB  100 DUP(?)  ; Buffer to store the string

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Display prompt
    MOV AH, 09H
    LEA DX, PROMPT
    INT 21H

    ; Read string
    LEA SI, BUFFER
    .REPEAT
        MOV AH, 01H
        INT 21H
        .IF AL != 0DH
            MOV [SI], AL
            INC SI
        .ENDIF
    .UNTIL AL == 0DH
    
    MOV BYTE PTR [SI], '$' ; Terminate string for output

    ; Process string (Caesar Cipher +3)
    LEA SI, BUFFER
    .WHILE BYTE PTR [SI] != '$'
        MOV AL, [SI]
        
        ; Check for Uppercase
        .IF AL >= 'A' && AL <= 'Z'
            ADD AL, 3
            .IF AL > 'Z'
                SUB AL, 26
            .ENDIF
        ; Check for Lowercase
        .ELSEIF AL >= 'a' && AL <= 'z'
            ADD AL, 3
            .IF AL > 'z'
                SUB AL, 26
            .ENDIF
        .ENDIF
        
        MOV [SI], AL
        INC SI
    .ENDW

    ; Display result label
    MOV AH, 09H
    LEA DX, RESULT
    INT 21H

    ; Display encrypted string
    LEA DX, BUFFER
    MOV AH, 09H
    INT 21H

    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
