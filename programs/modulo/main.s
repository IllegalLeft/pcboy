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
    ld a, 9
    ld b, 2
    dec b
    and b
    ld ($200), a
    halt

; vim: filetype=wla
