.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc 

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Tetris",0
area_width EQU 980
area_height EQU 700
area DD 0

numar DD 0
stare dd 0


arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
lung dw 50 
gros dw 30
p dd 3
format db "%d ",0
format1 db 13,10,0
format_piesa db "poz este %d", 13,10,0
format2 db "aici %d",13,10,0   
nr dd 0
x dd 0
y dd 100

x1 dd 500
y1 dd 670	;coordonatele primei sageti
left_arrow_y1 dd 500
left_arrow_y2 dd 540 
left_arrow_x1 dd 670
left_arrow_x2 dd 740

x2 dd 500
y2 dd 770	;coordonatele celei de-a doua sageti 
right_arrow_y1 dd 500
right_arrow_y2 dd 540
right_arrow_x1 dd 770
right_arrow_x2 dd 830

x3 dd 540 
y3 dd 735
down_arrow_y1 dd 540 
down_arrow_y2 dd 600
down_arrow_x1 dd 730 
down_arrow_x2 dd 790

piesa_x dd 305
piesa_y dd 20

position_piesa dd 0

restart_x1 dd 755 
restart_x2 dd 860
restart_y1 dd 150
restart_y2 dd 180


symbol_width EQU 10
symbol_height EQU 20
dim_piesa dd 30 
random dd 0
random_color dd 0
red dd 0FF0000h
blue dd 00000FFh
green dd 00FF00h
yellow dd 0FFFF00h
color dd 0FF0000h
game_area db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;;matricea de joc 
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
game_area_width dd 20 ;coloane matrice joc 
game_area_height dd 22 ;linii matrice joc
x_game dd 0 
y_game dd 5
include piese1.inc
include digits.inc
include letters.inc
include matrice.inc
include sagetiSD.inc
include sageataJOS.inc
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y


make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A' ; se obtine indexul din vectorul de litere 
	lea esi, letters ;incarca in esi adresa literelor
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9' ;daca e intre 0 si 9 afisam cifra, daca nu, afisam spatiu
	jg make_space
	sub eax, '0'
	lea esi, digits 
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters ;in esi incarca literele
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0FFFFFFh
	push area
	call memset
	add esp, 12
	
	jmp afisare_litere 
draw_line_horizontal proc

    push ebp
	mov ebp, esp
	sub esp,4
	pusha
	
	mov ecx,[EBP+8] ;lungime linie
	draw_line:
    mov eax,[EBP+12] ;y
    mov ebx,area_width
    mul ebx
	mov edx,ecx
	add edx,[EBP+16] ;x
    add eax,edx
    shl eax,2
	add eax,area
	
	mov [EBP-4],ecx
	shl ebx,2
	
	mov ecx,[EBP+20] ;grosime
	loop_g:
    mov edx,[EBP+24]
	mov dword ptr [eax],edx ;culoare
	add eax,ebx
	loop loop_g
	
	mov ecx,[EBP-4]
	
	loop draw_line
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw_line_horizontal endp

draw_line_horizontal_macro macro lung , y , x , gros , color
	push color
	push gros
	push x
	push y
	push lung
	call draw_line_horizontal
	add esp, 20
endm 

still_in_game proc
	push ebp 
	mov ebp, esp 
	lea esi, game_area
	add esi, game_area_width
	
	mov eax, 1
	
	mov ecx, game_area_width
	linie:
		cmp byte ptr [esi],0 
		jne final
		inc esi 
		dec ecx 
		cmp ecx, 0		
	jg linie
	jmp final1 
	
	final:
	mov eax, 0 

	final1:
	mov esp, ebp
	pop ebp
	ret
still_in_game endp

check_space proc 

	push ebp 
	mov ebp, esp 
	lea esi, piese 
	mov eax, 9
	mov ebx, [ebp+12]
	mul ebx 
	mov ebx, 1
	add esi, eax 
	
	mov edi, [esp+8]
	
	primul_elem:
	cmp byte ptr [edi], 0
	jg et1 
	inc edi 
	inc esi
	jmp al_doilea_elem
	
	et1: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_doilea_elem:
	cmp byte ptr [edi], 0
	jg et2
	inc edi 
	inc esi
	jmp al_treilea_elem
	
	et2: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_treilea_elem:
	cmp byte ptr [edi], 0
	jg et3
	inc edi 
	inc esi
	jmp al_patrulea_elem
	
	et3: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_patrulea_elem:
	add edi,game_area_width
	sub edi,3
	cmp byte ptr [edi], 0
	jg et4
	inc edi 
	inc esi
	jmp al_cincilea_elem
	
	et4: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_cincilea_elem:
	cmp byte ptr [edi], 0
	jg et5
	inc edi 
	inc esi
	jmp al_saselea_elem
	
	et5: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_saselea_elem:
	cmp byte ptr [edi], 0
	jg et6
	inc edi 
	inc esi
	jmp al_saptelea_elem
	
	et6: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_saptelea_elem:
	add edi,game_area_width
	sub edi,3
	cmp byte ptr [edi], 0
	jg et7
	inc edi 
	inc esi
	jmp al_optelea_elem
	
	et7: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_optelea_elem:
	cmp byte ptr [edi], 0
	jg et8
	inc edi 
	inc esi
	jmp al_noualea_elem
	
	et8: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	
	al_noualea_elem:
	cmp byte ptr [edi], 0
	jg et9
	inc edi 
	inc esi
	jmp the_end 
	
	et9: 
	cmp byte ptr [esi],0 
	jg final 
	inc edi 
	inc esi 
	mov ebx, 1
	jmp the_end
	
	final:
	mov ebx, 0
	jmp the_end 
	
	the_end:
	mov esp, ebp
	pop ebp
	ret
check_space endp 

check_space_macro macro position_piesa,nr
	push nr
	push position_piesa
	call check_space
	add esp, 8
endm 
deseneaza_piesa proc 
	push ebp
	mov ebp, esp
	
	lea esi, piese 
	mov eax, 9
	mov ebx, [ebp+16]
	mul ebx 
	add esi, eax 
	
	mov edi, [ebp+20]
	cmp edi, 1
	je pune_rosu
	cmp edi, 2
	je pune_albastru 
	cmp edi, 3 
	je pune_verde 
	cmp edi, 4
	je pune_galben
	
	pune_rosu:
	mov edi, red 
	jmp desen 
	pune_albastru:
	mov edi, blue 
	jmp desen
	pune_verde:
	mov edi, green
	jmp desen 
	pune_galben:
	mov edi, yellow
	jmp desen
	
	
	desen:
	mov eax, [ebp+8] ;y
	mov ebx, [ebp+12] ;x
	mov ecx, p
	 linii:
	push ecx 
	mov ecx, p
		coloane:
		cmp byte ptr [esi],1
		je patrat 
	jmp next_bit
	
	patrat:
	draw_line_horizontal_macro dim_piesa, eax, ebx, dim_piesa, edi 
	
	next_bit:
	add ebx, dim_piesa
	
	inc esi 
	loop coloane
	add eax,dim_piesa
	
	mov ebx, [ebp+12]
	pop ecx
	loop linii
	
	mov esp, ebp
	pop ebp 
	ret 
deseneaza_piesa endp 


deseneaza_piesa_macro macro y , x, nr,random_color
	push random_color
	push nr 
	push x
	push y
	call deseneaza_piesa
	add esp, 16
endm

pune_piesa proc 
	push ebp
	mov ebp, esp 
	
	lea esi, piese
	mov eax,9
	mov ebx,[esp+12]
	mul ebx 
	add esi,eax
	
	mov edi, [esp+8]
	
	mov ebx, [esp+16]
	
	urmatoarea1:
	cmp byte ptr [esi],0 
	je zero1
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp urmatoarea2
	zero1:
	inc esi
	inc edi
	
	urmatoarea2:
	cmp byte ptr [esi],0 
	je zero2
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp urmatoarea3
	zero2:
	inc esi
	inc edi
	
	urmatoarea3:
	cmp byte ptr [esi],0 
	je zero3
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp et1
	zero3:
	inc esi
	inc edi
	
	et1:
	add edi,game_area_width
	sub edi,3
	urmatoarea4:
	cmp byte ptr [esi],0 
	je zero4
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp urmatoarea5
	zero4:
	inc esi
	inc edi
	
	urmatoarea5:
	cmp byte ptr [esi],0 
	je zero5
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp urmatoarea6 
	zero5:
	inc esi
	inc edi
	
	urmatoarea6:
	cmp byte ptr [esi],0 
	je zero6
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp et
	zero6:
	inc esi
	inc edi
	
	et:
	add edi,game_area_width
	sub edi,3
	
	urmatoarea7:
	cmp byte ptr [esi],0 
	je zero7
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp urmatoarea8
	zero7:
	inc esi
	inc edi
	
	urmatoarea8:
	mov eax,0
	cmp byte ptr [esi],0 
	je zero8
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp urmatoarea9
	zero8:
	inc esi
	inc edi
	
	urmatoarea9:
	cmp byte ptr [esi],0 
	je zero9
	mov byte ptr [edi],bl 
	inc esi
	inc edi
	jmp final
	zero9:
	inc edi
	inc esi 
	
	
	final:
	mov esp, ebp
	pop ebp 
	ret 
pune_piesa endp
    
pune_piesa_macro macro position_piesa,random,random_color 
	push random_color 
	push random 
	push position_piesa
	call pune_piesa 
	add esp,12
endm

draw_game_area proc 
	push ebp 
	mov ebp, esp 
	
	lea esi, game_area
	mov eax, game_area_height
	mov ebx, game_area_width
	mul ebx
	mov ecx, eax
	
	mov eax,y_game
	mov ebx,x_game
	mov ecx, game_area_height
	loop_linii:
	push ecx
	mov ecx,game_area_width
		loop_coloane:
		cmp byte ptr [esi],0
		je patratel_negru
		cmp byte ptr [esi],1 
		je patratel_rosu 
		cmp byte ptr [esi],2 
		je patratel_albastru 
		cmp byte ptr [esi],3
		je patratel_verde 
		cmp byte ptr [esi],4 
		je patratel_galben
		jmp next_bit
	    
		patratel_negru:	
	    draw_line_horizontal_macro dim_piesa,ebx,eax,dim_piesa,0
		jmp next_bit
		
		patratel_rosu:
		draw_line_horizontal_macro dim_piesa, ebx, eax, dim_piesa, 0FF0000h
		jmp next_bit
		
		patratel_albastru:
		draw_line_horizontal_macro dim_piesa, ebx, eax, dim_piesa, 00000FFh
		jmp next_bit
		
		patratel_verde:
		draw_line_horizontal_macro dim_piesa, ebx, eax, dim_piesa, 000FF00h
		jmp next_bit
		
		patratel_galben:
		draw_line_horizontal_macro dim_piesa, ebx, eax, dim_piesa, 0FFFF00h
	    jmp next_bit
	next_bit:
	add eax,dim_piesa
	
	inc esi
	;loop loop_coloane
	dec ecx 
	cmp ecx, 0
	jg loop_coloane
	add ebx,dim_piesa
	mov eax, y_game
	pop ecx 
	dec ecx 
	cmp ecx, 0
	jg loop_linii
	;loop loop_linii

	mov esp, ebp
	pop ebp 
	ret 
draw_game_area endp
 
draw_line_vertical proc
    push ebp
	mov ebp, esp
	sub esp,4
	pusha
	
	
	mov ecx,[EBP+8] ;lungime linie
	draw_line:
    mov eax,[EBP+12] ;y
	add eax,ecx
    mov ebx,area_width
    mul ebx
	add eax,[EBP+16] ;x

    shl eax,2
	add eax,area
	
	mov [EBP-4],ecx
	shl ebx,2
	
    mov ecx,[EBP+20] ;grosime
	loop_g:
    mov edx,[EBP+24]
	mov dword ptr [eax],edx ;culoare
	add eax,ebx
	loop loop_g
	
	mov ecx,[EBP-4]
	
	loop draw_line
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw_line_vertical endp

    draw_line_vertical_macro macro lung , y , x , gros , color
	push color
	push gros
	push x
	push y
	push lung
	call draw_line_vertical
	add esp, 20
endm


evt_click:
	stanga:
	mov eax,[ebp+arg2]
	mov ebx,[ebp+arg3]
	cmp eax, left_arrow_x1
	jl dreapta
	cmp eax, left_arrow_x2
	jg dreapta
	cmp ebx, left_arrow_y1
	jl dreapta
	cmp ebx, left_arrow_y2
	jg dreapta
	jmp click_stanga
	
	dreapta:	
	cmp eax, right_arrow_x1
	jl jos
	cmp eax, right_arrow_x2
	jg jos 
	cmp ebx, right_arrow_y1
	jl jos
	cmp ebx, right_arrow_y2
	jg jos
	jmp click_dreapta 
	
	jos:
	cmp eax,down_arrow_x1
	jl restart
	cmp eax, down_arrow_x2
	jg restart
	cmp ebx, down_arrow_y1
	jl restart
	cmp ebx, down_arrow_y2
	jg restart
	jmp click_jos
	
	restart:
	cmp eax, restart_x1
	jl final_draw
	cmp eax, restart_x2 
	jg final_draw
	cmp ebx, restart_y1 
	jl final_draw
	cmp ebx, restart_y2 
	jg final_draw 
	jmp click_restart
	
	click_stanga:
	mov eax,piesa_x
	sub eax,dim_piesa
	cmp eax, 4
	mov ebx, position_piesa
	sub ebx,1
	mov position_piesa, ebx 
	je final_draw
	mov piesa_x,eax 
	jmp final_draw
	
	click_dreapta:
	mov eax,piesa_x
	add eax,dim_piesa
	cmp eax, 570
	mov ebx, position_piesa
	add ebx, 1
	mov position_piesa, ebx 
	je final_draw
	mov piesa_x,eax 
	jmp final_draw
	
	click_restart:
	lea esi, game_area
	mov eax, game_area_height
	mov ebx, game_area_width
	mul ebx
	mov ecx, eax
	
	mov ecx, game_area_height
	loop_lin:
	push ecx
	mov ecx,game_area_width
		loop_col:
		mov byte ptr [esi],0
	inc esi
	dec ecx 
	cmp ecx, 0
	jg loop_col
	pop ecx 
	dec ecx 
	cmp ecx, 0
	jg loop_lin
	jmp final_draw
	
	click_jos:
	
	
evt_timer:
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0FFFFFFh
	push area
	call memset
	add esp, 12
	
	call make_orizontal_arrows
	call make_down_arrow
	call draw_game_area
	call still_in_game
	cmp eax, 0
	je end_game
	deseneaza_piesa_macro piesa_y,piesa_x, random,random_color
	
	
	cmp stare, 0
	jne verifica_spatiu_liber 

	
	cmp random_color,1
	je mred 
	cmp random_color,2
	je mblue 
	cmp random_color,3 
	je mgreen 
	cmp random_color,4
	je myellow
	jmp before_random
	
	mblue:
	push eax
	mov eax, random 
	inc eax 
	mov random, eax 
	pop eax 
	push eax 
	mov eax, blue 
	mov color, eax 
	pop eax 
	jmp before_random
	
	mred:
	push eax
	mov eax, random 
	inc eax 
	mov random, eax 
	push eax 
	pop eax 
	mov eax, red
	mov color, eax
	pop eax 
	jmp before_random
	
	mgreen:
	push eax
	mov eax, random 
	inc eax 
	mov random, eax 
	pop eax 
	push eax 
	mov eax, green
	mov color, eax
	pop eax 
	jmp before_random
	
	myellow:
	push eax
	mov eax, random 
	inc eax 
	mov random, eax 
	pop eax 
	push eax 
	mov eax, yellow
	mov color, eax
	pop eax 
	mov random_color, 0
	
	before_random: 
	push eax 
	mov edx, 0
	mov eax, random ;random modulo numarul de piese 
	push ebx 
	mov ebx, 12
	div ebx 
	pop ebx 
	pop eax 
	mov random, edx
	push eax 
	mov eax, random_color
	inc eax 
	mov random_color,eax 
	pop eax 
	mov piesa_y, 30
	mov piesa_x, 305
	
	
	lea esi, game_area
	
	mov ecx, game_area_height
	loop_linii: 

		push ecx 
		mov ecx, game_area_width
		push ecx 
		push	offset format1 
		call printf 
		add esp, 4
		pop ecx 
		loop_coloane:
			mov eax,0 
			mov al, byte ptr [esi]
			push ecx 
			push eax  
			push offset format 
			call printf 
			add esp, 8 
			pop ecx 
	inc esi 
	loop loop_coloane
		pop ecx 
	loop loop_linii
	;popa
	mov stare,1
	
	verifica_spatiu_liber:
	mov ebx,0 
	mov ecx, position_piesa
	add ecx, game_area_width
	check_space_macro ecx, random
	cmp ebx, 1 
	jne coboara_piesa
	jmp coboara_piesa_pana_jos
	
	coboara_piesa:
	mov eax,piesa_y
	add eax, 30
	mov piesa_y,eax
	mov ebx, position_piesa
	sub ebx, game_area_width
	mov position_piesa, ebx
	
	jmp reset_stare
		
	jmp afisare_litere
	
	coboara_piesa_pana_jos:
	mov eax,piesa_y
	add eax, 30
	cmp eax, 600
    jge reset_stare
	mov piesa_y,eax
	mov ebx, position_piesa
	add ebx, game_area_width
	mov position_piesa, ebx 
		
	jmp afisare_litere

	reset_stare: ;generam piesa random
	
	mov ecx, position_piesa
	add ecx, game_area_width
	mov position_piesa, ecx 
	pune_piesa_macro position_piesa, random,random_color  
	mov stare,0
	lea ecx, game_area
	add ecx,10
	mov position_piesa,ecx 
	pop eax 

	
afisare_litere:
	
	draw_line_horizontal_macro 610, 660, 0, 5, 0080FF00h
	
	draw_line_vertical_macro 659,0,606,1,0080FF00h
	draw_line_vertical_macro 659,0,607,1,0080FF00h
	draw_line_vertical_macro 659,0,608,1,0080FF00h
	draw_line_vertical_macro 659,0,609,1,0080FF00h
	draw_line_vertical_macro 659,0,610,1,0080FF00h
	
	draw_line_vertical_macro 659,0,0,1,0080FF00h
	draw_line_vertical_macro 659,0,1,1,0080FF00h
	draw_line_vertical_macro 659,0,2,1,0080FF00h
	draw_line_vertical_macro 659,0,3,1,0080FF00h
	draw_line_vertical_macro 659,0,4,1,0080FF00h
	jmp final_draw
	
end_game:
	make_text_macro 'G',area, 730,100
	make_text_macro 'A',area, 745,100
	make_text_macro 'M',area, 760,100
	make_text_macro 'E',area, 775,100
	
	make_text_macro 'O',area, 815,100
	make_text_macro 'V',area, 830,100
	make_text_macro 'E',area, 845,100
	make_text_macro 'R',area, 860,100
	
	
	make_text_macro 'R',area, 755,150
	make_text_macro 'E',area, 770,150
	make_text_macro 'S',area, 785,150
	make_text_macro 'T',area, 800,150
	make_text_macro 'A',area, 815,150
	make_text_macro 'R',area, 830,150
	make_text_macro 'T',area, 845,150
	
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp



make_orizontal_arrows proc
	push ebp
	mov ebp,esp
	
	lea esi, sageti_orizontale
	mov eax, sageti_height ;11
	mov ebx, sageti_width ;19
	mul ebx
	mov ecx, eax
	
	mov eax,y1
	mov ebx,x1
	mov ecx, sageti_height
	loop_linii:
	push ecx
	mov ecx,sageti_width
		loop_coloane:
		cmp byte ptr [esi],1
		je patratel
	draw_line_horizontal_macro 4,ebx,eax,4,0FFFFFFh
	jmp next_bit
	patratel:
	draw_line_horizontal_macro 4,ebx,eax,4,00d3472h
	
	next_bit:
	add eax,4
	
	inc esi
	loop loop_coloane
	add ebx,4
	mov eax, y1
	pop ecx 
	loop loop_linii 
	
	add esi, 209
	
	mov eax, sageti_width
	mov ebx, sageti_height
	mul ebx
	mov ecx, eax
	
	mov eax,x2
	mov ebx,y2
	mov ecx, sageti_width
	loop_linii1:
	push ecx
	mov ecx,sageti_height
		loop_coloane1:
		cmp byte ptr [esi],1
		je patratel1
	draw_line_horizontal_macro 4,eax,ebx,4,0FFFFFFh
	jmp next_bit1
	patratel1:
	draw_line_horizontal_macro 4,eax,ebx,4,0d3472h
	
	next_bit1:
	add eax,4
	
	inc esi
	loop loop_coloane1
	add ebx,4
	mov eax, x2
	pop ecx 
	loop loop_linii1
	
	
	mov esp,ebp
	pop ebp
	ret 
make_orizontal_arrows endp

make_down_arrow proc 
	push ebp 
	mov ebp, esp
	
	lea esi, sageata_jos
	mov eax, sageata_jos_height ;19
	mov ebx, sageata_jos_width ;11
	mul ebx 
	mov ecx, eax 
	
	mov eax, y3 
	mov ebx, x3
	mov ecx, sageata_jos_height ;19
	loop_linii2:
	push ecx
	mov ecx,sageata_jos_width ;11
		loop_coloane2:
		cmp byte ptr [esi],1
		je patratel2
	draw_line_horizontal_macro 4,ebx,eax,4,0FFFFFFh
	jmp next_bit2
	patratel2:
	draw_line_horizontal_macro 4,ebx,eax,4,0d3472h
	
	next_bit2:
	add eax,4
	
	inc esi
	loop loop_coloane2
	add ebx,4
	mov eax, y3
	pop ecx 
	loop loop_linii2
	
	mov esp,ebp
	pop ebp
	ret 
make_down_arrow endp

	
start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	lea ebx, game_area
	add ebx,10
	mov position_piesa,ebx 
	
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20

	;terminarea programului
	push 0
	call exit
end start
