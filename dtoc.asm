.model small

DATA segment
    ; 这里可以定义数据段内容
    buffer db 100 dup(0)  ; 用于存储转换后的字符串，最多5位数字加结束符
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    mov ax, 1234h        ; 示例输入数据
    lea si, buffer       ; si指向字符串缓冲区
    call dtoc            ; 调用dtoc函数

    
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

CODE ends
END START