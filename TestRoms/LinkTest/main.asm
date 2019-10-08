;GB2Twitter ROM by Daniel Chu (Pegmode)
;Thanks to DevEd for some code

;Constant Includes (DO NOT ADD CODE)
;==================================================
include "hardware.asm"
include "constants.asm"
include "macros.asm"

;Header
;==================================================
include "GBHeader.asm"

;User Program
;==================================================
SECTION "Main Program",HOME[$155]

;Startup (ENTRY POINT!)
;----------------------
StartupInit:
	call WaitVBlank
	call ClearVRAM ;DONT ASSUME INITIAL STATE
	call WaitVBlank
	ld a,%10010001 ;"Default" 10010001
	ld [rLCDC],a
	ld a,%11100100;"Expected" 11100100, "Default tile editor"
	ldh [rBGP],a;
;==================================================
debug1:


loadInitPage:
	;load text tiles

	ld hl,TextTiles ;source
	ld de,$8000+16;memory adr, every tile takes up 16 bytes
	ld c,$FF
	call VRamCopyLoop;load first word of text tiles
	ld c,161
	call VRamCopyLoop;load second word of text tiles

	;line one text
	ld hl,initText1
	ld de,_SCRN0
	call FillASCIIMap
	;line 2 text
	ld hl,initText2
	ld de,_SCRN0 + $20 ;$20 diff for new line
	call FillASCIIMap
	;info bottom text
	ld hl,bottomText1
	ld de,_SCRN0 + $20*$10
	call FillASCIIMap
	ld hl,bottomText2
	ld de,_SCRN0 + $20*$11
	call FillASCIIMap


.waitForInitialInput
	call ReadJoy
	ld a,[OldJoyData]
	cp $1;check B button
	jp z,setMaster
	cp $2;check A botton
	jp z,setSlave
	jp .waitForInitialInput

main:
	ld a,[rSC]
	and 1
	cp 1;check if in master mode
	jp nz,.notMaster;if not in master mode jp
	call ReadJoy
	ld a,[OldJoyData]
	cp $8;check for start button
	jp z,startTransfer
.notMaster
	nop
.exit
	jp main

startTransfer:;as master start transfer
	;clear old
	ld hl,_SCRN0 + $20*4
	ld bc,scrWidth_tiles
	call ClearLoop
	;update text
	ld hl,masterTextTransfer
	ld de,_SCRN0 + $20*4
	call FillASCIIMap
	ld a,%10000001
	ld [rSC],a;START TRANSFER!
.checkTransfer
	ld a,[rSC]
	and %10000000
	jp nz,.checkTransfer
	;TRANSFER IS DONE!
	;clear old
	ld hl,_SCRN0 + $20*4
	ld bc,scrWidth_tiles
	call ClearLoop
	;update text
	ld hl,masterTextDone
	ld de,_SCRN0 + $20*4
	call FillASCIIMap
	jp main

setMaster:
	ld a,1
	ld [rSC],a;set GB to master
	;LOAD TEST MASTER PAYLOAD
	ld a,$69
	ld [rSB],a
	;clear line
	ld hl,_SCRN0 + $20*3
	ld bc,scrWidth_tiles
	call ClearLoop
	;Write text
	ld hl,masterText
	ld de,_SCRN0 + $20*3
	call FillASCIIMap
	ld hl,masterText2
	ld de,_SCRN0 + $20*4
	call FillASCIIMap
	jp main

setSlave:
	ld a,%10000000
	ld [rSC],a;set GB to Slave
	;LOAD TEST SLAVE PAYLOAD
	ld a,$42
	ld [rSB],a
	;clear line
	ld hl,_SCRN0 + $20*3
	ld bc,scrWidth_tiles
	call ClearLoop
	;Write Text
	ld hl,slaveText
	ld de,_SCRN0 + $20*3
	call FillASCIIMap
	ld hl,slaveText2
	ld de,_SCRN0 + $20*4
	call FillASCIIMap
	;ld a,%00000100 ;set interupt
	;ld [rIF],a
	;ei
	jp main

printCurrentSerial:


;ASCII2tile
;=====================================
;hl = input text address, de = destination
FillASCIIMap:
	push bc
	ld b,32
.l1
	ld a,[hl+]
	cp $00 ;null termination char
	jr z,.exit ;test if current ascii is the null termination character (0)

	sub 32;convert to "A" table index positions
	ld b,0
	ld c,a
	push hl;need hl for 16 bit add
	ld hl,ASCIITileTable
	add hl,bc
	ld a,[hl];load tile number for ascii char into A
	pop hl;get back actual hl
	push af
	call WaitBlank
	pop af
	ld [de],a ;load tile number into destination
	inc de
	jr .l1
.exit
	pop bc
	ret

;printAt
;=========================================
;hl = input text address,
printAt:


;INTERUPTS
;===================================================
serialInt:
	ld a,[rSB]
	cp %10000001
	jp z,.exit;jump if master
	;clear old
	ld hl,_SCRN0 + $20*4
	ld bc,scrWidth_tiles
	call ClearLoop
	;update text
	ld hl,slaveTextDone
	ld de,_SCRN0 + $20*4
	call FillASCIIMap
	di
.exit
	ret

;VBlank
;----------------------
vBlankInt:

.scanButtons
ret

;DATA
;==============================================
initText1:
	db "A FOR MASTER",0
initText2:
	db "B FOR SLAVE",0

masterText:
	db "MASTER MODE",0
masterText2:
	db "PRESS START TO TRANSFER",0
masterTextTransfer:
	db "SENDING",0
masterTextDone:
	db "TRANSFER FINISHED",0

slaveText:
	db "SLAVE MODE",0
slaveText2:
	db "WAITING",0
slaveTextTransfer:
	db "RECEIVING",0
slaveTextDone:
	db "DONE RECEIVING",0



bottomText1:
	db "TESTROM BY",0 ;10 hex pos
bottomText2:
	db "DANIEL CHU PEGMODE",0 ;11 hex
;SUBROUTINES
;================================================


include "GeneralSubroutines.asm"
include "VideoSubroutines.asm"
include "Graphics/TextTiles.asm" ;TileSet1
