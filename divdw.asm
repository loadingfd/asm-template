.model small

DATA segment
    
DATA ends

.stack 400h

.code
begin:
    mov ax, DATA
    mov ds, ax

    ; Example usage
    mov ax, 4240h
    mov dx, 000Fh
    mov cx, 0Ah
    call divdw

    mov ax, 4C00H
    int 21H
; 参数:(ax)=dword 型数据的低16位
; (dx)=dword型数据的高16位
; (cx)=除数
; 返回: (dx)=结果的高 16位, (ax)=结果的低16位
; (cx)=余数
divdw proc
    mov bx, ax  ; 因为后面要把 dx 的内容给 ax ，所以要把 ax 的内容暂存在 bx 中
    mov ax, dx  ; 将被除数的高 16 位的内容给 ax ，用来先计算 H/N
    mov dx, 0   ; 将除法 H/N 中高 16 位设置为 0 
    div cx      ; 计算 H/N，商在 ax 中，余数在 dx 中

    mov si, ax

    mov ax, bx  ; 把被除数低 16 位的内容给 ax
    div cx      ; 计算 [rem(H/N)*65536+L]/N，商在 ax 中，余数在 dx 中

    mov cx, dx  ; 把余数给 cx
    mov dx, si  ; 把结果的高 16 位给 dx
    ; 结果的低 16 位在 ax 中

    ret
divdw endp
    
end begin