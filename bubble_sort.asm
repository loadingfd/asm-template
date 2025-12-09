.model small

DATA segment
    array dw 9, 8, 7, 6, 5, -1, 3
    sz dw 7
    msg db "swap!!", 0Dh, 0Ah, '$'
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    mov ax, sz
    push ax
    lea si, array
    push si
    call bubble_sort
    int 3
    mov ah, 4Ch
    int 21h

; 有符号整数冒泡排序
; 输入: si - 指向待排序数组的指针
;       cl - 数组元素个数
; 输出: 数组按升序排序
bubble_sort proc STDCALL a:word, n:word 
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