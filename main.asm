.model small
.stack 100h

.data 

;strings

string_prompt db "Please enter a number", "$"
char_newline db 10, "$"
char_carriage_return db 13, "$"

;util
firstNum db ?
secondNum db ?
end_of_string db '$'

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
	mov dx, offset string_prompt
	int 21h
	
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

	call NewLine

	; end of string routine
	mov byte ptr [si], '$'
	
	; writing out the string
	mov ah, 09h
	mov dx, offset firstNum
	int 21h
	
	call NewLine
	
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
	endp
	
	WaitForKeypress proc
		mov ah,00       ;  Function To Read Character
		int 16h
    
		mov ah,4ch      ; Terminate and return to dos
		mov al,00
		int 21h
		ret
	endp
	
	PrintNumber proc
		
	endp
	
	StringToNumber proc
		xor eax, eax ; zero a "result so far"
		
		.top:
			movzx ecx, byte [edx] ; get a character
			inc edx ; ready for next one
			cmp ecx, '0' ; valid?
			
			jb .done
			cmp ecx, '9'
			ja .done
			
			sub ecx, '0' ; "convert" character to number
			imul eax, 10 ; multiply "result so far" by ten
			add eax, ecx ; add in current digit
			jmp .top ; until done
		
		.done:
			ret
	endp

end start