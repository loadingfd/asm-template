.MODEL SMALL
.STACK 100h

.DATA
    prompt1     DB 'Enter keyword: $'
    prompt2     DB 0Dh, 0Ah, 'Enter pattern: $'
    prompt3     DB 0Dh, 0Ah, 'Enter sentence: $'
    res         DB 0Dh, 0Ah, 'Result: $'
    newline     DB 0Dh, 0Ah, '$'
    
    keyword     DB 80, ?, 80 DUP(?)    ; 关键字缓冲区
    pattern     DB 80, ?, 80 DUP(?)    ; 模式缓冲区
    sentence    DB 255, ?, 255 DUP(?)  ; 句子缓冲区
    result_str  DB 512 DUP(?)          ; 结果缓冲区
    
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
    
    ; 显示提示并输入模式 (Pattern)
    LEA DX, prompt2
    MOV AH, 09h
    INT 21h
    
    LEA DX, pattern
    MOV AH, 0Ah
    INT 21h
    
    ; 显示提示并输入句子
    LEA DX, prompt3
    MOV AH, 09h
    INT 21h
    
    LEA DX, sentence
    MOV AH, 0Ah
    INT 21h
    
    ; 初始化替换逻辑
    XOR SI, SI                  ; SI = 句子当前索引 (从0开始)
    XOR DI, DI                  ; DI = 结果字符串当前索引
    
    MOV CL, sentence[1]         ; CL = 句子长度
    XOR CH, CH
    MOV BP, CX                  ; BP = 句子总长度
    
ReplaceLoop:
    CMP SI, BP
    JAE ReplaceDone             ; 如果处理完所有字符，结束
    
    ; 检查剩余长度是否足够匹配关键字
    MOV AX, BP
    SUB AX, SI                  ; AX = 剩余长度
    MOV BL, keyword[1]
    XOR BH, BH
    CMP AX, BX
    JL CopyChar                 ; 剩余长度小于关键字长度，直接复制字符
    
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
    POP CX
    POP DI
    POP SI
    
    ; 复制 pattern 到 result_str
    LEA BX, pattern[2]
    MOV CL, pattern[1]
    XOR CH, CH
    JCXZ PatternCopied          ; 如果 pattern 为空，跳过复制
    
    PUSH SI
    XOR SI, SI
CopyPatternLoop:
    MOV AL, [BX + SI]
    MOV result_str[DI], AL
    INC DI
    INC SI
    LOOP CopyPatternLoop
    POP SI
    
PatternCopied:
    ; 跳过句子中的关键字
    MOV BL, keyword[1]
    XOR BH, BH
    ADD SI, BX
    JMP ReplaceLoop
    
MatchFailed:
    POP CX
    POP DI
    POP SI
    
CopyChar:
    ; 复制原句子的当前字符
    MOV AL, sentence[2 + SI]
    MOV result_str[DI], AL
    INC SI
    INC DI
    JMP ReplaceLoop

ReplaceDone:
    MOV result_str[DI], '$'     ; 添加字符串结束符
    
    ; 显示结果提示
    LEA DX, res
    MOV AH, 09h
    INT 21h
    
    ; 显示结果字符串
    LEA DX, result_str
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
END MAIN