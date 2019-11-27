;ROM constants
;DO NOT PUT ASM CODE INSIDE THIS FILE!

;other stuff

DefaultLCDC equ $91 ;10010001




;Carillon Sound engine addresses  (within a switched bank)
;------------------------------------------
Music_Player_Initialize       equ     $4000
Music_Player_MusicStart       equ     $4003
Music_Player_MusicStop        equ     $4006
Music_Player_SongSelect       equ     $400c
Music_Player_MusicUpdate      equ     $4100


;RAM Locations
;===============================================================


ShadowX equ $C000
ShadowY equ $C001
CurrentScreenFlag equ $C002

TextInputPointerMS equ $c005 ;2 bytes reserved
TextInputPointerLS equ $c006
TweetPointerIndex equ $c007
ScreenPointerOffset equ $c008
ScreenPointerCol equ $c009
ScreenPointerRow equ $C00A
ScreenPointerMS equ $c00B ;2 bytes reserved
ScreenPointerLS equ $c00C


Seed equ $C020 ;Random number generator seed 3 bytes long

ShadowOAM equ $C100 ;Shadow OAM adddress
N_ShadowOAM equ $C1 ;reference to first nibble of $C100
;devsound reserved: $c200-$c300
OldJoyData equ $ff8b;stores last joy input
NewJoyData equ $ff8c;stores new joy

;Serial Payload reserv
PayloadType equ $c300
DebugPayload equ $C301

PayloadFirstChar equ $c302
PayloadSecondChar equ $c303
PayloadTermChar equ $c304

_VTILE0 equ $8000 ;BG & Window Tile Data Select set to 1 (defualt)
_VTILE1 equ $8800 ;BG & Window Tile Data Select set to 0

;Draw functions (RAM
CurrentMapHeight EQU $D000 ;current height
TweetBuffer equ $D001 ; ~200 reserved

;TextBox constants
TCursorXInit EQU 16
TCursorYInit EQU 120
