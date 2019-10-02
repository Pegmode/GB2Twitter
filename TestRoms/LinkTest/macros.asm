;;DEBUG
testMacro: MACRO
	inc a
	jp main
	ENDM
	
loadEditorNormalPallet: MACRO ;;INVOKE DURING VBLANK!!!
	ld a,%11100100
	ldh [rBGP],a
	ENDM
	
