.model small
DATA segment
    num1 dw ?
    num2 dw ?
    result dw ?
    str1 db 100 dup(0)
    len1 db 0
    str2 db 100 dup(0)
    len2 db 0
    op db ?
    resstr db 100 dup(0)
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    mov ah, 01h
    int 21h
    xor cx, cx
    lea si, str1
    .WHILE (al != '+' && al != '-' && al != '*' && al != '/') || (cx == 0)
        mov bx, si
        add bx, cx
        mov [bx], al
        inc cx
        mov ah, 01h
        int 21h
    .ENDW

    mov op, al

    push cx
    push si
    call ctod
    mov num1, ax

    lea si, str2
    xor cx, cx
    mov ah, 01h
    int 21h
    .WHILE (al != 0Dh && al != 0Ah)
        mov bx, si
        add bx, cx
        mov [bx], al
        inc cx
        mov ah, 01h
        int 21h
    .ENDW

    push cx
    push si
    call ctod

    mov num2, ax

    .IF op == '+'
        mov ax, num1
        add ax, num2
        mov result, ax
    .ELSEIF op == '-'
        mov ax, num1
        sub ax, num2
        mov result, ax
    .ELSEIF op == '*'
        mov ax, num1
        mul num2
        mov result, ax
    .ELSEIF op == '/'
        mov ax, num1
        div num2
        xor ah, ah
        mov result, ax
    .ENDIF
    
    mov ax, result
    lea si, resstr
    call dtoc

    lea ax, resstr
    push ax
    call show_str

    
    mov ah, 4Ch
    int 21h
    
; 将字符串转换为有符号整数函数
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

; 名称:dtoc
; 功能:将 word型数据转变为表示十进制数的字符串,字符串以0为结尾符。
; 参数:(ax)=word 型数据
; ds:si指向字符串的首地址
dtoc proc
    push ax
    push bx
    push cx
    push dx
    push bp
    
    ; 记录符号并对负数取绝对值，兼容-32768
    cwd                     ; 符号扩展到dx
    mov bp, dx              ; 保存符号
    cmp bp, 0
    jge dtoc_positive
    mov byte ptr [si], '-'
    inc si
    neg ax                  ; 对dx:ax取绝对值
    adc dx, 0
    neg dx
dtoc_positive:

    mov bx, 10
    xor cx, cx          ; cx用来计数位数

next_digit:
    xor dx, dx
    div bx              ; ax = ax / 10, dx = ax % 10
    push dx             ; 保存余数
    inc cx              ; 位数加1
    cmp ax, 0
    jne next_digit
    
    ; 此时cx中保存了十进制数的位数
    ; 栈中保存了各位数字(逆序)

pop_digits:
    pop dx              ; 弹出一位数字
    add dl, 30h         ; 转为ASCII码
    mov [si], dl        ; 保存到字符串
    inc si
    loop pop_digits     ; 循环处理下一位

    mov byte ptr [si], 0   ; 仍保留0作为逻辑结束符

    pop bp
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
  
CODE ends
end START
