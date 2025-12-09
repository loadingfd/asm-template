.model small
DATA segment
    buffer db 100 ; 0000h
    db ?
    db 100 dup(0)
    tmp db 100 dup(0) 
    array_count dw 0 ; 初始化为0
    msg db "ARRAY:"
    array dw 50 dup(?)
    debug_msg db 'Debug Breakpoint', 0Dh, 0Ah, '$'
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    .WHILE 1
        lea dx, buffer
        mov ah, 0Ah
        int 21h

        lea si, buffer
        mov cl, [si + 1]     ; 获取实际输入的字符数
        xor ch, ch           ; CX = 长度
        add si, 2            ; SI 指向实际字符串
        push cx              ; 压入长度
        push si              ; 压入字符串指针
        call ctod

        mov bx, offset array
        mov cx, array_count
        shl cx, 1
        add bx, cx
        mov [bx], ax
        inc array_count

        mov ax, array_count
        push ax
        lea si, array
        push si
        call bubble_sort
        
        mov cx, array_count
        mov bx, 0

        int 3
        .REPEAT
            mov ax, array[bx]
            add bx, 2

            lea si, tmp
            call dtoc
            mov ax, offset tmp
            push ax
            call show_str

            mov dl, ' '
            mov ah, 02h
            int 21h
        .UNTILCXZ
        ; 输出换行
        mov dl, 0Ah
        mov ah, 02h
        int 21h
    .ENDW

    mov ah, 4Ch
    int 21h


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

; 有符号整数冒泡排序
; 输入: si - 指向待排序数组的指针
;       cl - 数组元素个数
; 输出: 数组按升序排序
bubble_sort proc STDCALL a:word, n:word 
    .IF n == 1
        ret 4
    .ENDIF
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov dx, n          ; n
    dec dx              ; passes = n - 1
    .REPEAT
        mov cx, 0
        push dx
        .REPEAT
            mov bx, a       ; &array
            mov di, cx
            shl di, 1       ; offset = idx * 2
            add bx, di
            mov ax, [bx]
            mov si, [bx+2]
            cmp ax, si
            jle no_swap
                mov [bx], si
                mov [bx+2], ax
        no_swap:
            inc cx
        .UNTIL cx >= dx
        pop dx
        dec dx
    .UNTIL dx == 0

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4
bubble_sort endp

CODE ends
end START
