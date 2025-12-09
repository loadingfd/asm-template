DATA SEGMENT
buffer DB 100        ; 最大输入长度 100
       DB ?         ; DOS 返回实际长度
       DB 100 DUP(?) ; 字符存储区
       msg db 'damn bro $'
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX

    ; 调用 DOS 功能 0Ah 输入字符串
    MOV AH, 0Ah
    LEA DX, buffer   ; DX = 缓冲区地址
    INT 21h

    ; 处理字符串结尾，添加 '$'
    LEA BX, buffer
    MOV AL, [BX+1]   ; 获取实际输入长度
    MOV AH, 0
    MOV SI, AX
    MOV BYTE PTR [BX+SI+2], '$' ; 在字符串末尾添加 '$'

    ; 输出换行
    MOV DL, 0Ah
    MOV AH, 02h
    INT 21h

    ; 处理
    lea bx, buffer
    xor cx, cx
    mov cl, [bx+1] ; 获取实际输入长度
    lea si, [bx+2] ; 指向实际输入字符开始处
    .REPEAT
        mov al, [si]
        .IF (al >= 'a') && (al <= 'z')
            sub al, 20h
            mov [si], al
        .ENDIF
        inc si
    .UNTILCXZ

    ; 输出输入的字符串
    MOV AH, 09h
    LEA DX, buffer + 2 ; DX 指向实际字符开始处
    INT 21h

    ; 退出程序
    MOV AH, 4Ch
    INT 21h
CODE ENDS
END START