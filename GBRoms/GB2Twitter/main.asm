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
	ld a,%11100001;"Default" 10010001
			; 76543210
	ld [rLCDC],a
	ld a,%11100100;"Expected" 11100100, "Default tile editor"
	ldh [rBGP],a;

	call loadUITiles
	call loadTextInputWindow
	call enableLCD

;==================================================
main:
.mainLoop
	jp .mainLoop


loadUITiles:
	call disableLCD;WILL HANG IF LCD IS NOT ENABLED
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
