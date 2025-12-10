.MODEL SMALL
.STACK 100h

.DATA
    prompt1     DB 'Enter keyword: $'
    prompt3     DB 0Dh, 0Ah, 'Enter sentence: $'
    res         DB 0Dh, 0Ah, 'Occurrences: $'
    newline     DB 0Dh, 0Ah, '$'
    cnt         DB 0                   ; 出现次数计数器
    
    keyword     DB 80, ?, 80 DUP(?)    ; 关键字缓冲区
    sentence    DB 255, ?, 255 DUP(?)  ; 句子缓冲区
    
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    ; 显示提示并输入关键字
    LEA DX, prompt1
    MOV AH, 09h
    INT 21h
    
    LEA DX, keyword
    MOV AH, 0Ah
    INT 21h
    
    ; 显示提示并输入句子
    LEA DX, prompt3
    MOV AH, 09h
    INT 21h
    
    LEA DX, sentence
    MOV AH, 0Ah
    INT 21h
    
    ; 初始化搜索逻辑
    XOR SI, SI                  ; SI = 句子当前索引 (从0开始)
    
    MOV CL, sentence[1]         ; CL = 句子长度
    XOR CH, CH
    MOV BP, CX                  ; BP = 句子总长度
    MOV cnt, 0
    
FindLoop:
    CMP SI, BP
    JAE FindDone             ; 如果处理完所有字符，结束
    
    ; 检查剩余长度是否足够匹配关键字
    MOV AX, BP
    SUB AX, SI                  ; AX = 剩余长度
    MOV BL, keyword[1]
    XOR BH, BH
    CMP AX, BX
    JL FindDone                 ; 剩余长度小于关键字长度，结束
    
    ; 尝试匹配关键字
    PUSH SI
    PUSH DI
    PUSH CX
    
    LEA BX, keyword[2]          ; BX 指向关键字内容
    LEA DI, sentence[2]         ; DI 指向句子内容
    ADD DI, SI                  ; DI 指向当前比较位置
    
    MOV CL, keyword[1]          ; 关键字长度
    XOR CH, CH
    
MatchLoop:
    MOV AL, [BX]                ; 取关键字字符
    MOV AH, [DI]                ; 取句子字符
    CMP AL, AH
    JNE MatchFailed
    INC BX                      ; 指针后移
    INC DI                      ; 指针后移
    LOOP MatchLoop
    
    ; 匹配成功
    INC cnt                     ; 出现次数加1

MatchFailed:
    POP CX
    POP DI
    POP SI
    
    INC SI                      ; 移动到下一个位置
    JMP FindLoop
    
FindDone:
    ; 显示结果提示
    LEA DX, res
    MOV AH, 09h
    INT 21h
    
    ; 打印 cnt 的值 (十进制)
    XOR AX, AX
    MOV AL, cnt
    MOV CX, 0
    MOV BX, 10
    
    CMP AX, 0
    JNE ConvertLoop
    
    ; 如果是0
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP ExitProgram

ConvertLoop:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE ConvertLoop
    
PrintLoop:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP PrintLoop

ExitProgram:
    ; 换行
    LEA DX, newline
    MOV AH, 09h
    INT 21h
    
    ; 退出程序
    MOV AH, 4Ch
    INT 21h

MAIN ENDP
END MAIN