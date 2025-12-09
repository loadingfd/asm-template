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
    
; 将16进制字符串转换为有符号整数函数
; 输入: str_ptr 指向字符串的指针
;       str_len 字符串的长度
; 输出: ax 中存放转换后的有符号整数（16 位）
ctod proc STDCALL str_ptr:WORD, str_len:WORD
    push bx
    push cx
    push dx
    push si
    push di
    mov si, str_ptr
    mov cx, str_len
    xor bx, bx           ; accumulator in BX
    jcxz end_convert

    xor di, di           ; sign flag: 0 = positive, 1 = negative
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
    jcxz end_convert
    mov dl, [si]
    cmp dl, '0'
    jb end_convert
    cmp dl, '9'
    jbe digit_decimal
    cmp dl, 'A'
    jb check_lower
    cmp dl, 'F'
    jbe digit_upper
    jmp check_lower

digit_upper:
    sub dl, 'A'
    add dl, 10
    jmp accumulate

check_lower:
    cmp dl, 'a'
    jb end_convert
    cmp dl, 'f'
    ja end_convert
    sub dl, 'a'
    add dl, 10
    jmp accumulate

digit_decimal:
    sub dl, '0'

accumulate:
    push cx
    mov cl, 4
    shl bx, cl           ; multiply accumulator by 16
    pop cx
    xor dh, dh
    add bx, dx           ; add current digit
    
    inc si
    loop convert_loop

end_convert:
    cmp di, 0
    jz move_result
    neg bx
move_result:
    mov ax, bx

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
