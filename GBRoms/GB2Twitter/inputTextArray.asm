textInputArray:
;abstraction of textbox
;contains 3 one byte long items
;		Position x
;		Position y
;		ASCII Reference

;A
db 16, 120, "A",  24, 120, "B",  32, 120, "C",  40, 120, "D",  48, 120, "E",  56, 120, "F",  64, 120, "G"
db 72, 120, "H",  80, 120, "I",  88, 120, "J",  96, 120, "K",  104, 120, "L",  112, 120, "M",  120, 120, "N"
db 128, 120,"O",  136, 120, "P",  144, 120, "Q",  152, 120, "R"

db 16, 128, "S",  24, 128, "T",  32, 128, "U",  40, 128, "V",  48, 128, "W",  56, 128, "X",  64, 128, "Y"
db 72, 128, "Z",  80, 128, "a",  88, 128, "b",  96, 128, "c",  104, 128, "d",  112, 128, "e",  120, 128, "f"
db 128, 128, "g",  136, 128, "h",  144,128, "i", 152,128, "j"

db 16, 136, "k",  24, 136, "l",  32, 136, "m",  40, 136, "n",  48, 136, "o",  56, 136, "p",  64, 136, "q"
db 72, 136, "r",  80, 136, "s",  88, 136, "t",  96, 136, "u",  104, 136, "v",  112, 136, "w",  120, 136, "x"
db 128, 136, "y", 136, 136, "z", 144,136, "1", 152,136, "2"


db 16, 144, "3",  24, 144, "4",  32, 144, "5",  40, 144, "6",  48, 144, "7",  56, 144, "8",  64, 144, "9"
db 72, 144, "0",  80, 144, "!",  88, 144, "?",  96, 144, "?"

;TW!!
db 152, 144, "v"

;ORDER:
;A B C D E F G H I J K L M N O P Q R
;S T U V W X Y Z a b c d e f g h i j
;k l m n o p q r s t u v w x y z 1 2
;3 4 5 6 7 8 9 0 ! ? .             TW

;18 wide
;init x = 16, y = 120

;to move up/down add/sub 54 to addresses
;make sure to store address separately from
;working addresses
