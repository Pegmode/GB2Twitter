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


;==================================================
main:

.mainLoop
	jp .exit


loadTextInput:



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

;SUBROUTINES
;================================================


include "GeneralSubroutines.asm"
include "VideoSubroutines.asm"
include "Graphics/TextTiles.asm" ;TileSet1
include "Graphics/NumberTiles.asm";numbers
