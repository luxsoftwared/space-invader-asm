;------------------------------------------------------------
;	Autor: Luka Djokic				;
;	Datum nastanka: 18.03.2018.			;
;------------------------------------------------------------	
	
	
	ORG	32768
	CALL 	initialise
loop:
	HALT
	LD	HL,(Player_loc)
	CALL	Player_action
	BIT	0,A			;AKo je Q pritisnuto zavrsava igricu
	RET	Z

	CALL	Metak
	CALL	Metak_move
	JP	loop
	RET
	
initialise:
	CALL	Border_draw
	LD	HL,(Player_loc)
	CALL	Player_draw
	LD	HL,(Enemy_loc)
	CALL	Enemy_draw
	RET
	
	;---------------
	;Iscrtava okvir}
	;---------------
Border_draw: 
	;PUSH	HL
	;PUSH	AF
	;PUSH	BC
	;PUSH	DE
	LD	A,%00001000
	LD	BC,23264		;-----	Memorijska lokacija ćelije donjeg levog ćoška
	LD	HL,22528		;-----	Memorijska lokacija ćelije donjeg levog ćoška
	LD	D,32		;-----	Brojac za up_down	
up_down:				;-----	Iscrtava gornju i donju ivicu
	LD	(HL),A			
	LD	(BC),A
	INC	HL
	INC	BC
	DEC	D
	JP	NZ,up_down
	
	LD	HL,22528
	LD	D,24
	LD	BC,32		;Za koliko povecava koordinata kod crtanja bocnih bordera
left:				;-----	Iscrtava levu ivicu
	LD	(HL),A
	ADD	HL,BC
	DEC	D
	JP	NZ,left
	
	LD	HL,22559		;-----	Kordinate gornje desne ivice
	LD	D,24
right:				;-----	Iscrtava desnu ivicu
	LD	(HL),A
	ADD	HL,BC
	DEC	D
	JP	NZ,right
	
	;PUSH	DE
	;PUSH	BC
	;POP	AF
	;POP	HL
	;RET
	
;Iscrtava igraca na osnovu koordinata iz memorije (Player_loc)
	
Player_draw:
	PUSH	HL
	LD	HL,(Player_loc)
	LD	(HL),%01100000		;crta gornji piksel igraca
	LD	DE,31
	ADD	HL,DE
	LD	(HL),%01100000		;
	INC	HL			;
	LD	(HL),%01100000		;crtaju donja tri piksela igraca
	INC	HL			;
	LD	(HL),%01100000		;
	LD	DE,-33
	ADD	HL,DE	;vraca HL na pocetnu vrednost
	POP	HL
	RET
	
	
Player_del:
	LD	HL,(Player_loc)
	LD	(HL),%00111000		;crta gornji piksel igraca
	LD	DE,31
	ADD	HL,DE
	LD	(HL),%00111000		;
	INC	HL			;
	LD	(HL),%00111000		;crtaju donja tri piksela igraca
	INC	HL			;
	LD	(HL),%00111000		;
	LD	DE,-33
	ADD	HL,DE			;vraca HL na pocetnu vrednost
	RET
	
;Glavna metoda za kretanje i pucanje igraca

Player_action:
	PUSH	DE
	LD	BC,$FDFE			;Uzima vrednosti tastature (A, S, D, F, G)
	IN	A,(C)
	BIT	0,A			;A
	CALL	Z,Move_Left		
	BIT	2,A			;D
	CALL	Z,Move_right				
	LD	BC,$FBFE			;Uzima vrednosti tastature (Q, W, E, R, T)
	IN	A,(C)
	BIT	1,A		;W
	JP	NZ,shoot_end		;ako nije pritisnuto w, ne ispaljuje metal, pa presace ispaljivanje;				;AKO VEC IMA METAK TREBA JUMP
	PUSH	HL
	LD	HL,(Player_loc)
	LD	DE,-32
	ADD	HL,DE
	LD	(metakmetak),HL		;zapisuje pocetnu lokaciju metka
	POP	HL
shoot_end:
	;IN	A,(C)
	POP	DE
	RET
	

;Kretanje igraca u Levo
	
Move_Left:
	PUSH 	HL
	PUSH	AF
	LD	HL,(Player_loc)
	CALL	Player_del	;-----	Brise player-a 
	DEC	HL
	DEC	HL
	LD	A,(HL)
	CP	%00001000	;-----	Proverava da li je celija na koju planira da se pomeri obojena u boju kojom je obojen igrac
	JP	NZ,.stop		
	INC	HL
	
.stop:				;-----	Ako nije obojena, iscrtava player-a
	INC	HL
	LD	(Player_loc),HL
	CALL	Player_draw
	POP	AF
	POP	HL
	RET

	
Move_right:			;-----	Isti princip kao Move_Left
	PUSH	HL
	PUSH	AF
	CALL	Player_del
	INC	HL
	INC	HL
	LD	A,(HL)
	CP	%00001000
	JP	NZ,.stop
	DEC	HL
	
.stop:
	DEC	HL
	LD	(Player_loc),HL
	CALL	Player_draw
	POP	AF
	POP	HL
	RET

	
;-------------------------
;Na klik generise metak samo ako je (metakmetak)=0
	

	
	
;Iscrtava metak ako je to moguce
Metak:
	PUSH	HL
	PUSH	AF
	LD	HL,(metakmetak)
	LD	A,1
	DEC	HL			;Ako metak nema koordinate po defoltu je 1
	JP	Z,end_metak		;Ako je metak neispaljen HL ce biti 0 pa preskace iscrtavanje
	INC	HL
	LD	A,(HL)
	CP	%00010000
	JP	Z,del_metak		;Ako je udario u neprijatelja,brise se
	CP	%00001000
	JP	Z,del_metak		;Ako je metak udario u zid brise ga i ne ispisuje
	LD	HL,%00010000		;Iscrtava
	JP	exit_met
del_metak:
	LD	A,1
end_metak:
	LD	(metakmetak),A
exit_met:	
	POP	AF
	POP	HL
	RET

	
	;MRda adresu metak
Metak_move:
	PUSH	HL
	PUSH	DE
	LD	HL,(metakmetak)
	DEC	HL
	RET	Z
	LD	DE,-31
	ADD	HL,DE
	LD	(metakmetak),HL
	POP	DE
	POP	HL
	RET

;Iscrtava sve neprijatelje

Enemy_draw:
	PUSH	AF
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	HL,(Enemy_loc)
	LD	BC,8
	LD	A,4
loop1:
	PUSH	AF
	BIT	0,(HL)
	LD	A,%00010000
	JP	Z,continue1
	LD	A,%10000000
	OR	(HL)
	;LD	A,%10111000
	DEC 	HL
	LD	(HL),A
	INC	HL
continue1:
	LD	(HL),A		;crta donji piksel neprijatelja
	LD	DE,-33
	ADD	HL,DE
	LD	(HL),A		;
	INC	HL			;
	LD	(HL),A		;crtaju gornja tri piksela neprijatelja
	INC	HL			;
	LD	(HL),A		;
	LD	DE,31
	ADD	HL,DE			;vraca HL na pocetnu vrednost
	POP	AF
	ADD	HL,BC
	DEC	A
	JP	NZ,loop1
	
	LD	BC,+68
	ADD	HL,BC
	LD	BC,8
	LD	A,3
loop2:
	PUSH	AF
	BIT	0,(HL)
	LD	A,%00010000
	JP	Z,continue2
	LD	A,%10000000
	OR	(HL)
	DEC 	HL
	LD	(HL),A
	INC	HL
	
continue2:
	LD	(HL),A		;crta donji piksel neprijatelja
	LD	DE,-33
	ADD	HL,DE
	LD	(HL),%00010000		;
	INC	HL			;
	LD	(HL),%00010000		;crtaju gornja tri piksela neprijatelja
	INC	HL			;
	LD	(HL),%00010000		;
	LD	DE,31
	ADD	HL,DE			;vraca HL na pocetnu vrednost
	ADD	HL,BC
	POP	AF
	DEC	A
	JP	NZ,loop2
	
	
	POP	BC
	POP	DE
	POP	HL
	POP	AF
	RET
	
Enemy_del:		;brise jednog neprijatelja na osnovu HL prosledjenih koordinata

	PUSH	AF
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	HL,(Enemy_loc)
	LD	BC,8
	LD	A,4
.loop1:
	PUSH	AF
	BIT	0,(HL)
	LD	A,%00111000
	JP	Z,.continue1
	LD	A,%10111000
	DEC 	HL
	LD	(HL),A
	INC	HL
.continue1:
	LD	(HL),A		;crta donji piksel neprijatelja
	LD	DE,-33
	ADD	HL,DE
	LD	(HL),A		;
	INC	HL			;
	LD	(HL),A		;crtaju gornja tri piksela neprijatelja
	INC	HL			;
	LD	(HL),A		;
	LD	DE,31
	ADD	HL,DE			;vraca HL na pocetnu vrednost
	POP	AF
	ADD	HL,BC
	DEC	A
	JP	NZ,.loop1
	
	LD	BC,+68
	ADD	HL,BC
	LD	BC,8
	LD	A,3
.loop2:
	PUSH	AF
	BIT	0,(HL)
	LD	A,%00111000
	JP	Z,.continue2
	LD	A,%10111000
	DEC 	HL
	LD	(HL),A
	INC	HL
	
.continue2:
	LD	(HL),A		;crta donji piksel neprijatelja
	LD	DE,-33
	ADD	HL,DE
	LD	(HL),%00010000		;
	INC	HL			;
	LD	(HL),%00010000		;crtaju gornja tri piksela neprijatelja
	INC	HL			;
	LD	(HL),%00010000		;
	LD	DE,31
	ADD	HL,DE			;vraca HL na pocetnu vrednost
	ADD	HL,BC
	POP	AF
	DEC	A
	JP	NZ,.loop2
	
	
	POP	BC
	POP	DE
	POP	HL
	POP	AF
	RET
	
Enemy_move:
	PUSH	DE
	LD	HL,(Enemy_loc)
;	ADD	HL,DE		;Vraca HL na koordinate prvog neprijatelja 
	
enemy_Left:
	PUSH	AF
;	CALL	Player_del	;-----	Brise player-a 
;	DEC	HL
;	DEC	HL
;	LD	A,(HL)
;	CP	%00001000	;-----	Proverava da li je celija na koju planira da se pomeri obojena u boju kojom je obojen igrac
;	JP	NZ,.stop		
;	INC	HL
;	
;.stop:				;-----	Ako nije obojena, iscrtava player-a
;	INC	HL
;;	CALL	Player_draw
;	POP	AF
	
;	POP	DE
;	RET
	
;Enemy_destroyed:
	
	
	
Player_loc:	DW	23182		;pozicija igraca
Enemy_loc:	DW	22627 	;pozicije neprijatelja
metakmetak:	DW	%0000000000000000;
