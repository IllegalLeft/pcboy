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



.BANK 0
.ORGA 0
    ld sp, $FFFE
    jp $100

.ORG $100
    ld a, 123
    ld bc, $ff
    ld hl, $2000
    ld d, a
-   ldi (hl), a
    dec bc
    ld a, b
    or c
    ld a, d
    jr nz,-
    halt

; vim: filetype=wla
