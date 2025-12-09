.model small
DATA segment
    buffer db 100
    db ?
    db 100 dup(0)
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    mov ah, 0Ah
    mov dx, offset buffer
    int 21h

    lea si, buffer
    mov cl, [si + 1]     ; 获取实际输入的字符数
    xor ch, ch
    add si, 2            ; SI 指向实际字符串
    push cx              ; 压入长度
    push si              ; 压入字符串指针
    call ctod

    int 3                ; 调试断点：此时查看 ax 寄存器的值
    mov ah, 4Ch
    int 21h
    
; 将8进制字符串转换为有符号整数函数
; 输入: str_ptr 指向字符串的指针
;       str_len 字符串的长度
; 输出: ax 中存放转换后的有符号整数（16 位）
ctod proc STDCALL str_ptr:WORD, str_len:WORD
    push bx
    push cx
    push dx
    push si
    push di
    mov si, str_ptr      ; SI -> 字符串开始
    mov cx, str_len      ; CX = 字符串长度
    xor bx, bx           ; BX = 0, accumulator
    jcxz end_convert     ; zero length -> return 0

    xor di, di           ; DI will be sign flag: 0 = positive, 1 = negative
    mov al, [si]
    cmp al, '-'
    je handle_negative
    cmp al, '+'
    je skip_sign
    jmp convert_loop
    
handle_negative:
    mov di, 1
    inc si
    dec cx
    jz end_convert
    jmp convert_loop
    
skip_sign:
    inc si
    dec cx
    jz end_convert
    
convert_loop:
    jcxz end_convert     ; if no more characters, done
    mov al, [si]
    cmp al, '0'
    jb end_convert
    cmp al, '7'
    ja end_convert
    sub al, '0'
    xor ah, ah           ; AX = digit
    ;8086 的 SHL reg, imm 只能用立即数 1（否则报 A2070），要么写三次 SHL reg,1，要么先 mov cl,3 然后 shl reg,cl。
    shl bx, 1
    shl bx, 1
    shl bx, 1
    add bx, ax           ; BX += digit
    
    inc si
    loop convert_loop
    
end_convert:
    cmp di, 0
    jz done_convert
    neg bx
    
done_convert:
    mov ax, bx           ; move result to AX
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
ctod endp

CODE ends
end START
