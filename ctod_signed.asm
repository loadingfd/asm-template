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
    push si
    call ctod

    ; 结果在 ax 中，可以用调试器查看
    ; 例如：输入 "123" -> ax = 007Bh (123)
    ;       输入 "-123" -> ax = FF85h (-123)
    ;       输入 "+456" -> ax = 01C8h (456)
    
    int 3                ; 调试断点：此时查看 ax 寄存器的值
    mov ah, 4Ch
    int 21h
    
; 将字符串转换为有符号整数函数
; 输入: str_ptr 指向 DOS 输入缓冲区（buffer），第一个字节是缓冲区最大长度，
; 第二个字节是实际输入的字符数，实际的字符串从 buffer+2 开始
; 输出: ax 中存放转换后的有符号整数（16 位）
ctod proc STDCALL str_ptr:WORD
    push bx
    push cx
    push dx
    push si
    push di
    mov si, str_ptr      ; SI -> buffer
    xor ax, ax           ; AX = 0, accumulator
    mov cl, [si + 1]     ; CL = actual length
    xor ch, ch
    add si, 2            ; SI -> first character of input
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
