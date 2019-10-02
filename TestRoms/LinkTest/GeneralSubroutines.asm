;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;GENERAL SUBROUTINES
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


;MemCopy
;==========================================================
;Input requirements: hl = Source Address, bc = destination, d = data length
MemCopy:
	ld a,[hl+]
	ld [bc],a
	inc bc
	dec d
	jp nz,MemCopy
	ret
;OAMGMemCopy (copy memory when incrementing in OAM space)
;==========================================================
;Input requirements: hl = Source Address, bc = destination, d = data length
OAMGMemCopy:
	ld a,[hl+]
	ld [bc],a
	inc c
	dec d
	jp nz,OAMGMemCopy

;Read Joypad input (from GB cpu man)
;==========================================================
;[OldJoyData] return values:
;$8= start , $80=DOWN
;$4= select,$40=Up
;$2=b , $20=left
;$1=A, $10= right
ReadJoy:
	ld a,%00100000
	ld [rP1],a;Select P14
	ld a,[rP1]
	ld a,[rP1];wait
	cpl ;inv
	and %00001111;get only first 4 bits
	swap a;swap it
	ld b,a; store a in b
	ld a,%00010000
	ld [rP1],a;Select P15
	ld a,[rP1]
	ld a,[rP1]
	ld a,[rP1]
	ld a,[rP1]
	ld a,[rP1]
	ld a,[rP1];wait
	cpl ;inv
	and %00001111;get first 4 bits
	or b;put a and b together
	ld b,a;store a in d
	ld a,[OldJoyData];read old joy data from RAM
	xor b; toggle w/cirremt button bit backup
	and b; get current button bit backup
	ld [NewJoyData],a;save in new NewJoyData storage
	ld a,b;put original value in a
	ld [OldJoyData],a;store it as old jow Data
	ld a,$30;deslect p14 and P15
	ld [rP1],A;Reset Joypad
	ret


;Random Number Generator	(credit Jeff Frohwein)
;==========================================================
; (Allocate 3 bytes of ram labeled 'Seed')
; Exit: A = 0-255, random number
RandomNumber:
push hl
        ld      hl,Seed
        ld      a,[hl+]
        sra     a
        sra     a
        sra     a
        xor     [hl]
        inc     hl
        rra
        rl      [hl]
        dec     hl
        rl      [hl]
        dec     hl
        rl      [hl]
        ld      a,[$fff4]          ; get divider register to increase
.randomness
        add     [hl]
		pop hl
        ret


ASCIITileTable:
;start @ 0x32 + index in this table
;entries are tile index in vram
; " "  !   "   #   $   %   &   '   (   )   *   +   `   -   .   /
db $00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
;  0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
;  @   A    B    C    D    E    F    G    H    I    J    K    L    M    N    O
db 00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
;  P    Q    R    S    T    U    V    W    X    Y    Z
db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A
