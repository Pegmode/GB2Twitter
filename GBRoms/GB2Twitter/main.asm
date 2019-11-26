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
	ld de,54
	ld a,[TextInputPointerMS]
	ld h,a
	ld a,[TextInputPointerLS]
	ld l,a
	add hl,de
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
	;
.exit
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
	ld de,8*16
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
