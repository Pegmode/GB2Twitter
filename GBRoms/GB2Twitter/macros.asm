;;DEBUG
testMacro: MACRO
	inc a
	jp main
	ENDM

loadEditorNormalPallet: MACRO ;;INVOKE DURING VBLANK!!!
	ld a,%11100100
	ldh [rBGP],a
	ENDM

BREAKPOINT: MACRO
	ld b,b
	ENDM

mDisableLCD: macro
;SAFELY disable LCD and preserve
call WaitVBlank
ld a,[rLCDC]
ld b,$7F
and b
ld [rLCDC],a
	ENDM

mFillInvisBlank: macro
;pad BG map edge with zeros
;size = 12
	db 0,0,0,0,0,0,0,0,0,0,0,0
	endm
