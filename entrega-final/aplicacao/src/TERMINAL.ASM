; TERMINAL.ASM -- in-memory 64-column window, local preview and overlays.
; Rendering only; NETWORK handles transport. No model response is generated here.

put_line:
    ld (line_row),a
    ld (line_source),hl
    call mark_row
    call grid_row_address
    ld (line_dest),hl
    ld bc,64
    ld a,32
    call fill_memory
    ld hl,(line_source)
    ld de,(line_dest)
    ld b,64
put_line_loop:
    ld a,(hl)
    or a
    ret z
    ld (de),a
    inc hl
    inc de
    djnz put_line_loop
    ret

ui_initial:
    xor a
    ld hl,title_text
    call put_line
    ld a,1
    ld hl,ruler_text
    call put_line
    ld a,2
    ld hl,intro_text
    call put_line
    ld a,4
    ld hl,user_text
    call put_line
    ld a,&B1
    ld (ROWCOLORS+4),a
    ld a,5
    ld hl,chatgpt_text
    call put_line
    ld a,&71
    ld (ROWCOLORS+5),a
    ld a,7
    ld hl,history_intro
    call put_line
    ld a,8
    ld hl,cancel_intro
    call put_line
    ld a,23
    ld hl,footer_text
    call put_line
    ld a,11
    ld (term_row),a
    ret

term_string:
    ld a,(hl)
    or a
    ret z
    call term_char
    inc hl
    jp term_string
term_char:
    ld (term_value),a
    push hl
    push de
    push bc
    cp 10
    jp z,term_do_newline
    xor a
    ld (term_wrapped),a
    ld a,(term_row)
    call mark_row
    call grid_row_address
    ld a,(term_col)
    ld e,a
    ld d,0
    add hl,de
    ld a,(term_value)
    ld (hl),a
    ld a,(term_row)
    ld e,a
    ld d,0
    ld hl,ROWCOLORS
    add hl,de
    ld a,(term_color)
    ld (hl),a
    ld a,(term_col)
    inc a
    cp 64
    jp z,term_do_wrap
    ld (term_col),a
    jp term_char_done
term_do_newline:
    ld a,(term_wrapped)
    or a
    jp z,term_force_newline
    xor a
    ld (term_wrapped),a
    jp term_char_done
term_do_wrap:
    call term_newline
    ld a,1
    ld (term_wrapped),a
    jp term_char_done
term_force_newline:
    call term_newline
term_char_done:
    pop bc
    pop de
    pop hl
    ret
term_newline:
    xor a
    ld (term_wrapped),a
    ld (term_col),a
    ld a,(term_row)
    inc a
    cp 18
    jp c,term_store_row
    call term_scroll
    ld a,17
term_store_row:
    ld (term_row),a
    ret
term_scroll:
    ld hl,GRID+2*64
    ld de,GRID+64
    ld bc,16*64
    ldir
    ld hl,GRID+17*64
    ld bc,64
    ld a,32
    call fill_memory
    ld hl,ROWCOLORS+2
    ld de,ROWCOLORS+1
    ld bc,16
    ldir
    ld a,(term_color)
    ld (ROWCOLORS+17),a
    ld a,1
term_dirty_loop:
    call mark_row
    inc a
    cp 18
    jp nz,term_dirty_loop
    ret

preview_local:
    call overlay_restore
    ld hl,(editor_length)
    ld a,h
    or l
    ret z
    ld a,(term_col)
    or a
    call nz,term_newline
    ld a,&B1
    ld (term_color),a
    ld hl,preview_label
    call term_string
    ld a,10
    call term_char
    ld a,&F1
    ld (term_color),a
    ld hl,EDITOR
    call term_string
    ld a,10
    call term_char
    ld a,&71
    ld (term_color),a
    ld hl,local_status
    call term_string
    ld a,10
    call term_char
    ld a,&F1
    ld (term_color),a
    ret

help_toggle:
    ld a,1
    jp overlay_toggle
calibration_toggle:
    ld a,2
overlay_toggle:
    ld (overlay_requested),a
    ld b,a
    ld a,(overlay_mode)
    cp b
    jp z,overlay_restore
    or a
    call z,overlay_save
    ld a,(overlay_requested)
    ld (overlay_mode),a
    ld hl,GRID+64
    ld bc,17*64
    ld a,32
    call fill_memory
    ld hl,ROWCOLORS+1
    ld bc,17
    ld a,&F1
    call fill_memory
    ld a,(overlay_mode)
    cp 2
    jp z,draw_calibration
    call draw_help
    jp mark_all
overlay_save:
    ld hl,GRID+64
    ld de,OVERLAY_BACKUP
    ld bc,17*64
    ldir
    ld hl,ROWCOLORS+1
    ld de,OVERLAY_COLORS
    ld bc,17
    ldir
    ret
overlay_restore:
    ld a,(overlay_mode)
    or a
    ret z
    ld hl,OVERLAY_BACKUP
    ld de,GRID+64
    ld bc,17*64
    ldir
    ld hl,OVERLAY_COLORS
    ld de,ROWCOLORS+1
    ld bc,17
    ldir
    xor a
    ld (overlay_mode),a
    jp mark_all

draw_help:
    ld a,2
    ld hl,help_title
    call put_line
    ld a,4
    ld hl,help_1
    call put_line
    ld a,5
    ld hl,help_2
    call put_line
    ld a,6
    ld hl,help_3
    call put_line
    ld a,7
    ld hl,help_4
    call put_line
    ld a,8
    ld hl,help_5
    call put_line
    ld a,10
    ld hl,help_6
    call put_line
    ld a,11
    ld hl,help_7
    call put_line
    ld a,13
    ld hl,help_8
    jp put_line

draw_calibration:
    ld a,1
    ld hl,ruler_text
    call put_line
    ld a,2
    ld hl,cal_title
    call put_line
    ld a,4
    ld hl,cal_upper
    call put_line
    ld a,5
    ld hl,cal_lower
    call put_line
    ld a,6
    ld hl,font_text
    call put_line
    ld a,7
    ld hl,json_text
    call put_line
    ld a,9
    ld hl,accents_text
    call put_line
    ld a,10
    ld hl,accents_upper
    call put_line
    ; 64 logical glyphs occupy the full 256-pixel active width.
    ld hl,GRID+12*64
    ld b,64
    ld a,32
cal_ascii1:
    ld (hl),a
    inc a
    inc hl
    djnz cal_ascii1
    ld hl,GRID+13*64
    ld b,32
    ld a,96
cal_ascii2:
    ld (hl),a
    inc a
    inc hl
    djnz cal_ascii2
    ld a,15
    ld hl,cal_note
    call put_line
    jp mark_all

term_row: db 1
term_col: db 0
term_wrapped: db 0
term_color: db &F1
term_value: db 0
overlay_mode: db 0
overlay_requested: db 0
line_row: db 0
line_source: dw 0
line_dest: dw 0
title_text: dm "MSX CHATGPT TERMINAL | FASE 5 | 64x24 | OFFLINE"
    db 0
ruler_text: dm "0123456789012345678901234567890123456789012345678901234567890123"
    db 0
intro_text: dm "SCREEN 2: 64 colunas x 4 pixels = 256 pixels."
    db 0
user_text: dm "USER: digite na area inferior; Ctrl+P faz previa local."
    db 0
chatgpt_text: dm "Ctrl+Q publica .REQ; Ctrl+W transmite; Ctrl+O le .RSP."
    db 0
font_text: dm "Fonte: O0 I1l 0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    db 0
json_text: db 74,83,79,78,58,32,123,34,116,101,120,116,34,58,34,97,92,98,34,125,32,91,93,32,58,32,44,32,46,32,59,32,33,32,63,32,43,45,42,47,61,0
accents_text: dm "MSX-BR: "
    db 160,32,133,32,131,32,177,32,130,32,136,32,161,32,162,32,147,32,181,32,163,32,129,32,135,0
accents_upper: dm "MSX-BR: "
    db 132,32,143,32,140,32,176,32,144,32,141,32,137,32,138,32,142,32,180,32,139,32,154,32,128,0
footer_text: dm "Esc sair | ^S gravar ^Q pedir ^O resposta ^Y historico ^G ajuda"
    db 0
preview_label: dm "[USER / PREVIA LOCAL]"
    db 0
local_status: dm "[STATUS] Texto preservado. Nenhuma mensagem enviada."
    db 0
help_title: dm "AJUDA - Ctrl+G volta sem perder o texto"
    db 0
help_1: dm "Cursores: esquerda/direita/cima/baixo."
    db 0
help_2: dm "Enter: nova linha. A quebra automatica ocorre em 64 colunas."
    db 0
help_3: dm "Backspace apaga antes; Delete apaga na posicao do cursor."
    db 0
help_4: dm "Home ou Ctrl+A: inicio da linha logica. Ctrl+E: fim."
    db 0
help_5: dm "Ctrl+L: limpa apenas o editor. Esc: restaura video e sai."
    db 0
help_6: dm "^S grava; ^Q publica; ^W transmite; ^O importa resposta."
    db 0
help_7: dm "^D rascunho; ^B resposta; ^T auto; ^R fonte; ^Y historico."
    db 0
help_8: dm "^X duas vezes cancela pedido local. Editor: 2047 bytes."
    db 0
cal_title: dm "CALIBRACAO - Ctrl+R volta. Verifique colunas 0 e 63."
    db 0
cal_upper: dm "ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 O0 I1l MNW"
    db 0
cal_lower: dm "abcdefghijklmnopqrstuvwxyz gjpqy abcdefghijklmnopqrstuvwxyz"
    db 0
cal_note: dm "Acentos no mapa MSX-BR. Codigos nao mapeados mostram caixa."
    db 0

history_intro: dm "HISTORICO: Ctrl+Y abre; setas navegam; Esc volta ao editor."
    db 0
cancel_intro: dm "Sem argumentos: OFFLINE. Com IP privado e porta: transporte LAN."
    db 0
