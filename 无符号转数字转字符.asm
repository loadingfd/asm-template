.model small
DATA segment
    buffer db 100
        db ?
        db 100 dup(0)
    res_str db 100 dup(0)  ; 用于存储转换后的字符串
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    ; 读取字符串输入
    mov ah, 0Ah
    mov dx, offset buffer
    int 21h

    ; 调用ctod将字符串转换为无符号整数
    mov bx, offset buffer
    push bx
    call ctod

    ; 调用dtoc将整数转换回字符串
    ; ax -> si
    lea si, res_str
    call dtoc  
    ; 换行
    mov dl, 0Ah
    mov ah, 02h
    int 21h

    ; 输出
    lea si, res_str
    push si
    int 3
    call show_str

    mov ah, 4Ch
    int 21h

; 将字符串转换为无符号整数函数
; 输入: str_ptr 指向字符串缓冲区
; 输出: ax 中存放转换后的无符号整数
ctod proc STDCALL str_ptr:WORD
    push bx
    push cx
    push dx
    mov si, str_ptr
    xor ax, ax
    mov cl, [si + 1]
    xor ch, ch
    add si, 2
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

; 名称:dtoc
; 功能:将 word型数据转变为表示十进制数的字符串,字符串以0为结尾符。
; 参数:(ax)=word 型数据
; ds:si指向字符串的首地址
dtoc proc
    push ax
    push bx
    push cx
    push dx

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

    mov byte ptr [si], 0 ; 字符串结尾符0

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
