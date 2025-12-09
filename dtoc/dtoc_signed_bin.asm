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
; 功能:将 word型数据转变为表示2进制数的字符串,字符串以0为结尾符。
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

    mov bx, 2
    xor cx, cx          ; cx用来计数位数

next_digit:
    xor dx, dx
    div bx              ; ax = ax / 2, dx = ax % 2
    push dx             ; 保存余数
    inc cx              ; 位数加1
    cmp ax, 0
    jne next_digit
    
    ; 此时cx中保存了2进制数的位数
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
END START
