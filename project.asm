[org 0x100]

jmp start
oldisr:dd 0
timeisr:dd 0
characters: db "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
; select :dw 12,14,2,8,18
time:dw 0,0,0,0,0
rand: dw 0
randnum: dw 0

pos: dw 0,0,0,0,0
score :db 0 

char: db 'A','B','C','D','E'
seconds: dw 0
boxPos:dw 3920
miss: dw 0
msg1: db 'press enter to start the game ',0
msg2: db 'press escape to quit the game ',0
scoreStr:db 'score :',0
missStr:db 'Miss :',0
flagprint: db 0
exitstr:db 'your points are :',0
exitmissed: db 'you missed :',0


printMenu:

	push es
	push ax
	push cx
	push di
	mov ax, 0xb800
	mov es, ax 
	xor di, di 
	mov ax, 0x1120 
	mov cx, 2000 
	cld 
	rep stosw ; clear the whole screen

	mov si,msg1
	mov di,2130
	mov ah,05
	L1:
	lodsb
	stosw
	cmp byte[si],0
	jne L1


	mov si,msg2
	mov di,2450
	mov ah,05;
	L2:
	lodsb
	stosw
	cmp byte[si],0
	jne L2


	pop di
	pop cx
	pop ax
	pop es
	ret
	
	
printBox: ; subroutine to print box
	push ax
	push es
	push di
	mov ax,0xb800
	mov es,ax
	mov di,	3920;		
	mov word [es:di],0x07DC
	pop di
	pop es
	pop ax		
	ret	
	
	
myisrfor9:

	pusha
	push di
	push es
	mov ax,0xb800
	mov es,ax
	mov di,	[cs:boxPos]
	mov bx,0x07DC

	mov word[es:di],0x0720
	in al,0x60
	cmp al,0x4B
	je left			

	cmp al,0x4D
	je right


jmp update

	left: ;changing di
	cmp di,3840
	jbe update
	sub di,2
	jmp update

right:
	cmp di,3998
	jae update
	add di,2
	jmp update


update:

	mov word[es:di],bx
	mov word[cs:boxPos],di
	jmp exit

exit:
	;mov al,0x20
	;out 0x20,al
	
	pop es
	pop di
	
	popa
	jmp far[cs:oldisr]
	;iret
; taking n as parameter, generate random number from 0 to n nad return in the stack
randG:
   push bp
   mov bp, sp
   pusha
   cmp word [rand], 0
   jne next

  MOV     AH, 00h   ; interrupt to get system timer in CX:DX 
  INT     1AH
  inc word [rand]
  mov     [randnum], dx
  jmp next1

  next:
  mov     ax, 25173          ; LCG Multiplier
  mul     word  [randnum]     ; DX:AX = LCG multiplier * seed
  add     ax, 13849          ; Add LCG increment value
  ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
  mov     [randnum], ax          ; Update seed = return value

 next1:xor dx, dx
 mov ax, [randnum]
 mov cx, [bp+4]
 inc cx
 div cx
 shl DX,1
 
 
 mov [bp+6], dx
 popa
 pop bp
 ret 2


clrscr:
	push es
	push ax
	push cx
	push di
	mov ax, 0xb800
	mov es, ax ; point es to video base
	xor di, di ; point di to top left column
	mov ax, 0x0720 ; space char in normal attribute
	mov cx, 2000 ; number of screen locations
	cld ; auto increment mode
	rep stosw ; clear the whole screen
	pop di
	pop cx
	pop ax
	pop es

	ret

; delay1:
; push bp
; mov bp,sp
	; push cx
	; mov cx,[bp+4]
	; ;mov cx,2
	; dl1:
		; push cx
		
		; mov cx,0xFFFF
	; l2:
		; sub cx,1
		; jnz	l2
		; pop cx
		; sub cx,1
		; jnz	dl1

	; pop cx	
	; pop bp
	; ret 2


fall1:

	push ax
	push bx
	push di
	push es
	mov ax,0xb800
	mov es,ax
	mov di,[pos]
	cmp word[cs:boxPos],di
	jne C1
	; mov bx,5
	; push bx
	; call delay1
	mov word[es:di],0x07DC
	;mov word[cs:boxPos],
	inc byte[cs:score]
	mov word[cs:time],0
	jmp S1
	C1:
	
	;mov 
	inc word[cs:time]
	cmp word [cs:time],18
	jne exit1
	mov word[cs:time],0
	cmp word[pos],4000
	jle worknormal1
	inc word[cs:miss]
	S1:
	
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos],DX
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov ax,0
	mov al,[characters+bx]
	mov [char],al
	
	; mov bx,[select]
	; add bx,1
	; cmp bx,24
	; jge g
	; jmp u1
	; g:
	; mov word[select],0
	; u1:
	; mov word[select],bx
	; mov bx,[select]
	; mov ax,0
	; mov al,[characters+bx]
	; mov [char],al
	
	
	worknormal1:
	mov di,[pos]
	;mov bx,[bp+4]

	mov word [es:di],0x0720
	add di,160
	mov ax,0
	mov ah,0x07
	mov al,[char]
	mov [es:di],ax
	mov [pos],di
	exit1:
	pop es
	pop di
	pop bx
	pop ax

	ret 

fall2:

	push ax
	push bx
	push di
	push es
	mov ax,0xb800
	mov es,ax
	; mov bx,5
	; push bx
	; call delay1
	mov di,[pos +2]
	cmp word[cs:boxPos],di
	jne C2 ;continue
	mov word[es:di],0x07DC
	;mov word[cs:boxPos],0x07DC
	inc byte[cs:score]
	mov word[cs:time],0
	jmp S2
	C2:
	add word[cs:time+2],5
	cmp word [cs:time+2],18
	jle exit2
	mov word[cs:time+2],0
	cmp word[pos+2],4000
	jle worknormal2
	inc word[cs:miss]
	S2:
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos+2],DX
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov ax,0
	mov al,[characters+bx]
	mov [char+1],al
		
	worknormal2:
	mov di,[pos+2]
	;mov bx,[bp+4]

	mov word [es:di],0x0720
	add di,160
	mov ax,0
	mov ah,0x07
	mov al,[char+1]
	mov [es:di],ax
	mov [pos+2],di
	exit2:
	pop es
	pop di
	pop bx
	pop ax

	ret 


fall3:

	push ax
	push bx
	push di
	push es
	mov ax,0xb800
	mov es,ax
	
	mov di,[pos +4]
	cmp word[cs:boxPos],di
	jne C3
	
	mov word[es:di],0x07DC
	;mov word[cs:boxPos],0x07DC
	inc byte[cs:score]
	mov word[cs:time],0
	jmp S3

    C3:
	inc word[cs:time+4]
	cmp word [cs:time+4],18
	jne exit3
	mov word[cs:time+4],0
	cmp word[pos+4],4000
	jle worknormal3
	inc word[cs:miss]
	
	S3:
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos+4],DX
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char+2],al
		
	worknormal3:
	mov di,[pos +4]
	;mov bx,[bp+4]

	mov word [es:di],0x0720
	add di,160
	mov ax,0
	mov ah,0x07
	mov al,[char+2]
	mov [es:di],ax
	mov [pos+4],di
	exit3:
	pop es
	pop di
	pop bx
	pop ax

	ret 



fall4:

	push ax
	push bx
	push di
	push es
	mov ax,0xb800
	mov es,ax
	
	mov di,[pos+6]
	cmp word[cs:boxPos],di
	jne C4
	mov word[es:di],0x07DC
	;mov word[cs:boxPos],0x07DC
	inc byte[cs:score]
	mov word[cs:time],0
	jmp S4
	
	C4:
	add word[cs:time+6],6
	cmp word [cs:time+6],18
	jne exit4
	mov word[cs:time+6],0
	cmp word[pos+6],4000
	jle worknormal4
	inc word[cs:miss]
	
	S4:
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos+6],DX
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char+3],al
	
	worknormal4:
	mov di,[pos+6]
	;mov bx,[bp+4]

	mov word [es:di],0x0720
	add di,160
	mov ax,0
	mov ah,0x07
	mov al,[char+3]
	mov [es:di],ax
	mov [pos+6],di
	exit4:
	pop es
	pop di
	pop bx
	pop ax

	ret 

fall5:

	push ax
	push bx
	push di
	push es
	mov ax,0xb800
	mov es,ax
	
	mov di,[pos+8]
	cmp word[cs:boxPos],di
	jne C5
	mov word[es:di],0x07DC
	inc byte[cs:score]
	mov word[cs:time],0
	jmp S5
	
	C5:
	add word[cs:time+8],3
	cmp word [cs:time+8],18
	jne exit4
	mov word[cs:time+8],0
	cmp word[pos+8],4000
	jle worknormal5
	inc word[cs:miss]
	S5:
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos+8],DX
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char+4],al
	
	worknormal5:
	mov di,[pos+8]
	;mov bx,[bp+4]

	mov word [es:di],0x0720
	add di,160
	mov ax,0
	mov ah,0x07
	mov al,[char+4]
	mov [es:di],ax
	mov [pos+8],di
	exit5:
	pop es
	pop di
	pop bx
	pop ax

	ret 

printScore:
	push bp
	mov bp,sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	
	mov ax,0xb800
	mov es,ax
	mov ax,[bp+4]
	mov bx,10
	mov cx,0
	mov di,[bp+8]
    jmp nextDigit
MissPos:
mov byte[cs:flagprint],1
mov ax,[bp+6]
mov bx, 10
mov cx,0
mov di,[bp+10]
nextDigit:

	mov dx,0
	div bx
	add dl,0x30
	push dx
	inc cx
	cmp ax,0
	jnz nextDigit
	
	

nextpos:
pop dx
mov dh,0x06
mov [es:di],dx
add di,2
loop nextpos

cmp byte[cs:flagprint],0
je MissPos
mov byte[cs:flagprint],0

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 8



printScoreString:

push es
push ax
push si
push di

	
mov ax,0xb800
mov es,ax

mov si,scoreStr
	mov di,140
	mov ah,05;
	L3:
	lodsb
	stosw
	cmp byte[si],0
	jne L3
	
	mov si,missStr
	mov di,300
	mov ah,05
	L4:
	lodsb
	stosw
	cmp byte[si],0
	jne L4
	
	
pop di
pop si
pop ax
pop es

ret

exitMenu:
call clrscr

	push es
	push ax
	push si
	push di
	mov ax,0xb800
	mov es,ax
	mov si,exitmissed
	mov di,2130
	mov ah,05
	
	cld
	L5:
	lodsb
	stosw
	cmp byte[si],0
	jne L5
	
	push di
	mov si,exitstr
	mov di,2450
	mov ah, 0x05
	cld
	L6:
	lodsb
	stosw
	cmp byte[si],0
	jne L6
	push di
	push word[cs:miss]
	xor ax,ax
	mov al,[cs:score]
	push ax
	call printScore
	
	pop di
	pop si
	pop ax
	pop es

	ret	
	
timer:
	push ax
     push bx
	
	call printScoreString
	push word 314
	push word 154
	xor bx,bx
    mov bx, [cs:miss]
	push bx
	mov bl,[cs:score]
	push bx
	
	call printScore
	call fall1
	
	call printScoreString
	push word 314
	push word 154
	xor bx,bx
    mov bx, [cs:miss]
	push bx
	mov bl,[cs:score]
	push bx

	call printScore
	call fall2

; ;call printScore
    call printScoreString
	push word 314
	push word 154
	xor bx,bx
    mov bx, [cs:miss]
	push bx
	mov bl,[cs:score]
	push bx
	call printScore
	call fall3

    call printScoreString
	push word 314
	push word 154
	xor bx,bx
    mov bx, [cs:miss]
	push bx
	mov bl,[cs:score]
	push bx
	call printScore
	call fall4


    call printScoreString
	push word 314
	push word 154
	xor bx,bx
    mov bx, [cs:miss]
	push bx
	mov bl,[cs:score]
	push bx
	call printScore
	call fall5	
; ;call printScore
end:
	
	mov al, 0x20
	out 0x20, al 
	pop bx
	pop ax
	iret 

start:

xor ax,ax

Menu:

	call printMenu
	mov ah,0 ;keyboard intrupt (store value in ascii in al)
	int 16h
	; xor ax,ax
	; int 16h
	cmp al,13
	je startGame
	cmp al,27
	je endexit
	jmp Menu

startGame:
	call clrscr	
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos],DX
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos +2],DX
	
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos+4],DX
	
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos+6],DX
	
	sub sp,2
	push 79
	call randG
	pop DX
	mov word [pos+8],DX
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char],al
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char+1],al
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char+2],al
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char+3],al
	
	mov bx,0
	sub sp,2
	push 25
	call randG
	pop bx
	shr bx,1
	mov al,[characters+bx]
	mov [char+4],al
	
	xor ax,ax
	mov es,ax
	mov ax,[es:9*4]
	mov [oldisr],ax
	mov ax,[es:9*4+2]
	mov [oldisr+2],ax
	
	mov ax,[es:8*4]
	mov [timeisr],ax
	mov ax,[es:8*4+2]
	mov [timeisr+2],ax
	
    call printScoreString
	call printBox
	xor ax,ax
	mov es,ax
	cli
	mov word [es:9*4],myisrfor9
	mov [es:9*4+2],cs
	mov word [es:8*4], timer 
    mov [es:8*4+2], cs
	sti
	l1:
	cmp word[miss],10 ;missed condtion
	jge endexit
	
	
	jmp l1
endexit:
mov ax,[oldisr] ;unhooking
mov bx,[oldisr+2]
mov cx,[timeisr]
mov dx,[timeisr+2]
cli
mov word [es:9*4],ax
mov [es:9*4+2],bx
mov word [es:8*4],cx
mov [es:8*4+2],dx

sti
;call endprint
call exitMenu
mov ax,0x4c00	
int 21h
