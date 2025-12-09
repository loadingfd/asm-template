.model small
DATA segment
    buffer db 100 ; 0000h
    db ?
    db 100 dup(0)
    tmp db 100 dup(0) 
    array_count dw 0 ; 初始化为0
    array dw 50 dup(?)
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    lea ax, tmp
    push ax
    mov ax, offset array_count
    push ax
    lea ax, array
    push ax
    call array_input
    
    int 3
    mov ah, 4Ch
    int 21h


; 输入用空格分隔的有符号整数，存储array数组
; 输入: arr - 存储整数的数组
;       cnt - 存储整数个数的变量地址
;       buf - 存储输入字符串的缓冲区
; 输出: cnt中存储的整数个数增加
;       arr中存储输入的整数

array_input proc STDCALL arr:WORD, cnt:WORD, buf:WORD
    
    ; 初始化
    xor bx, bx ; 使用bx作为单个数字长度计数器

    ; 读取第一个字符
    mov ah, 01h
    int 21h
    mov dl, al
    
    .WHILE dl != 0Dh
        ; 重置长度计数器
        xor bx, bx
        
        ; 读取一个数
        .WHILE (dl != ' ') && (dl != 0Dh)
            mov si, buf
            mov [si + bx], dl
            inc bx

            mov ah, 01h
            int 21h
            mov dl, al
        .ENDW

        ; 如果没有读取到任何字符，跳过存储
        .IF bx != 0
            ; 结束字符串
            mov si, buf
            mov byte ptr [si + bx], 0
            
            ; 转换字符串到整数
            push bx               ; 压入长度
            push si               ; 压入字符串指针
            call ctod
            
            ; 存储结果到数组
            mov di, arr
            mov si, cnt
            mov bx, si            ; bx = cnt 地址
            mov si, [bx]          ; si = 当前数组索引
            shl si, 1             ; si = si * 2 (每个元素2字节)
            add di, si            ; di = 数组地址 + 偏移量
            mov [di], ax          ; 存储转换结果
            shr si, 1             ; 恢复 si
            inc si
            mov [bx], si          ; 增加计数
        .ENDIF

        ; 如果是空格，读取下一个字符继续
        .BREAK .IF dl == 0Dh
        mov ah, 01h
        int 21h
        mov dl, al
    .ENDW

    ret
array_input endp

ctod proc STDCALL str_ptr:WORD, str_len:WORD
    push bx
    push cx
    push dx
    push si
    push di
    mov si, str_ptr      ; SI -> 字符串开始
    mov cx, str_len      ; CX = 字符串长度
    xor ax, ax           ; AX = 0, accumulator
    jcxz end_convert     ; zero length -> return 0

    xor di, di           ; DI will be sign flag: 0 = positive, 1 = negative
    mov al, [si]
    cmp al, '-'
    je handle_negative
    cmp al, '+'
    je skip_sign
    ; otherwise first char is a digit, continue conversion
    xor ax, ax           ; reset ax to 0 before conversion
    jmp convert_loop
    
handle_negative:
    mov di, 1
    inc si
    dec cl
    jz end_convert
    xor ax, ax           ; reset ax to 0 before conversion
    jmp convert_loop
    
skip_sign:
    inc si
    dec cl
    jz end_convert
    xor ax, ax           ; reset ax to 0 before conversion
    
convert_loop:
    jcxz end_convert     ; if no more characters, done
    mov bl, [si]
    cmp bl, '0'
    jb end_convert
    cmp bl, '9'
    ja end_convert
    sub bl, '0'
    xor bh, bh
    
    ; ax = ax * 10 + digit
    push dx
    mov dx, 10
    imul dx              ; ax = ax * 10 (signed multiply)
    pop dx
    add ax, bx
    
    inc si
    loop convert_loop

end_convert:
    cmp di, 0
    jz done_convert
    neg ax
done_convert:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
ctod endp


CODE ends
end START
