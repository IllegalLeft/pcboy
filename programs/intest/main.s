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
    di
    ld sp, $FFFE
    ei
    jp start

; VBlank Interrupt
.ORG $08
    ld hl, STR_VBLANK
    call PrintStr
    reti

; Input Interrupt
.ORG $10
    ld hl, STR_INPUT
    call PrintStr
    reti

.ORG $100
start:
    xor a
loop:
    cp $FF
    jr c, loop
    halt

PrintStr:
    ; hl    source of string
    ld de, $A000	; VRAM starts here
-   ldi a, (hl)
    cp 0
    ret z
    ld (de), a
    inc de
    ld a, 15		; fg color
    ld (de), a
    inc de
    xor a		; bg color
    ld (de), a
    inc de
    jr -
    ret			; just in case problems


STR_VBLANK:
.ASC "VBlank"
.DB $00

STR_INPUT:
.ASC "Input"
.DB $00

; vim: filetype=wla
