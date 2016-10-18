.model small
.stack 100h

.data 

;strings
prompt_enter_string db "Please enter a number", "$"
prompt_this_a_string db "This is your string", "$"
prompt_this_a_number db "This is your number", "$"

char_newline db 10, "$"
char_carriage_return db 13, "$"

;util
firstNum db ?
secondNum db ?
end_of_string db '$'

firstNumInt dd ?

.code

; interruptions:
; 01h - read a symbol
; 09h - write out a string

start:
	; setup routine
	.386
	mov ax, @data
	mov ds, ax
	
	; main part
	
	; printing out the prompt
	mov ah, 09h
	mov dx, offset prompt_enter_string
	int 21h
	
	call NewLine
	call NewLine
	
	;firstNum
	
	lea si, firstNum
	
inp:
	mov ah, 01h
	int 21h
	
	mov [si], al
	inc si
	
	cmp al, 0dh
	jnz inp

;inp

	; end of string routine
	mov byte ptr [si], '$'
	
	call NewLine
	call NewLine
	
	mov ah, 09h
	
	mov dx, offset prompt_this_a_string
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset firstNum
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset prompt_this_a_number
	int 21h
	
	call NewLine
	call NewLine
	
	mov esi, offset firstNum
	; after executing of next line number as int must be in eax
	call StringToNumber
	
	call PrintNumber
	
	; deinitial routine
	call WaitForKeypress
	
	
	NewLine proc
		mov dx, offset char_newline
		mov ah, 09h
		int 21h
		
		mov dx, offset char_carriage_return
		mov ah, 09h
		int 21h
		ret
	NewLine endp
	
	WaitForKeypress proc
		mov ah,00       ;  Function To Read Character
		int 16h
    
		mov ah,4ch      ; Terminate and return to dos
		mov al,00
		int 21h
		ret
	WaitForKeypress endp
	
	StringToNumber proc
			xor eax, eax ; zero a "result so far"
			
			cmp byte ptr [esi], '-'
			je .negative
			mov ch, 0
			jmp .convert
			
		.negative:
			mov ch, 1
			inc esi
			
		.convert:
			mov al, [esi]
			sub al, 48
			
			movzx eax, al
			mov ebx, 10
			
		.next: 
			inc esi
			cmp byte ptr[esi], '$'
			je .done
			
			mul ebx
			mov dl, [esi]
			sub dl, 48
			movzx edx, dl
			
			add eax, edx
			jmp .next
			
		.done:
			cmp ch, 1
			je .negativize
			jmp .return
			
		.negativize:
			neg eax
		
		.return:
			ret
	StringToNumber endp
	
	PrintNumber proc
		mov cx, 0
		mov ebx, 10
		
	.loopr:
		xor edx, edx
		div ebx
		add dl, '0'
		push dx 
		
		inc cx
		cmp eax, 0
		jnz .loopr
		
	.print:
		pop dx
		mov ah, 2h
		int 21h
		
		dec cx
		jnz .print

		ret
	PrintNumber endp

end start