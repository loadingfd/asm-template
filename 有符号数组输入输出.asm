.model small
DATA segment
    buffer db 100 ; 0000h
    db ?
    db 100 dup(0)
    tmp db 100 dup(0) 
    array_count dw 0 ; 初始化为0
    array dw 50 dup(?)
    debug_msg db 'Debug Breakpoint', 0Dh, 0Ah, '$'
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
    
    mov cx, array_count
    mov bx, 0
    .REPEAT
        mov ax, array[bx]
        add bx, 2

        lea si, tmp
        call dtoc
        mov ax, offset tmp
        push ax
        call show_str

        ; 输出换行
        mov dl, 0Ah
        mov ah, 02h
        int 21h
    .UNTILCXZ

    mov ah, 4Ch
    int 21h


; 输入用空格分隔的有符号整数，存储array数组
; 输入: arr - 存储整数的数组
;       cnt - 存储整数个数的变量地址
;       buf - 存储输入字符串的缓冲区
; 输出: cnt中存储的整数个数增加
;       arr中存储输入的整数

array_input proc STDCALL arr:WORD, cnt:WORD, buf:WORD
    
    .WHILE 1
        ; 重置长度计数器
        xor bx, bx
        ; 读取第一个字符
        mov ah, 01h
        int 21h
        
        ; 读取一个数
        .WHILE al != ' ' && al != 0Dh && al != 0Ah
            mov si, buf
            mov [si + bx], al
            inc bx

            mov ah, 01h
            int 21h
        .ENDW

        ; 如果没有读取到任何字符，跳过存储
        .IF bx != 0
            ; 结束字符串
            mov si, buf
            mov byte ptr [si + bx], 0
            
            ; 转换字符串到整数
            mov dl, al              ; 保存结束字符
            push bx                 ; 压入长度
            push si                 ; 压入字符串指针
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
            mov al, dl              ; 恢复结束字符
        .ENDIF

        .IF (al == 0Dh || al == 0Ah)
            .BREAK
        .ENDIF
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
