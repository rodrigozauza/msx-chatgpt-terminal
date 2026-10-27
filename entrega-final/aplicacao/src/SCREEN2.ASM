; SCREEN2.ASM -- TMS9918A Graphics II, BIOS transfers via CALSLT.
; Register geometry from TI TMS9918A Data Manual sections 2.2/2.4.2.
; BIOS addresses/arguments: ASCII Technical Handbook appendix 1, common MSX1.
bios_call:
    ld iy,(EXPTBL-1)
    call CALSLT
    ei
    ret

screen_enter:
    ld hl,RG0SAV
    ld de,saved_regs
    ld bc,8
    ldir
    ld a,(SCRMOD)
    ld (saved_mode),a
    ld a,(CNSDFG)
    ld (saved_cnsdfg),a
    ld a,1
    ld (CNSDFG),a
    ; Both source/destination buffers passed to BIOS are outside page 0.
    ld hl,0
    ld de,VRAM_BACKUP
    ld bc,&4000
    ld ix,&0059
    call bios_call
    ld a,1
    ld (video_saved),a
    ld a,2
    ld (SCRMOD),a
    ld hl,screen2_regs
    ld (register_ptr),hl
    xor a
    ld (register_index),a
screen_set_reg:
    ld hl,(register_ptr)
    ld b,(hl)
    ld a,(register_index)
    ld c,a
    ld ix,&0047
    call bios_call
    ld hl,(register_ptr)
    inc hl
    ld (register_ptr),hl
    ld a,(register_index)
    inc a
    ld (register_index),a
    cp 8
    jp nz,screen_set_reg
    ld hl,0
    ld bc,&4000
    xor a
    ld ix,&0056
    call bios_call
    ; Names 0..255 repeated once per Graphics II third.
    ld hl,NAMES
    ld bc,768
    ld d,0
screen_names:
    ld (hl),d
    inc hl
    inc d
    dec bc
    ld a,b
    or c
    jp nz,screen_names
    ld hl,NAMES
    ld de,&1800
    ld bc,768
    ld ix,&005C
    call bios_call
    ; D0h terminates sprite processing on TMS9918A.
    ld hl,&1B00
    ld bc,1
    ld a,&D0
    ld ix,&0056
    call bios_call
    call render_dirty
    ld b,&E0
    ld c,1
    ld ix,&0047
    jp bios_call

screen_leave:
    ld a,(video_saved)
    or a
    ret z
    ; Blank first; restore the saved 16K before restoring visible mode.
    ld b,&A0
    ld c,1
    ld ix,&0047
    call bios_call
    ld hl,VRAM_BACKUP
    ld de,0
    ld bc,&4000
    ld ix,&005C
    call bios_call
    xor a
    ld (register_index),a
screen_restore_reg:
    ld a,(register_index)
    cp 1
    jp z,screen_restore_next
    ld e,a
    ld d,0
    ld hl,saved_regs
    add hl,de
    ld b,(hl)
    ld c,a
    ld ix,&0047
    call bios_call
screen_restore_next:
    ld a,(register_index)
    inc a
    ld (register_index),a
    cp 8
    jp nz,screen_restore_reg
    ld a,(saved_mode)
    ld (SCRMOD),a
    ld a,(saved_cnsdfg)
    ld (CNSDFG),a
    ld a,(saved_regs+1)
    ld b,a
    ld c,1
    ld ix,&0047
    call bios_call
    xor a
    ld (video_saved),a
    ret

; A=row. Pattern+color invalidation. Preserves main registers.
mark_row:
    push af
    push hl
    push de
    ld e,a
    ld d,0
    ld hl,DIRTY
    add hl,de
    ld a,(hl)
    or 3
    ld (hl),a
    pop de
    pop hl
    pop af
    ret
mark_cursor_row:
    ld a,(cursor_screen_row)
mark_pattern_row:
    push af
    push hl
    push de
    ld e,a
    ld d,0
    ld hl,DIRTY
    add hl,de
    ld a,(hl)
    or 1
    ld (hl),a
    pop de
    pop hl
    pop af
    ret
mark_all:
    ld hl,DIRTY
    ld bc,24
    ld a,3
    jp fill_memory

; Fill BC bytes at HL with A, including safe zero/one-byte handling.
fill_memory:
    ld (fill_value),a
    ld a,b
    or c
    ret z
    ld a,(fill_value)
    ld (hl),a
    dec bc
    ld a,b
    or c
    ret z
    ld d,h
    ld e,l
    inc de
    ldir
    ret

; A=row -> HL=GRID+row*64; destroys DE.
grid_row_address:
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,GRID
    add hl,de
    ret
glyph_address:
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,font4x8
    add hl,de
    ret

render_dirty:
    xor a
    ld (render_row),a
render_next_row:
    ld a,(render_row)
    ld e,a
    ld d,0
    ld hl,DIRTY
    add hl,de
    ld a,(hl)
    ld (render_flags),a
    and 1
    call nz,render_patterns
    ld a,(render_flags)
    and 2
    call nz,render_colors
    ld a,(render_row)
    ld e,a
    ld d,0
    ld hl,DIRTY
    add hl,de
    ld (hl),0
    ld a,(render_row)
    inc a
    ld (render_row),a
    cp 24
    jp nz,render_next_row
    ret
render_colors:
    ld a,(render_row)
    ld e,a
    ld d,0
    ld hl,ROWCOLORS
    add hl,de
    ld a,(hl)
    push af
    ld a,(render_row)
    add a,&20
    ld h,a
    ld l,0
    pop af
    ld bc,256
    ld ix,&0056
    jp bios_call

render_patterns:
    ld a,(render_row)
    call grid_row_address
    ld (render_grid_ptr),hl
    ld hl,ROWBUF
    ld (render_buffer_ptr),hl
    ld a,32
    ld (render_tiles),a
render_tile:
    ld hl,(render_grid_ptr)
    ld a,(hl)
    inc hl
    ld (render_grid_ptr),hl
    call glyph_address
    ld (left_glyph),hl
    ld hl,(render_grid_ptr)
    ld a,(hl)
    inc hl
    ld (render_grid_ptr),hl
    call glyph_address
    push hl
    pop ix
    ld hl,(left_glyph)
    ld de,(render_buffer_ptr)
    ld b,8
render_scanline:
    ld a,(hl)
    rlca
    rlca
    rlca
    rlca
    ld c,a
    ld a,(ix+0)
    or c
    ld (de),a
    inc hl
    inc ix
    inc de
    djnz render_scanline
    ld (render_buffer_ptr),de
    ld a,(render_tiles)
    dec a
    ld (render_tiles),a
    jp nz,render_tile
    ld a,(cursor_phase)
    or a
    jp z,render_send
    ld a,(cursor_screen_row)
    ld b,a
    ld a,(render_row)
    cp b
    call z,render_cursor
render_send:
    ld a,(render_row)
    ld d,a
    ld e,0
    ld hl,ROWBUF
    ld bc,256
    ld ix,&005C
    jp bios_call
render_cursor:
    ld a,(cursor_col)
    srl a
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,ROWBUF
    add hl,de
    ld a,(cursor_col)
    and 1
    ld c,&F0
    jp z,render_cursor_ready
    ld c,&0F
render_cursor_ready:
    ld b,8
render_cursor_line:
    ld a,(hl)
    xor c
    ld (hl),a
    inc hl
    djnz render_cursor_line
    ret

screen2_regs: db &02,&A0,&06,&FF,&03,&36,&07,&01
saved_regs: ds 8
saved_mode: db 0
saved_cnsdfg: db 0
video_saved: db 0
register_ptr: dw 0
register_index: db 0
render_row: db 0
render_flags: db 0
render_tiles: db 0
render_grid_ptr: dw 0
render_buffer_ptr: dw 0
left_glyph: dw 0
fill_value: db 0
