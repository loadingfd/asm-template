.MODEL small
.STACK 100h

.DATA
prompt      db  'Enter string: $'
inputBuf    db  255,0,255 dup('$')
upperTitle  db  0Dh,0Ah,'Uppercase counts:',0Dh,0Ah,'$'
lowerTitle  db  0Dh,0Ah,'Lowercase counts:',0Dh,0Ah,'$'
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

    lea dx, upperTitle
    mov ah, 09h
    int 21h

    mov cx, 26
    mov dl, 'A'
    mov si, 0
.REPEAT
    mov dh, dl
    call PrintChar
    mov dl, ':'
    call PrintChar
    mov dl, ' '
    call PrintChar

    mov bx, si
    shl bx, 1
    mov ax, upperCounts[bx]
    call PrintNumber

    call PrintCRLF

    mov dl, dh
    inc dl
    inc si
.UNTILCXZ

    lea dx, lowerTitle
    mov ah, 09h
    int 21h

    mov cx, 26
    mov dl, 'a'
    mov si, 0
.REPEAT
    mov dh, dl
    call PrintChar
    mov dl, ':'
    call PrintChar
    mov dl, ' '
    call PrintChar

    mov bx, si
    shl bx, 1
    mov ax, lowerCounts[bx]
    call PrintNumber

    call PrintCRLF

    mov dl, dh
    inc dl
    inc si
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

END start