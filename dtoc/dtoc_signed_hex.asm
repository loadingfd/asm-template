.model small

DATA segment
    buffer db 100 dup(0)  ; 用于存储转换后的字符串
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    mov ax, -1234        ; 示例输入数据
    lea si, buffer       ; si指向字符串缓冲区
    call dtoc            ; 调用dtoc函数

    mov ax, offset buffer ; 将字符串地址加载到dx以便查看结果
    push ax
    call show_str

    mov ax, 4C00H
    int 21H

    
; 名称:dtoc
; 功能:将 word 型数据转变为表示16进制数的字符串(4位)，字符串以0为结尾符。
; 参数:(ax)=word 型数据
; ds:si指向字符串的首地址
dtoc proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov bx, ax           ; 保存输入值
    mov di, 4            ; 处理4个16进制数字
    mov cl, 12           ; 从高位开始，每次移4位

hex_loop:
    mov dx, bx
    shr dx, cl
    and dx, 0Fh          ; 取当前半字节
    cmp dl, 9
    jbe store_digit
    add dl, 7            ; A-F 调整
store_digit:
    add dl, '0'
    mov [si], dl
    inc si
    sub cl, 4
    dec di
    jnz hex_loop

    mov byte ptr [si], 0   ; 0结束符

    pop di
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
END START