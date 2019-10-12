;GB2Twitter ROM by Daniel Chu (Pegmode)
;Thanks to DevEd for some code

;Constant Includes (DO NOT ADD CODE)
;==================================================
include "hardware.asm"
include "constants.asm"
include "macros.asm"

;Header (Code from here down)
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

  xor a;ld 0
  ld [PayloadTermChar],a ;load Term Char for later prints
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
	;load numbers (could save here)
	ld hl,NumberTiles
	ld de,$8000+432 ;432 is the offset from the last load
	ld c,160
	call VRamCopyLoop

firstloadFirstPage:;data that stays constant
  ;info bottom text
  ld hl,bottomText1
  ld de,_SCRN0 + $20*$10
  call FillASCIIMap
  ld hl,bottomText2
  ld de,_SCRN0 + $20*$11
  call FillASCIIMap
  ld hl,currentPayloadText1
  ld de,_SCRN0
  call FillASCIIMap

loadFirstPage:
	;line one text
	ld hl,initText1
	ld de,_SCRN0 + $20 * 3
	call FillASCIIMap
	;line 2 text
	ld hl,initText2
	ld de,_SCRN0 + $20 * 4 ;$20 diff for new line
	call FillASCIIMap
  jp idleHandleInput

DecPayload:
	ld a,[rSB]
	dec a
	ld [rSB],a
  call printCurrentSerial
	ret
IncPayload:4
	ld a,[rSB]
	inc a
	ld [rSB],a
  call printCurrentSerial
	ret

clearText:
  ld hl,_SCRN0
  ld bc,$99F3-$9860
  call ClearLoop
  ret


idleHandleInput:;NOT A CALL FUNCTION, has currently replaced main
  call ReadJoy
  ld a,[OldJoyData]
  cp $1;check B button
  jp z,setMaster
  cp $2;check A botton
  jp z,setSlave
  cp $20;check left
  jp nz,idleHandleInput
  call DecPayload
  jp idleHandleInput
  cp $10;check right
  jp nz,idleHandleInput
  call IncPayload
  jp idleHandleInput

main:
  jp idleHandleInput; idleHandleInput has become the new main
.exit
	jp main

slaveWaitLoop:
  ld a,[rSC]
  ld b,$80; select last bit
  and b
  jp nz,slaveWaitLoop;wait for TRANSFER
  jp waitNextMainCycle

startTransfer:;as master start transfer
	;clear old
	ld hl,_SCRN0 + $20*3
	ld bc,scrWidth_tiles
	call ClearLoop
  ;clear old
  ld hl,_SCRN0 + $20*4
  ld bc,scrWidth_tiles
  call ClearLoop
	;update text
	ld hl,masterTextTransfer
	ld de,_SCRN0 + $20*3
	call FillASCIIMap
	ld a,%10000001
	ld [rSC],a;START TRANSFER!
.checkTransfer
	ld a,[rSC]
	and %10000000
	jp nz,.checkTransfer
	;TRANSFER IS DONE!
	;clear old
	ld hl,_SCRN0 + $20*3
	ld bc,scrWidth_tiles
	call ClearLoop
	;update text
	ld hl,masterTextDone
	ld de,_SCRN0 + $20*3
	call FillASCIIMap
	jp waitNextMainCycle

waitNextMainCycle:;wait for user input to restart whole process
 call printCurrentSerial
.l1
  call ReadJoy
  ld a,[OldJoyData]
  cp $8;check start button
  jp nz,.l1
  ;exit the cycle
  ;clear the screen
  ld hl,_SCRN0
  ld bc,$99F3-$9860
  call ClearLoop
  jp loadFirstPage

setMaster:
	ld a,1
	ld [rSC],a;set GB to master
	;LOAD TEST MASTER PAYLOAD
	ld a,$42
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
	ld a,$42;PAYLOAD
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
	jp slaveWaitLoop

printCurrentSerial:
  ;clear line
  ld hl,_SCRN0 + $20*3
  ld bc,scrWidth_tiles
  call ClearLoop
  ;load and convert values
  ld a,[rSB]
  ld d,b
  call Hex2ASCII
  ;print values
  ld a,b
  ld [PayloadFirstChar],a
  ld a,c
  ld [PayloadSecondChar],a
  ld hl,PayloadFirstChar
  ld de,_SCRN0 + $20
  call FillASCIIMap
  ret



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

;printGB
;=========================================
;Prints a semi formatted string at given line and col
;hl = input text address, e = line #, c = col (line pos)
;USES ALL REGISTER PAIRS
printGB:
	ld d,0;set d to zero for 16 bit op
	ld b,0; b to zero for 16 bit op
	sla e;e * 32 new line is 32
	sla e
	sla e
	sla e
	sla e
	push hl;temp store hl
	ld hl,_SCRN0
	add hl,de ;_SCRN0 + line# * 32
	add hl,bc; Line + x position
	ld d,h; de = hl set destinatino address
	ld e,l
	pop hl;restore hl

.l1
;working: de = destination, bc = temp
	ld a,[hl+]
	cp $00;null termination char check
	jr z,.exit
	cp $0A;newline char check
	jr z,.newline
	sub 32; 32 is lowest in ascii block
	ld b,0; 16SU
	ld c,a
	push hl; temp store
	ld hl,ASCIITileTable
	add hl,bc; get tile number table address
	ld a,[hl];load tile num into a
	pop hl; restore hl
	push af
	call WaitBlank
	pop af
	ld [de],a;load tile num into memory
	inc de
	jp .l1
.newline
	push hl;temp store
	ld bc,32; new line is 32 diff
	ld h,d ; de = hl
	ld l,e
	add hl,bc;destination is + 32
	ld d,h
	ld e,l
	pop hl;restore hl
	jp .l1
.exit
	ret

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

currentPayloadText1:
  db "CURRENT PAYLOAD",0

debugString:
	db "THIS IS \n A TEST",0

bottomText1:
	db "TESTROM BY",0 ;10 hex pos
bottomText2:
	db "DANIEL CHU PEGMODE",0 ;11 hex
;SUBROUTINES
;================================================


include "GeneralSubroutines.asm"
include "VideoSubroutines.asm"
include "Graphics/TextTiles.asm" ;TileSet1
include "Graphics/NumberTiles.asm";numbers
