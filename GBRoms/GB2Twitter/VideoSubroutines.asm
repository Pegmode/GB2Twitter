;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;VIDEO SUBROUTINES
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;Load tiles
;==========================================================
;note: non-dynamic. only use for inital loads
LoadTiles:
	or 1 ;reset z
	ld de,_VTILE0 ;load the first tile ram address into de
					;hl is at data start

;Copy data to Vram (for tiles and map)
;===========================================================
; Input requirements: de = VRAM address, hl = data start address, c = tile data size
VRamCopyLoop:
		call WaitBlank
		ld a,[hl+] ;Load the data at address hl into a and inc hl
		ld [de],a ;Load the data into ram
		inc de	;increment the VRam address
		dec bc ;Decrement counter     16 BIT OPERATIONS DONT THROW FLAGs
		ld a,b
		or c ;test if counter is zero
		jp nz,VRamCopyLoop
    ret





;Load BG Map ("Window styled")
;===========================================================  THINK ABOUT SWAPING HL AND DE
;Input requirements: hl start address(read), bc tile width in bytes, de VramLocation(destination top right corner), [MapHeight]` current maps height
LoadBGMap:
.BGLoadLoop
	push bc;keep the initial value of bc
	call VRamCopyLoop
	pop bc;reset bc to initial value

	push hl ;backup hl
	;skip to next line
	ld a,mapWidth_tiles; find distance to add
	sub c
	;setup hl for dumb 16bit crap
	ld h,0
	ld l,a
	add hl,de ;add width to VRAM address (still in ghost registers)
	ld d,h
	ld e,l

	pop hl;fetch backup hl

	;checks if at end of height
	or 1
	ld a,[CurrentMapHeight]
	dec a
	ld [CurrentMapHeight],a ;save current map x in no. of tiles
	jp nz,.BGLoadLoop ;if not at end of row continue writing
	ret




;Wait for V/HBlank
;==========================================================
;Total time: 52 cycles
;stat %xxxxxx0x
WaitBlank:
	ld a,[rSTAT]    ;16C
	and 2						;8C
	jr	nz,WaitBlank;12 ~ 8C
	ret							;16C

;Wait for VBlank
;==========================================================
;wait for Beginning of vBlank
;holds for a long time
;stat %xxxxxx01
WaitVBlank:
	ld a,[rSTAT]
	bit 0,a
	jr nz,WaitVBlank;wait for non vBlankState
.waitforVBlank;
	ld a,[rSTAT]
	bit 0,a
	jr z,.waitforVBlank
	bit 1,a
	jr nz,.waitforVBlank
	ret

;Wait for rSTAT to change
;==========================================================
WaitStat:
	push	af
.wait
	ld	a,[rSTAT]
	and	2
	jr	z,.wait
.wait2
	ld	a,[rSTAT]
	and	2
	jr	nz,.wait2
	pop	af
	ret
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;SPITE STUFF
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;DMA Transfer Code (DO NOT CALL THIS CODE DIRECTLY)
;==========================================================
;Length = 9
DMATransCode:
	ld a,N_ShadowOAM
	ld [rDMA],a ;initiate DMA Transfer from N_ShadowOAM to OAM
    ld      a, $28 ;wait 128 micro seconds while transfer completes
.loop:
	dec     a
	jr     nz, .loop
	ret


;StartDMATransfer
;==========================================================
;input requirements: Requires data in N_ShadowOAM ($c100) to contain OAM data
;Disables all memory access except HRAM while running
StartDMATransfer:
	push bc
	;pass values to MemCopy
	ld hl,DMATransCode
	ld bc,_HRAM;$FF80
	ld d,10 ;length of DMATransCode
	call MemCopy
	call _HRAM;Start Transfer (no memory access)
	pop bc
	ret



;SelectSprite
;==========================================================
;Input requirements: l = sprite # (indexed from 0), de = Base address ($C100 or _OAMRAM ), h is destroyed
SelectSprite:
	ld h,0
	add hl,hl
	add hl,hl ; l*4 (OAM are in 4 byte blocks)
	add hl,de
	ret

;SetSpritePos
;==========================================================
;Input requirements: l = sprite #, b = x pos, c = y pos, de = Base Address, h is destroyed
SetSpritePos:
	call SelectSprite
	push bc
	ld [hl],b
	inc hl
	ld [hl],c
	pop bc
	ret

;SetSpriteTile
;==========================================================
;Input requirements: l = sprite #, b = tile #, de = base address, h is destroyed
SetSpriteTile:
	call SelectSprite
	inc hl;add optimized
	inc hl
;CreateMetaSprite
;========================================================
; x, y, width, height, map loc
CreateMetaSprite:


;Load Standard DMG pallet
;============================================================
LoadNormalPallet:
	ld a,$E4
	ld [$FF47],a
	ret

; ================================================================
; Clear video RAM (CREDIT DEVED)
; ================================================================

ClearVRAM:
	ld	hl,$8000 ;VRAM start address
	ld	bc,$2000 ;VRAM address length
	; routine continues in ClearLoop

; ================================================================
; Clear a section of RAM (CREDIT DEVED)
; ================================================================
	;hl = start address
	;bc = length

ClearLoop:
	call WaitStat ;REPLACE THIS WITH DISABLING THE LCD WHEN ITS CALLED
	xor	a
	ld	[hl+],a
	dec	bc
	ld	a,b
	or	c
	jr	nz,ClearLoop
	ret


; Loads a DMG palette. (Credit DevEd)
; USAGE: SetPal <rBGP/rOBP0/rOBP1>,(color 1),(color 2),(color 3),(color 4)
SetDMGPal:                macro
    ld    a,(\2 + (\3 << 2) + (\4 << 4) + (\5 << 6))
    ldh    [\1],a
    endm
