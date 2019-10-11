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
BounceFlag equ $c005 ;7:Direction,
BounceV equ $c006
Seed equ $C020 ;Random number generator seed 3 bytes long

ShadowOAM equ $C100 ;Shadow OAM adddress
N_ShadowOAM equ $C1 ;reference to first nibble of $C100
;devsound reserved: $c200-$c300
OldJoyData equ $ff8b;stores last joy input
NewJoyData equ $ff8c;stores new joy

;Serial Payload reserv
PayloadType equ $c300



_VTILE0 equ $8000 ;BG & Window Tile Data Select set to 1 (defualt)
_VTILE1 equ $8800 ;BG & Window Tile Data Select set to 0

;Draw functions (RAM
CurrentMapHeight EQU $D000 ;current height


;Bounce Physics constants

VelocityI1 equ 15 ;right
VelocityI2 equ 8 ;left
Acceleration1 equ 1;right
Acceleration2 equ 1 ;left
MaxD equ 160
MinD equ 8;20
;d = v+d
;v = v-a1
;check if d is in bounds
;if fail then cont, if pass then go back to beginning
;v=vi2
;d=v-d
;v=v-a2
;check again
