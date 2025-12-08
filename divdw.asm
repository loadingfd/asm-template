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
    push bx         ; Save bx, we will use it for temporary storage
    push ax         ; Save Low 16 bits (L) temporarily

    mov ax, dx      ; Move High 16 bits (H) to ax for division
    mov dx, 0       ; Clear dx to make it 32-bit number 0000:H
    div cx          ; H / N. Result: ax = int(H/N), dx = rem(H/N)

    mov bx, ax      ; Save the high 16 bits of the result (int(H/N))
    
    pop ax          ; Restore Low 16 bits (L) to ax. 
                    ; Now dx:ax = (rem(H/N) * 65536 + L)

    div cx          ; (rem(H/N) * 65536 + L) / N
                    ; Result: ax = low 16 bits of result, dx = remainder

    mov cx, dx      ; Move remainder to cx as per requirement
    mov dx, bx      ; Move high 16 bits of result to dx as per requirement

    pop bx          ; Restore original bx
    ret
divdw endp
    
end begin