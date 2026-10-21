.model small
.stack 100h

.data

.code
start:
    mov ax, @data
    mov ds, ax
	mov bl,'a'
	mov cx,2
	outer:
	    push cx
	    mov cx, 13

	inner:
	  mov dl,bl
	  mov ah,02h
	  int 21h

	  mov dl,' '
	  mov ah,02h
	  int 21h

	  inc bl
	  dec cx
	  jnz inner
	
	  mov dl, 0dh
    	  mov ah, 02h
    	  int 21h

	  mov dl,0ah
	  mov ah,02h
	  int 21h
	  
	  pop cx
	  dec cx
	  jnz outer

    mov ax, 4c00h
    int 21h

end start