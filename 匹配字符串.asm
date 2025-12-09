.MODEL SMALL
.STACK 100h

.DATA
    prompt1     DB 'Enter keyword: $'
    prompt2     DB 0Dh, 0Ah, 'Enter sentence: $'
    matchMsg    DB 0Dh, 0Ah, 'Match at position: $'
    noMatchMsg  DB 0Dh, 0Ah, 'No match!$'
    newline     DB 0Dh, 0Ah, '$'
    
    keyword     DB 80, ?, 80 DUP(?)    ; 关键字缓冲区
    sentence    DB 255, ?, 255 DUP(?)  ; 句子缓冲区
    hexChars    DB '0123456789ABCDEF'  ; 十六进制字符表
    output     DB 100 DUP(0)               ; 用于存储转换后的十六进制字符串

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; 显示提示并输入关键字
    LEA DX, prompt1
    MOV AH, 09h
    INT 21h
    
    LEA DX, keyword
    MOV AH, 0Ah
    INT 21h
    
    ; 显示提示并输入句子
    LEA DX, prompt2
    MOV AH, 09h
    INT 21h
    
    LEA DX, sentence
    MOV AH, 0Ah
    INT 21h
    
    ; 初始化搜索
    XOR BX, BX                  ; BX = 句子位置索引 (从0开始)
    MOV CL, sentence[1]         ; CL = 句子长度
    XOR CH, CH
    MOV DX, CX                  ; DX = 句子长度备份
    
    MOV AL, keyword[1]          ; AL = 关键字长度
    XOR AH, AH
    
    ; 检查关键字是否为空
    .IF AL == 0
        JMP NoMatch
    .ENDIF
    
    ; 检查句子是否比关键字短
    .IF DX < AX
        JMP NoMatch
    .ENDIF
    
    SUB DX, AX                  ; DX = 最大搜索位置
    INC DX
    
SearchLoop:
    .IF BX >= DX
        JMP NoMatch
    .ENDIF
    
    ; 比较关键字和句子的子串
    PUSH BX
    XOR SI, SI                  ; SI = 关键字索引
    MOV CL, keyword[1]          ; CL = 关键字长度
    XOR CH, CH
    
CompareLoop:
    .IF CX == 0
        ; 完全匹配
        POP BX
        JMP FoundMatch
    .ENDIF
    
    MOV AL, keyword[SI + 2]     ; 取关键字字符
    MOV DI, BX
    ADD DI, SI
    MOV AH, sentence[DI + 2]    ; 取句子字符
    
    .IF AL != AH
        ; 不匹配，尝试下一个位置
        POP BX
        INC BX
        JMP SearchLoop
    .ENDIF
    
    INC SI
    DEC CX
    JMP CompareLoop

FoundMatch:
    ; 显示匹配消息
    LEA DX, matchMsg
    MOV AH, 09h
    INT 21h
    
    ; 将位置转换为十六进制显示 (位置从1开始)
    inc BX
    LEA SI, output
    MOV AX, BX
    CALL dtoc
    LEA AX, output
    push AX
    CALL show_str
    
    JMP ExitProgram

NoMatch:
    ; 显示不匹配消息
    LEA DX, noMatchMsg
    MOV AH, 09h
    INT 21h

ExitProgram:
    ; 换行
    LEA DX, newline
    MOV AH, 09h
    INT 21h
    
    ; 退出程序
    MOV AH, 4Ch
    INT 21h



MAIN ENDP

; 名称:dtoc
; 功能:将 word 型数据转变为表示16进制数的字符串(4位)，字符串以0为结尾符。
; 参数:(ax)=word 型数据
; ds:si指向字符串的首地址
dtoc proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov bx, ax           ; 保存输入值
    mov di, 4            ; 处理4个16进制数字
    mov cl, 12           ; 从高位开始，每次移4位

hex_loop:
    mov dx, bx
    shr dx, cl
    and dx, 0Fh          ; 取当前半字节
    cmp dl, 9
    jbe store_digit
    add dl, 7            ; A-F 调整
store_digit:
    add dl, '0'
    mov [si], dl
    inc si
    sub cl, 4
    dec di
    jnz hex_loop

    mov byte ptr [si], 0   ; 0结束符

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
dtoc endp
   

show_str proc STDCALL str_ptr:WORD
    push ax
    push dx
    ; 找到字符串的0结尾，替换成'$'
    mov si, str_ptr
find_end:
    mov al, [si]
    cmp al, 0
    je replace_end
    inc si
    jmp find_end
replace_end:
    mov byte ptr [si], '$'

    mov dx, str_ptr
    mov ah, 09H
    int 21H

    pop dx
    pop ax
    ret
show_str endp

END MAIN