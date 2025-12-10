; 字符串a~z排序 和 A~Z排序
; 统计字符串中各字母出现的次数，并按字母顺序输出结果
.MODEL small
.STACK 100h

.DATA
prompt      db  'Enter string: $'
inputBuf    db  255,0,255 dup('$')
numBuf      db  6 dup('$')
ten         dw  10
upperCounts dw  26 dup(0)
lowerCounts dw  26 dup(0)

.CODE
start:
    mov ax, @data
    mov ds, ax

    lea dx, prompt
    mov ah, 09h
    int 21h

    lea dx, inputBuf
    mov ah, 0Ah
    int 21h

    xor cx, cx
    mov cl, [inputBuf+1]
    mov si, OFFSET inputBuf+2

; 统计一手
.REPEAT
    mov al, [si]
    inc si

    .IF (al >= 'a') && (al <= 'z')
        sub al, 'a'
        mov bl, al
        xor bh, bh
        shl bx, 1
        inc word ptr lowerCounts[bx]
    .ELSEIF (al >= 'A') && (al <= 'Z')
        sub al, 'A'
        mov bl, al
        xor bh, bh
        shl bx, 1
        inc word ptr upperCounts[bx]
    .ENDIF

.UNTILCXZ

    call PrintCRLF

    mov cx, 26
    mov dl, 'A'
    mov si, 0
.REPEAT

    mov bx, si
    shl bx, 1
    mov ax, upperCounts[bx] ; 数量
    .IF ax > 0
        push ax
        push dx
        call PrintNChar
    .ENDIF

    inc si
    inc dl

.UNTILCXZ

    mov cx, 26
    mov dl, 'a'
    mov si, 0
.REPEAT

    mov bx, si
    shl bx, 1
    mov ax, lowerCounts[bx] ; 数量
    .IF ax > 0
        push ax
        push dx
        call PrintNChar
    .ENDIF

    inc si
    inc dl
.UNTILCXZ

    mov ax, 4C00h
    int 21h

PrintChar PROC NEAR
    mov ah, 02h
    int 21h
    ret
PrintChar ENDP

PrintCRLF PROC NEAR
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    ret
PrintCRLF ENDP

PrintNumber PROC NEAR
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    lea di, numBuf + 5
    mov byte ptr [di], '$'
    dec di

    cmp ax, 0
    jne pn_loop
    mov byte ptr [di], '0'
    jmp pn_out

pn_loop:
    xor dx, dx
    mov bx, ten
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    cmp ax, 0
    jne pn_loop
    inc di

pn_out:
    lea dx, [di]
    mov ah, 09h
    int 21h

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNumber ENDP

PrintNChar proc stdcall cc:word, num:word
    push cx
    push ax
    push dx

    mov cx, num
    xor ch, ch
    mov dx, cc
    xor dh, dh
    mov ah, 02h
    .REPEAT
        int 21h
    .UNTILCXZ

    pop dx
    pop ax
    pop cx
    ret
PrintNChar endp

END start