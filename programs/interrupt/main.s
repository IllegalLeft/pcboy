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
; Reset 0
.ORG $0
    ld sp, $FFFE
    jp start

; Reset 7
.ORG $38
    ld a, $FF
    reti

.ORG $100
start:
    xor a
loop:
    cp $FF
    jr c, loop
    halt

; vim: filetype=wla
