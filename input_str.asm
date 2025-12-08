.model small

DATA segment
    buffer db 100
    db ?
    db 100 dup(0)
DATA ends

.stack 400h

CODE segment
    assume cs:CODE, ds:DATA
START:
    mov ax, DATA
    mov ds, ax

    mov ax, 0A00h
    mov dx, offset buffer
    int 21h

    mov dx, 0Ah
    mov ah, 02h
    int 21h

    lea ax, [buffer + 2]
    push ax
    call show_str

    mov ax, 4C00H
    int 21H

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

