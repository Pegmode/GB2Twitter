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
	ld a,%11100011;"Default" 10010001
			; 76543210
	ld [rLCDC],a
	ld a,%11100100;"Expected" 11100100, "Default tile editor"
	ldh [rBGP],a;
	ld a,%11100100;"Expected" 11100100, "Default tile editor"
	ldh [rOBP0],a;

	;Clearram
	ld hl,_RAM
	ld bc,$2000
	call ClearLoop
	;video init
	call disableLCD
	call ClearVRAM
	ld hl,_OAMRAM
	ld bc,$009f
	call ClearLoop
	;sprite tiles
	ld hl,hContrastCursor
	ld bc,$8000+16;Tiles 2
	ld de,16
	call MemCopyLong
	call loadCursor
	call loadUITiles
	call loadTextInputWindow
	call enableLCD
	ld hl,ScreenPointerMS


;==================================================
main:
.mainLoop
	call ReadJoy
	call textInputHandling
	jp .mainLoop


textInputHandling:
	;isolate only button press
	;ld a,[OldJoyData]
	;ld b,a
	ld a,[NewJoyData]
	;xor b
	;and b

	bit 4,a

	jp z,.c1
;RIGHT PRESSED

	ld de,3
	ld a,[TextInputPointerMS]
	ld h,a
	ld a,[TextInputPointerLS]
	ld l,a
	add hl,de
	;checkBounds
	; bc -= de
	ld d,h
	ld e,l
	ld bc,InputArrayEnd - 2
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jp c,.exit;if button press is out of bounds

	ld a,h
	ld [TextInputPointerMS],a
	ld a,l
	ld [TextInputPointerLS],a
	ld b,[hl];x pos
	inc hl
	ld c,[hl];y pos
	inc hl
	;WRITE TO OUTPUT
	;
	ld hl,_OAMRAM
	call WaitVBlank

	ld [hl],c
	inc hl
	ld [hl],b
	inc hl
	jp .exit
.c1;rightnotPressed
	bit 5,a

	jp z,.c2
	;Left was pressed
	ld a,[TextInputPointerMS]
	ld h,a
	ld a,[TextInputPointerLS]
	ld l,a
	dec hl;hl - 3
	dec hl
	dec hl
	;checkBounds
	; bc -= de
	ld b,h
	ld c,l
	ld de,textInputArray
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jp c,.exit;if button press is out of bounds

	ld a,h
	ld [TextInputPointerMS],a
	ld a,l
	ld [TextInputPointerLS],a
	ld b,[hl];x pos
	inc hl
	ld c,[hl];y pos
	inc hl
	;WRITE TO OUTPUT
	;
	ld hl,_OAMRAM
	call WaitVBlank

	ld [hl],c
	inc hl
	ld [hl],b
	inc hl
	jp .exit

.c2 ;left not pressed
	bit 7,a

	jp z,.c3
	;down
	ld de,54
	ld a,[TextInputPointerMS]
	ld h,a
	ld a,[TextInputPointerLS]
	ld l,a
	add hl,de

	;checkBounds
	; bc -= de
	ld d,h
	ld e,l
	ld bc,InputArrayEnd
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jp c,.exit;if button press is out of bounds

	ld a,h
	ld [TextInputPointerMS],a
	ld a,l
	ld [TextInputPointerLS],a
	ld b,[hl];x pos
	inc hl
	ld c,[hl];y pos
	inc hl
	;WRITE TO OUTPUT
	;
	ld hl,_OAMRAM
	call WaitVBlank

	ld [hl],c
	inc hl
	ld [hl],b
	inc hl
	jp .exit
.c3
	bit 6,a

	jp z,.c4
	;Up
	ld a,[TextInputPointerMS]
	ld h,a
	ld a,[TextInputPointerLS]
	ld l,a

	ld de,54
	;hl -= de
	ld a,l
	sub e
	ld l,a
	ld a,h
	sbc d
	ld h,a

	;checkBounds
	; bc -= de
	ld b,h
	ld c,l
	ld de,textInputArray
	ld a, c
	sub e
	ld c, a
	ld a, b
	sbc d
	ld b, a
	jp c,.exit;if button press is out of bounds

	ld a,h
	ld [TextInputPointerMS],a
	ld a,l
	ld [TextInputPointerLS],a
	ld b,[hl];x pos
	inc hl
	ld c,[hl];y pos
	inc hl
	;WRITE TO OUTPUT
	;
	ld hl,_OAMRAM
	call WaitVBlank

	ld [hl],c
	inc hl
	ld [hl],b
	inc hl
	jp .exit
.c4
	bit 0,a

	jp z,.c5

	;a
	ld a,[TextInputPointerMS]
	ld h,a
	ld a,[TextInputPointerLS]
	ld l,a
	inc hl
	inc hl
	ld a,[hl]
	cp "~"
	jp z,.sendTweetSel
	dec hl
	dec hl
	ld de,2
	add hl,de
	ld b,[hl]
	call putToTWDisplay
	call addToTweetBuffer
	jp .exit
.sendTweetSel
	ld b,4; 4 = eot (End of Transmission
	call addToTweetBuffer
	call sendTweet
	jp .exit
.c5
	bit 1,a

	jp z,.c6
	;b
	call removeFromTWDisplay
	call removeTweetFromBuffer

	jp .exit
.c6
.exit
	ret

sendTweet:
	BREAKPOINT
	ret

;arg b = char
;note: does not inc index
putToTWDisplay:

	ld a,b
	ld d,32
	sub d; a -32
	ld d,0
	ld e,a
	ld hl,ASCIITileTable
	add hl,de
	ld c,[hl];load map ref tile
	;to move add 12

	;_SCRN0

	ld a,[ScreenPointerCol]
	ld e,a
	ld a,19
	cp e
	ld a,e
	ld e,1
	jr nc,.c1;do we need newline?
	ld e,13
	ld a,0
	
.c1
	inc a
	ld [ScreenPointerCol],a
	ld a,[ScreenPointerMS]
	ld h,a
	ld a,[ScreenPointerLS]
	ld l,a

	add hl,de
	ld a,h
	ld [ScreenPointerMS],a
	ld a,l
	ld [ScreenPointerLS],a
	dec hl
	call WaitBlank
	ld [hl],c
	ret
;note does not dec index
removeFromTWDisplay:
	ld hl,_SCRN0
	ld a,[TweetPointerIndex]
	ld d,0
	ld e,a
	dec hl;index has not been dec yet so we gotta temp it
	add hl,de
	call WaitBlank
	ld [hl],d;may have to change d val later
	ret

;arg: b = char
;note: incs index
addToTweetBuffer:
	ld hl,TweetBuffer
	ld a,[TweetPointerIndex]
	ld d,0
	ld e,a
	add hl,de
	ld [hl],b
	inc e
	ld a,e
	ld [TweetPointerIndex],a
	ret

;note: decs index
removeTweetFromBuffer:
	ld a,[TweetPointerIndex]
	dec a
	ld [TweetPointerIndex],a
	ret


loadUITiles:
	;call disableLCD;WILL HANG IF LCD IS NOT ENABLED
	ld hl,TextTiles
	ld bc,$8800+16;Tiles 2
	ld de,26*16
	call MemCopyLong
	ld hl,NumberTiles
	ld de,10*16
	call MemCopyLong
	ld hl,LowerCase
	ld de,26*16
	call MemCopyLong
	ld hl,OtherChar
	ld de,9*16
	call MemCopyLong

	ret;LCD is still disabled!

loadCursor:
	;ONLY DURING v/hBLANK or LCD off
	ld hl,_OAMRAM
	;yPos
	ld a,TCursorYInit
	ld [hl+],a
	;xPos
	ld a,TCursorXInit
	ld [hl+],a
	;Tile
	ld a,1;tile 1
	ld [hl+],a
	;OBJflags

	;input ptr
	ld hl,textInputArray
	ld a,h
	ld [TextInputPointerMS],a
	ld a,l
	ld [TextInputPointerLS],a
	ret

loadTextInputWindow:
	;load window map with UITiles References
	ld hl,rWX
	ld a,7
	ld [hl],a
	ld hl,rWY
	ld a,104-8; 6 high
	ld [hl],a

	ld a,6
	ld hl,CurrentMapHeight
	ld [hl],a

	ld hl, WindowMapUpper
	ld bc, 16*20
	ld de,_SCRN1

	call LoadBGMap
	;setup screen pointer
	ld hl,ScreenPointerMS
	ld de,_SCRN0
	ld [hl],d
	inc hl
	ld [hl],e


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

;INTERUPTS
;===================================================
serialInt:

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

include "inputTextArray.asm"


;SUBROUTINES
;================================================


include "GeneralSubroutines.asm"
include "VideoSubroutines.asm"
include "Graphics/TextTiles.asm" ;uppercase
include "Graphics/NumberTiles.asm";numbers
include "Graphics/otherChar.asm";Other chars
include "Graphics/lowercase.asm";lowercase
include "Graphics/WindowMap.asm"
include "Graphics/ShiftKey.asm";n
include "Graphics/SpriteCursor.asm"
include "Graphics/hContrastCursor.z80";
