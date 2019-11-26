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
	ld a,[OldJoyData]
	bit 4,a
	jp z,.DebugSkip
	BREAKPOINT
.DebugSkip

	jp .mainLoop


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
	ld a,104+16+8
	ld [hl+],a
	;xPos
	ld a,16+32+16
	ld [hl+],a
	;Tile
	ld a,1;tile 1
	ld [hl+],a

	;OBJflags
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

textInputArray:
;abstraction of textbox
;contains 3 one byte long items
;		Position x
;		Position y
;		ASCII Reference
	


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
