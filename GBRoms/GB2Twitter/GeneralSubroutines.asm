;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;GENERAL SUBROUTINES
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;MemCopyLong
;==========================================================
;Input requirements: hl = Source Address, bc = destination, de = data length
MemCopyLong:
	ld a,[hl+]
	ld [bc],a
	inc bc
	dec de
	xor a
	or e
	jp nz,MemCopyLong
	or d
	jp nz,MemCopyLong
	ret

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

;disableLCD
;==========================================================
;SAFELY disable LCD and preserve LCDC
disableLCD:
	call WaitVBlank
	ld a,[rLCDC]
	ld b,$7F
	and b
	ld [rLCDC],a
	ret
;enableLCD
;==========================================================
;WARNING: ENSURE THAT LCD IS DISABLED TO PREVENT PHYSICAL DAMAGE TO ELECTRONICS
enableLCD:
	ld a,[rLCDC]
	ld b,$80
	or b
	ld [rLCDC],a
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

; Hex2ASCII:
; ;reads in a hex value and returns its ascii representation
; ;param: d = Input
; ;rtn: BC = ASCII representation
; ld a,$0F
; and d
; ld hl,Hex2ASCIITable
; ;MAY CAUSE A BUG IF Hex2ASCIITABLE IS ON EDGE OF legal
; add l
; ld c,[hl]
; ;Load 2nd char
; ld a,$F0
; and d
; srl a
; srl a
; srl a
; srl a
; ld hl,Hex2ASCIITable
; add l
; ld b,[hl]
; ret
Hex2ASCII:
;reads in a hex value and returns its ascii representation
;param: d = Input
;rtn: BC = ASCII representation
ld a,$0F
and d
ld hl,Hex2ASCIITable
;MAY CAUSE A BUG IF Hex2ASCIITABLE IS ON EDGE OF legal
push de ;save de
ld d,0
ld e,a
add hl,de
pop de; restore
ld c,[hl]
;Load 2nd char
ld a,$F0
and d
srl a
srl a
srl a
srl a
ld hl,Hex2ASCIITable
;no need to push b/c we dont care about de anymore
ld d,0
ld e,a
add hl,de
ld b,[hl]
ret


Hex2ASCIITable:
;  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
db 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70

ASCIITileTable:
;CURRENT ORDER A-B, 0-1, a-b
;start @ 0x32 + index in this table
;entries are tile index in vram
; " "  !   "   #   $   %   &   '   (   )   *   +   '   -   .   /
db $00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
;  0    1     2    3    4    5    6    7    8    9   :   ;   <   =   >   ?
db $24, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, 00, 00, 00, 00, 00, 00
;  @   A    B    C    D    E    F    G    H    I    J    K    L    M    N    O
db 00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
;  P    Q    R    S    T    U    V    W    X    Y    Z
db $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A
;  [   \   ]   ^   _   `
db 00, 00, 00, 00, 00, 00
;  a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p
db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
;  q   r   s   t   u   v   w   x   y   z
db 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
