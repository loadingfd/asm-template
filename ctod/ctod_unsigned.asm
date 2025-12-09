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

    xor ax, ax
    mov al, buffer[1]
    push ax
    lea ax, buffer[2]
    push ax
    
    call ctod

    int 3
    mov ah, 4Ch
    int 21h
; 将字符串转换为无符号整数函数
; 输入: str_ptr 指向字符串缓冲区
; 输出: ax 中存放转换后的无符号整数
ctod proc STDCALL str_ptr:WORD, len:WORD
    push bx
    push cx
    push dx
    mov si, str_ptr
    mov cx, len
    xor ax, ax
    jcxz end_convert
convert_loop:
    mov bl, [si]
    cmp bl, '0'
    jb end_convert
    cmp bl, '9'
    ja end_convert
    sub bl, '0'
    mov bh, 0
    mov cx, ax
    mov ax, 10
    mul cx
    add ax, bx
    inc si
    jmp convert_loop
end_convert:
    pop dx
    pop cx
    pop bx
    ret
ctod endp

CODE ends
end START
