.MEMORYMAP
DEFAULTSLOT 0
SLOTSIZE $0500
SLOT 0 $0000
.ENDME

.ROMBANKMAP
BANKSTOTAL 2
BANKSIZE $0500
BANKS 2
.ENDRO


.DEFINE COLOUR_BLACK		0
.DEFINE COLOUR_RED		1
.DEFINE COLOUR_GREEN		2
.DEFINE COLOUR_YELLOW		3
.DEFINE COLOUR_BLUE		4
.DEFINE COLOUR_MAGENTA		5
.DEFINE COLOUR_TEAL		6
.DEFINE COLOUR_GREY		7
.DEFINE COLOUR_DARKGREY		8
.DEFINE COLOUR_BRIGHTRED	9
.DEFINE COLOUR_BRIGHTGREEN	10
.DEFINE COLOUR_BRIGHTYELLOW	11
.DEFINE COLOUR_BRIGHTBLUE	12
.DEFINE COLOUR_BRIGHTMAGENTA	13
.DEFINE COLOUR_BRIGHTTEAL	14
.DEFINE COLOUR_WHITE		15


.BANK 0
; Reset 0
.ORG $0
    di
    ld sp, $FFFE
    ei
    jp Start

; VBlank Interrupt
.ORG $8
    reti

; Input Interrupt
.ORG $10
    xor a
    ld bc, 40*3
    ld hl, $A000
    call FillMem
    ld hl, $FE00	; input buffer
    call PrintStr
    reti



.ORG $100
Start:
    ; Set colours up
    ld hl, FG
    ld a, 15		; white
    ldi (hl), a
    xor a		; black
    ld (hl), a

    ; clear memory
    xor a
    ld bc, 40*3
    ld hl, $A000
    call FillMem
Loop:
    jp Loop

FillMem:
    ; a	    value
    ; bc    count
    ; hl    location
    ld d, a
-   ldi (hl), a
    dec bc
    ld a, b
    or c
    ld a, d
    jr nz, -
    ret

PrintStr:
    ; hl    source of string
    ld de, $A000	; VRAM
-   ldi a, (hl)
    cp 0
    ret z
    ld (de), a
    inc de
    ;ld a, 15		; fg color
    ld a, (FG)
    ld (de), a
    inc de
    xor a		; bg color
    ld a, (BG)
    ld (de), a
    inc de
    jr -
    ret

.ENUM $C000
FG	DB
BG	DB
.ENDE

; vim: filetype=wla
