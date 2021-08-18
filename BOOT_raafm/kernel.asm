org 0x7e00
jmp 0x0000:start


putchar:                ; mov al, digito
    mov ah, 0x0e       
    int 10h
    ret

   
getchar:
    mov ah, 0x00
    int 16h
    ret
   
   
delchar:
    mov al, 0x08                    
    call putchar
    mov al, ' '
    call putchar
    mov al, 0x08                   
    call putchar
    ret
   
endl:
    mov al, 0x0a                    
    call putchar
    mov al, 0x0d                    
    call putchar
    ret
   
stoi:							; mov si, string
	xor cx, cx
	xor ax, ax
	.loop1:
		push ax
		lodsb
		mov cl, al
		pop ax
		cmp cl, 0				; check EOF(NULL)
		je .endloop1
		sub cl, 48				; '9'-'0' = 9
		mov bx, 10
		mul bx					; 999*10 = 9990
		add ax, cx				; 9990+9 = 9999
		jmp .loop1
	.endloop1:
	ret                         ; int sai em ax
	
prints:							; mov si, string
    mov bl,cl
	.loop:
		lodsb					; bota character em al 
		cmp al, 0
		je .endloop
		call putchar
		jmp .loop
	.endloop:
	ret

gets:                             ; mov di, string
    xor cx, cx                    ; zerar contador
    .loop1:
        call getchar
        cmp al, 0x08            
        je .backspace
        cmp al, 0x0d            
        je .done
        cmp cl, 13               ; limite da string / 13 equivale ao enter 
        je .loop1
       
        stosb
        inc cl
        call putchar
       
        jmp .loop1
        .backspace:
            cmp cl, 0           
            je .loop1
            dec di
            dec cl
            mov byte[di], 0
            call delchar
        jmp .loop1
    .done:
    mov al, 0
    stosb
    call endl
    ret

get_time:                         ; mov di, string
    xor cx, cx                    ; zerar contador
    .loop1:
        call getchar
        cmp al, 0x08             ; olha se quer deletar
        je .backspace
        cmp al, 0x0d            
        je .done
        cmp cl, 13               ; limite da string / 13 equivale ao enter 
        je .loop1
       
        stosb
        inc cl
        call putchar
       
        jmp .loop1
        .backspace:
            cmp cl, 0           
            je .loop1
            dec di
            dec cl
            mov byte[di], 0
            call delchar
        jmp .loop1
    .done:
    mov al, 0
    stosb
    
    ret

tostring:						; mov ax, int / mov di, string
	push di
	.loop1:
		cmp ax, 0
		je .endloop1
		xor dx, dx
		mov bx, 10
		div bx					; ax = 9999 -> ax = 999, dx = 9
		xchg ax, dx				; swap ax, dx
		add ax, 48				; 9 + '0' = '9'
		stosb
		xchg ax, dx
		jmp .loop1
	.endloop1:
	pop si
	cmp si, di
	jne .done
	mov al, 48
	stosb
	.done:
		mov al, 0
		stosb
		call reverse
		ret


	
reverse:						; mov si, string
	mov di, si
	xor cx, cx					; zerar contador
	.loop1:						; botar string na stack
		lodsb
		cmp al, 0
		je .endloop1
		inc cl
		push ax
		jmp .loop1
	.endloop1:
	.loop2: 					; remover string da stack				
		pop ax
		stosb
		loop .loop2
	ret	



;ax/escolhe: resultado em ax, e o resto em dx

resto_10:               ;mov ax, dividendo
    xor dx,dx           ;zera quociente
    
    mov bx,10           ; 10 como divisor
    div bx              ; divide ax por 10
    add dx,48           ; resto + '0': casting de int para char
    mov al,dl           ; preparando para print

    call putchar        ;print

    ret

random_digit:

    mov ah,0        
    int 1ah             ; clock number saved in dx

    mov ax,dx           ; clock number in ax for print
        
    call resto_10       ; ax = clock%10

    ret

print_operacao:

    call random_digit
    
    sub ax,48           ;casting de volta para int
    push ax             ;lembrar do primeiro fator

    mov di,aux
    call get_time
    
    mov al, ' '
    call putchar

    mov al, 'x'
    call putchar
    
    mov al, ' '
    call putchar

    call random_digit
    sub ax,48                 ;casting de volta para int
    xor bx,bx
    pop bx
    mul bl                    ; ax = al*bl  

    mov di,resposta_certa     ;print resposta da conta
    call tostring

    mov al, ' '
    call putchar

    mov al, '='
    call putchar
    
    mov al, ' '
    call putchar

    mov al,10
    call putchar

    ret

confere_resposta:       

    mov si,resposta_user
    call stoi 
    
    push ax                  ; salva resposta_user

    mov si,resposta_certa
    call stoi                ; resposta certa em ax

    pop bx                   ;pega resposta_user

    cmp ax,bx
    je .acertou

    mov si,resposta_certa
    call prints

    call endl
    

    .errou:
        mov al,'e'
        call putchar
        
        mov al,'r'
        call putchar
        mov al,'r'
        call putchar
        
        mov al,'o'
        call putchar

        mov al,'u'
        call putchar
        
        mov si,msgtwo
        call prints

    jmp .end_checar

    .acertou:

        mov si,resposta_certa
        call prints

        call endl

        mov si,msgone
        call prints
        
        mov si,N_acertos
        call stoi
        inc ax 
        mov di,N_acertos
        call tostring
        mov si,N_acertos
        call prints 
             
        mov si,msgtwo
        call prints
        jmp .end_checar

    .end_checar:
        ret

data:
	string times 13 db 0
	aux times 2 db 0
    msgone db "Acertos: ", 0    
    msgtwo db ", ENTER para continuar.",0
    
    N_acertos times 2 db 0
    resposta_user times 3 db 0
    resposta_certa times 3 db 0
    abacate times 3 db 0
start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    mov ah,1h
    int 21h
    mov dl,al

    ;set video mode
    mov ah, 00h
    mov al, 00h
    int 10h
    
    xor ax,ax               
    push ax           ;contador loop armazenado na stack
    push ax           ;contador acertos armazenado na stack

   .for_main:

        mov di,aux          ;apenas pra clock andar
        call gets           

        pop ax              ; pega valor do contador 
        add ax,1            ; incrementa ele 
        cmp ax, 10          ; if(terminou loop)
        je .end_main
        push ax             ; guarda valor do contador no loop

        call print_operacao

        mov di, resposta_user
        call gets

        call confere_resposta       

        call endl

        jmp .for_main

    .end_main:
        mov al,'f'
        call putchar
        mov al,'i'
        call putchar
        mov al,'m'
        call putchar
        
        
jmp $