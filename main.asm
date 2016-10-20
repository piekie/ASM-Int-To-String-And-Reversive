.model small
.stack 100h

.data 

	;strings
	prompt_enter_string db "Please enter a number", "$"
	prompt_this_a_string db "This is your string", "$"
	prompt_this_a_number db "This is your number", "$"

	;char
	char_newline db 10, "$"
	char_carriage_return db 13, "$"
	char_minus db "-", "$"

	;variables
	string_input db ?
	integer_value dd ?

.code

; interruptions:
; 01h - read a symbol
; 02h - write a symbol
; 09h - write out a string

start:
	; setup routine
	.386
	mov ax, @data
	mov ds, ax
	
	; printing out the prompt
	mov ah, 09h
	mov dx, offset prompt_enter_string
	int 21h
	
	call NewLine
	call NewLine
	
	;firstNum
	
	lea si, string_input
	
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
	
	mov dx, offset string_input
	int 21h
	
	call NewLine
	call NewLine
	
	mov dx, offset prompt_this_a_number
	int 21h
	
	call NewLine
	call NewLine
	
	mov esi, offset string_input
	
	; after executing of next line number as int must be in eax
	call StringToNumber
		
	mov integer_value, eax
	
	cmp ch, 1
	je .printMinus
	jmp .goNext
	
	.printMinus:
		
		mov ah, 09h
		mov dx, offset char_minus
		int 21h
			
	.goNext:
		
		mov eax, integer_value
		
		call PrintNumber
		
		; deinitial routine
		call WaitForKeypress
		
		call Finish
	
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
		mov ah, 00      	
		int 16h
   
		ret
	WaitForKeypress endp
		
	StringToNumber proc
		xor eax, eax 						; zero a "result so far"
		
		cmp byte ptr [esi], '-'				; if first char is "minus"-symbol
		je .negative
		mov ch, 0
		jmp .convert
		
	.negative:
		mov ch, 1							; set our "sign" flag to 1
		inc esi								; i++ 
		
	.convert:
		mov al, [esi]						; al = esi [ i ] 
		sub al, '0'							; get real integer value of char
		
		movzx eax, al						; move with zero extend because of moving from 16bit to 32bit
		mov ebx, 10							; get ready for multiplying
		
	.next: 
		inc esi								; i++
		cmp byte ptr[esi], '$'				; check if we are on end of the string
		je .done							; if true - done
	
		mul ebx								; eax *= 10
		mov dl, [esi]						; dl = esi[ i ]
		sub dl, '0'							; get real integer value of char
				
		movzx edx, dl						; move with zero extend because of moving from 16bit to 32bit
		
		add eax, edx						; adding value we get to result
		jmp .next							; continue
		
	.done:
		sub eax, 221						; fixme: need to remove magic number
	
		xor edx, edx						; zero a edx for correct dividing
		mov ebx, 10							; ebx = 10
		div ebx								; eax /= 10
		
		ret									; return
	StringToNumber endp
	
	

	PrintNumber proc
		mov cx, 0							; i = 0
		mov ebx, 10							; ebx = 10
		
	.loopr:
		xor edx, edx						; edx = 0. dividing routine
		
		div ebx								; eax /= ebx. we will get remainder in dx
		add dl, '0'							; adding '0' int value to lower part of dx
		push dx 							; push into stack because of wish to get correct direction of number :)
		
		inc cx								; i++
		cmp eax, 0							; if eax is 0
		jnz .loopr							; if not zero we are going to loop again
	
		mov ah, 2h							; write char interruption
		
	.print:
		pop dx								; get last pushed value into stack
		int 21h								; write dx to console
		
		dec cx								; i--
		jnz .print							; if cx != 0 then go to print loop again

		ret									; return 
	PrintNumber endp
	
	
	
	Finish proc 
		mov ah, 4ch    
		mov al, 00
		int 21h
		
		ret
	Finish endp

end start